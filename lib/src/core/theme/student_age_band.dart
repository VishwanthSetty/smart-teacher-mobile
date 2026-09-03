/// Presentation density for the KG-to-Grade-10 student experience.
///
/// The bands come from the Stitch design system. When the active enrollment
/// is unavailable, the middle band is the intentionally neutral fallback.
enum StudentAgeBand {
  explorers,
  learners,
  scholars;

  factory StudentAgeBand.fromGradeRank(int? rank) {
    if (rank == null) {
      return StudentAgeBand.learners;
    }
    if (rank <= 2) {
      return StudentAgeBand.explorers;
    }
    if (rank <= 5) {
      return StudentAgeBand.learners;
    }
    return StudentAgeBand.scholars;
  }
}
