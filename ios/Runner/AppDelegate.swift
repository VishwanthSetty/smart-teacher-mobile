import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let screenProtection = AppScreenProtection()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    AVPlayer.stmDisableExternalPlayback()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "AppScreenProtection")
    else {
      fatalError("Screen-protection channel could not be registered.")
    }
    screenProtection.register(with: registrar.messenger())
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    screenProtection.obscureForAppSwitcher()
    super.applicationWillResignActive(application)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    screenProtection.refreshCaptureState()
  }
}

/// iOS has no equivalent to Android's FLAG_SECURE. In production this applies
/// the platform's best available protection: obscure the whole Flutter window
/// while screen capture is active and protect the app-switcher snapshot. A
/// screenshot notification arrives after capture, so it can warn and obscure
/// subsequent content but cannot revoke pixels already captured by iOS.
private final class AppScreenProtection {
  private static let channelName =
    "com.brinda.smart_teacher_mobile/screen_protection"

  private var channel: FlutterMethodChannel?
  private var captureObserver: NSObjectProtocol?
  private var screenshotObserver: NSObjectProtocol?
  private var isEnabled = false
  private var hideAfterScreenshot: DispatchWorkItem?

  private lazy var shieldView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Screenshots and screen recording are disabled."
    label.textColor = .white
    label.font = .preferredFont(forTextStyle: .headline)
    label.numberOfLines = 0
    label.textAlignment = .center
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
      label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
    ])
    return view
  }()

  func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setEnabled" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let arguments = call.arguments as? [String: Any],
        let enabled = arguments["enabled"] as? Bool
      else {
        result(FlutterError(
          code: "invalid_arguments",
          message: "Screen protection requires an enabled flag.",
          details: nil))
        return
      }
      self?.setEnabled(enabled)
      result(nil)
    }
  }

  func obscureForAppSwitcher() {
    guard isEnabled else { return }
    showShield()
  }

  func refreshCaptureState() {
    guard isEnabled else {
      hideShield()
      return
    }
    if UIScreen.main.isCaptured {
      showShield()
    } else {
      hideShield()
    }
  }

  private func setEnabled(_ enabled: Bool) {
    isEnabled = enabled
    hideAfterScreenshot?.cancel()
    removeObservers()

    guard enabled else {
      hideShield()
      return
    }

    captureObserver = NotificationCenter.default.addObserver(
      forName: UIScreen.capturedDidChangeNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.refreshCaptureState()
    }
    screenshotObserver = NotificationCenter.default.addObserver(
      forName: UIApplication.userDidTakeScreenshotNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.showScreenshotWarning()
    }
    refreshCaptureState()
  }

  private func showScreenshotWarning() {
    guard isEnabled else { return }
    hideAfterScreenshot?.cancel()
    showShield()
    let work = DispatchWorkItem { [weak self] in
      self?.refreshCaptureState()
    }
    hideAfterScreenshot = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: work)
  }

  private func showShield() {
    guard shieldView.superview == nil, let window = keyWindow() else { return }
    shieldView.frame = window.bounds
    window.addSubview(shieldView)
  }

  private func hideShield() {
    shieldView.removeFromSuperview()
  }

  private func keyWindow() -> UIWindow? {
    for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
      if let window = scene.windows.first(where: { $0.isKeyWindow }) {
        return window
      }
    }
    return nil
  }

  private func removeObservers() {
    if let captureObserver {
      NotificationCenter.default.removeObserver(captureObserver)
      self.captureObserver = nil
    }
    if let screenshotObserver {
      NotificationCenter.default.removeObserver(screenshotObserver)
      self.screenshotObserver = nil
    }
  }

  deinit {
    removeObservers()
  }
}

/// Turns off AirPlay video routing for every AVPlayer in the process.
///
/// The viewer PRD (B1/B3) requires AirPlay disabled: it is an output surface
/// that sends the decoded stream off-device, outside the secured playback
/// route. AVPlayer defaults `allowsExternalPlayback` to `true`, and
/// `video_player_avfoundation` never touches it (it builds its player in
/// `FVPAVFactory.playerWithPlayerItem:` and sets no playback-routing flags),
/// so there is no Dart-side option to pass — the flag can only be cleared on
/// the instance itself.
///
/// Hooking `-play` is what makes that reachable: the app never holds the
/// plugin's AVPlayer, but every playback start goes through this method, so
/// the flag is asserted before any audio/video route is established. The app
/// shows no AirPlay picker of its own (no `AVPlayerViewController`, no
/// `AVRoutePickerView`), so the Control Center route is the only path this has
/// to close.
///
/// Residual gap, deliberately accepted: enabling AirPlay from Control Center
/// *during* playback is not re-checked until the next `play()`. Closing that
/// completely means setting the flag at player construction, which requires a
/// patched `video_player_avfoundation`. Delete this whole extension if that
/// plugin ever exposes the option.
extension AVPlayer {
  private static let stmSwizzleOnce: Void = {
    guard
      let original = class_getInstanceMethod(AVPlayer.self, #selector(AVPlayer.play)),
      let replacement = class_getInstanceMethod(
        AVPlayer.self, #selector(AVPlayer.stmPlayWithExternalPlaybackDisabled))
    else {
      assertionFailure("AVPlayer.play could not be hooked; AirPlay would stay enabled.")
      return
    }
    method_exchangeImplementations(original, replacement)
  }()

  static func stmDisableExternalPlayback() {
    _ = stmSwizzleOnce
  }

  @objc func stmPlayWithExternalPlaybackDisabled() {
    allowsExternalPlayback = false
    usesExternalPlaybackWhileExternalScreenIsActive = false
    // Implementations are exchanged, so this dispatches to the original -play.
    stmPlayWithExternalPlaybackDisabled()
  }
}
