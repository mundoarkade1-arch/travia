import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { buildSyncEnvelope, mergeSyncStates, migrateState } from '../core/model.mjs';
import { EncryptedJsonStore } from '../core/sync.mjs';
import { SyncService } from '../sync-server.mjs';

test('migração preserva dados do MVP e aplica versão atual', () => {
  const state = migrateState({ courses: [{ id: 1, name: 'Cálculo', hours: 76.5 }], settings: { semester: 4 } });
  assert.equal(state.version, 4);
  assert.equal(state.courses[0].name, 'Cálculo');
  assert.equal(state.settings.limit, 9);
  assert.deepEqual(state.tutor.conversations, {});
});

test('merge de sincronização preserva item local mais recente', () => {
  const local = { tasks: [{ id: 1, text: 'local', updatedAt: '2026-11-24T10:00:00Z' }] };
  const remote = { tasks: [{ id: 1, text: 'remoto antigo', updatedAt: '2026-11-24T09:00:00Z' }, { id: 2, text: 'novo' }] };
  const merged = mergeSyncStates(local, remote);
  assert.equal(merged.tasks.find(item => item.id === 1).text, 'local');
  assert.equal(merged.tasks.length, 2);
});

test('armazenamento de sincronização é criptografado e tem revisão/conflicto', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'travia-test-'));
  t.after(() => rm(directory, { recursive: true, force: true }));
  const store = new EncryptedJsonStore(join(directory, 'secret.enc.json'), 'uma-chave-local-de-teste');
  await store.write({ privateText: 'conteúdo acadêmico' });
  assert.deepEqual(await store.read(), { privateText: 'conteúdo acadêmico' });
  assert.doesNotMatch(await readFile(join(directory, 'secret.enc.json'), 'utf8'), /conteúdo acadêmico/);
  const service = new SyncService({ directory, encryptionKey: 'uma-chave-local-de-teste' });
  const login = await service.register('aluno@example.com', 'senha-segura-123');
  assert.equal(service.authenticate(login.token), 'aluno@example.com');
  const envelope = buildSyncEnvelope({ courses: [] }, 'device-a');
  const first = await service.write('aluno@example.com', envelope, 0);
  assert.equal(first.revision, 1);
  await assert.rejects(() => service.write('aluno@example.com', envelope, 0), /sync_conflict/);
  const restarted = new SyncService({ directory, encryptionKey: 'uma-chave-local-de-teste' });
  const recoveredLogin = await restarted.login('aluno@example.com', 'senha-segura-123');
  assert.equal(restarted.authenticate(recoveredLogin.token), 'aluno@example.com');
  assert.equal((await restarted.read('aluno@example.com')).revision, 1);
  assert.throws(() => restarted.authenticate('token-inexistente'), /unauthorized/);
});

test('sessão expira sem apagar conta nem dados persistidos', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'travia-session-test-'));
  t.after(() => rm(directory, { recursive: true, force: true }));
  const service = new SyncService({ directory, encryptionKey: 'uma-chave-local-de-teste', sessionTtlMs: 1000 });
  const first = await service.register('sessao@example.com', 'senha-segura-123');
  assert.equal(service.authenticate(first.token), 'sessao@example.com');
  await new Promise(resolve => setTimeout(resolve, 1100));
  assert.throws(() => service.authenticate(first.token), /session_expired/);
  const second = await service.login('sessao@example.com', 'senha-segura-123');
  assert.equal(service.authenticate(second.token), 'sessao@example.com');
});
