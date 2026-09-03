import {callStitchTool} from './stitch-mcp-client.mjs';

const projectId = process.argv[2];
if (!projectId) throw new Error('Project ID is required.');

const result = await callStitchTool('list_screens', {projectId});
const text = result.content?.find((item) => item.type === 'text')?.text;
const payload = text ? JSON.parse(text) : result.structuredContent;
const screens = payload?.screens ?? [];

for (const screen of screens) {
  process.stdout.write(`${JSON.stringify({
    id: screen.name?.split('/').at(-1) ?? screen.id,
    title: screen.title,
    status: screen.screenMetadata?.status,
    screenshot: screen.screenshot?.downloadUrl,
  })}\n`);
}
