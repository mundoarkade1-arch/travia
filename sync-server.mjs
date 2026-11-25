import { randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { join } from 'node:path';
import { EncryptedJsonStore } from './core/sync.mjs';

const scrypt = promisify(scryptCallback);
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export class SyncService {
  constructor({ directory, encryptionKey, sessionTtlMs = 7 * 24 * 60 * 60 * 1000 }) {
    if (!encryptionKey || encryptionKey.length < 16) throw new Error('sync_encryption_key_required');
    this.users = new EncryptedJsonStore(join(directory, 'users.enc.json'), encryptionKey);
    this.data = new EncryptedJsonStore(join(directory, 'data.enc.json'), encryptionKey);
    this.sessions = new Map();
    this.sessionTtlMs = Math.max(1000, Number(sessionTtlMs) || 7 * 24 * 60 * 60 * 1000);
  }
  async loadUsers() { return (await this.users.read({})) || {}; }
  async register(email, password) {
    if (!emailPattern.test(email) || typeof password !== 'string' || password.length < 10) throw new Error('invalid_credentials');
    const normalized = email.toLowerCase(); const users = await this.loadUsers();
    if (users[normalized]) throw new Error('user_exists');
    const salt = randomBytes(16).toString('base64url');
    const digest = (await scrypt(password, Buffer.from(salt), 32)).toString('base64url');
    users[normalized] = { salt, digest, createdAt: new Date().toISOString() }; await this.users.write(users);
    return this.login(normalized, password);
  }
  async login(email, password) {
    const normalized = email.toLowerCase(); const user = (await this.loadUsers())[normalized];
    if (!user) throw new Error('invalid_credentials');
    const digest = await scrypt(password, Buffer.from(user.salt), 32);
    if (!timingSafeEqual(digest, Buffer.from(user.digest, 'base64url'))) throw new Error('invalid_credentials');
    const token = randomBytes(32).toString('base64url'); const expiresAt = Date.now() + this.sessionTtlMs;
    this.sessions.set(token, { user: normalized, expiresAt });
    return { token, user: normalized, expiresAt: new Date(expiresAt).toISOString() };
  }
  authenticate(token) { const session = this.sessions.get(token); if (!session) throw new Error('unauthorized'); if (Date.now() >= session.expiresAt) { this.sessions.delete(token); throw new Error('session_expired'); } return session.user; }
  async read(user) { return (await this.data.read({}))?.[user] || { revision: 0, envelope: null }; }
  async write(user, envelope, baseRevision) {
    const all = (await this.data.read({})) || {}; const current = all[user] || { revision: 0, envelope: null };
    if (Number(baseRevision) !== current.revision) { const error = new Error('sync_conflict'); error.current = current; throw error; }
    const next = { revision: current.revision + 1, envelope: { ...envelope, serverUpdatedAt: new Date().toISOString() } };
    all[user] = next; await this.data.write(all); return next;
  }
}
