import {readFile} from 'node:fs/promises';
import {callStitchTool} from './stitch-mcp-client.mjs';

const projects = {
  student: {
    id: '4086503233287179347',
    designSystem: 'assets/6677994744381388235',
    roleCodes: ['6.1', '6.3', '6.5', '7.1', '7.2', '7.4', '7.5', '7.6', '7.7', '7.8', '9.1', '9.2', '9.3', '9.5', '9.6'],
  },
  teacher: {
    id: '7753021071171110152',
    designSystem: 'assets/15010860429511999864',
    roleCodes: ['6.2', '6.4', '6.5', '7.3', '7.6', '7.7', '7.8', '8.1', '8.2', '8.3', '8.4', '9.1', '9.2', '9.3', '9.5', '9.6'],
  },
};

const sharedCodes = ['5.1', '5.2', '5.3', '5.4', '5.5'];

function parseSections(markdown) {
  const matches = [...markdown.matchAll(/^###\s+(\d+\.\d+)\s+(.+)$/gm)];
  const sections = new Map();

  for (let index = 0; index < matches.length; index += 1) {
    const match = matches[index];
    const end = matches[index + 1]?.index ?? markdown.length;
    const body = markdown.slice(match.index + match[0].length, end);
    const prompt = body
      .split(/\r?\n/)
      .filter((line) => line.startsWith('>'))
      .map((line) => line.replace(/^>\s?/, ''))
      .join('\n')
      .trim();

    if (prompt) {
      sections.set(match[1], {title: match[2].trim(), prompt});
    }
  }

  return sections;
}

function summarize(result) {
  const text = result?.content?.find((item) => item.type === 'text')?.text;
  if (!text) {
    return {isError: Boolean(result?.isError), message: 'No text response'};
  }

  try {
    const parsed = JSON.parse(text);
    const components = parsed.outputComponents ?? parsed.output_components ?? [];
    const screens = components.flatMap((component) => {
      const design = component.design;
      if (!design) return [];
      return design.screens ?? design.screenInstances ?? [];
    });
    return {
      isError: Boolean(result?.isError),
      projectId: parsed.projectId,
      sessionId: parsed.sessionId,
      screens: screens.map((screen) => ({
        id: screen.id ?? screen.name,
        title: screen.title ?? screen.label,
      })),
      text: components.map((component) => component.text).filter(Boolean),
      suggestions: components.map((component) => component.suggestion).filter(Boolean),
    };
  } catch {
    return {isError: Boolean(result?.isError), message: text.slice(0, 1000)};
  }
}

async function generate(role, code, section) {
  const project = projects[role];
  const prompt = `${section.prompt.replace(/\[style token §4\]/gi, '')}\n\nUse the ${role} project design system exactly. Generate exactly one polished portrait mobile screen or one clearly grouped state sheet when the brief explicitly requests variants. Title the output \"${code} ${section.title}\". Keep every interaction feasible in Flutter Material 3, with smooth purposeful motion specifications and no invented backend data.`;

  process.stdout.write(`START ${role} ${code} ${section.title}\n`);
  const result = await callStitchTool('generate_screen_from_text', {
    projectId: project.id,
    prompt,
    deviceType: 'MOBILE',
    modelId: 'GEMINI_3_1_PRO',
    designSystem: project.designSystem,
  });
  process.stdout.write(`DONE ${role} ${code} ${JSON.stringify(summarize(result))}\n`);
}

async function main() {
  const [role, requested = 'all'] = process.argv.slice(2);
  const project = projects[role];
  if (!project) {
    throw new Error('Role must be student or teacher.');
  }

  const markdown = await readFile('docs/stitch-design-prompts.md', 'utf8');
  const sections = parseSections(markdown);
  const codes = requested === 'all'
    ? [...sharedCodes, ...project.roleCodes]
    : requested.split(',').map((code) => code.trim()).filter(Boolean);

  for (const code of codes) {
    const section = sections.get(code);
    if (!section) {
      throw new Error(`No quoted Stitch prompt found for section ${code}.`);
    }
    await generate(role, code, section);
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error}\n`);
  process.exitCode = 1;
});
