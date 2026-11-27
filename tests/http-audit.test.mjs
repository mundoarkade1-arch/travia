import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { spawn } from 'node:child_process';
import { mkdtemp, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

async function listen(server) {
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  return server.address().port;
}

async function startTravia(directory) {
  const port = 4800 + Math.floor(Math.random() * 500);
  const child = spawn(process.execPath, ['server.mjs'], { cwd: new URL('..', import.meta.url), env: { ...process.env, PORT: String(port), TRAVIA_SYNC_KEY: 'chave-local-de-auditoria-16', TRAVIA_SYNC_DIR: directory }, stdio: ['ignore', 'pipe', 'pipe'] });
  await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('server_start_timeout')), 10000);
    child.stdout.on('data', chunk => { if (chunk.toString().includes(`:${port}`)) { clearTimeout(timer); resolve(); } });
    child.once('error', reject);
  });
  return { child, url: `http://127.0.0.1:${port}` };
}

test('auditoria local do proxy do tutor e da API de sincronização', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'travia-http-audit-'));
  let providerRequest;
  const provider = createServer(async (request, response) => {
    providerRequest = { authorization: request.headers.authorization, body: JSON.parse(await new Promise(resolve => { let value = ''; request.on('data', chunk => { value += chunk; }); request.on('end', () => resolve(value)); })) };
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ choices: [{ message: { content: 'Resposta local de teste' } }] }));
  });
  const providerPort = await listen(provider);
  const travia = await startTravia(directory);
  t.after(async () => { travia.child.kill(); provider.close(); await rm(directory, { recursive: true, force: true }); });

  const tutor = await fetch(`${travia.url}/api/tutor`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ endpoint: `http://localhost:${providerPort}/chat/completions`, model: 'modelo-local', apiKey: 'chave-nao-persistida', messages: [{ role: 'user', content: 'Olá' }] }) });
  assert.equal(tutor.status, 200);
  assert.equal((await tutor.json()).choices[0].message.content, 'Resposta local de teste');
  assert.equal(providerRequest.authorization, 'Bearer chave-nao-persistida');
  assert.equal(providerRequest.body.model, 'modelo-local');

  const blocked = await fetch(`${travia.url}/api/tutor`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ endpoint: 'http://example.com/chat', messages: [] }) });
  assert.equal(blocked.status, 400);
  assert.equal((await blocked.json()).error, 'endpoint_insecure');

  const register = await fetch(`${travia.url}/api/auth/register`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email: 'audit@example.com', password: 'senha-local-segura' }) });
  assert.equal(register.status, 201);
  const session = await register.json();
  const envelope = { schemaVersion: 4, payload: { courses: [] } };
  const write = await fetch(`${travia.url}/api/sync`, { method: 'PUT', headers: { Authorization: `Bearer ${session.token}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ envelope, baseRevision: 0 }) });
  assert.equal(write.status, 200);
  const saved = await write.json();
  assert.equal(saved.revision, 1);

  const read = await fetch(`${travia.url}/api/sync`, { headers: { Authorization: `Bearer ${session.token}` } });
  assert.equal(read.status, 200);
  assert.equal((await read.json()).revision, 1);
  const conflict = await fetch(`${travia.url}/api/sync`, { method: 'PUT', headers: { Authorization: `Bearer ${session.token}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ envelope, baseRevision: 0 }) });
  assert.equal(conflict.status, 409);
  const unauthorized = await fetch(`${travia.url}/api/sync`, { headers: { Authorization: 'Bearer token-inexistente' } });
  assert.equal(unauthorized.status, 401);
});
