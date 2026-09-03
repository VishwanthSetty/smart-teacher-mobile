import {readFile} from 'node:fs/promises';

const configPath = 'C:/Users/admin/.codex/config.toml';

export async function callStitchTool(name, args) {
  const config = await readFile(configPath, 'utf8');
  const url = config.match(/\[mcp_servers\.stitch\][\s\S]*?url\s*=\s*"([^"]+)"/)?.[1];
  const apiKey = config.match(/\[mcp_servers\.stitch\.http_headers\][\s\S]*?"X-Goog-Api-Key"\s*=\s*"([^"]+)"/)?.[1];

  if (!url || !apiKey) {
    throw new Error('Stitch MCP configuration is incomplete.');
  }

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Accept': 'application/json, text/event-stream',
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
    },
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: `${Date.now()}`,
      method: 'tools/call',
      params: {name, arguments: args},
    }),
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Stitch MCP HTTP ${response.status}: ${text}`);
  }

  const payload = JSON.parse(text);
  if (payload.error) {
    throw new Error(`Stitch MCP ${payload.error.code}: ${payload.error.message}`);
  }

  return payload.result;
}

async function main() {
  const [name, argsPath] = process.argv.slice(2);
  if (!name || !argsPath) {
    throw new Error('Usage: node stitch-mcp-client.mjs <tool> <args.json>');
  }
  const args = JSON.parse(await readFile(argsPath, 'utf8'));
  const result = await callStitchTool(name, args);
  process.stdout.write(`${JSON.stringify(result)}\n`);
}

if (process.argv[1]?.endsWith('stitch-mcp-client.mjs')) {
  main().catch((error) => {
    process.stderr.write(`${error.stack ?? error}\n`);
    process.exitCode = 1;
  });
}
