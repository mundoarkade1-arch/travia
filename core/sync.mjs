import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'node:crypto';
import { mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';

function keyFromSecret(secret) {
  if (!secret || secret.length < 16) throw new Error('sync_encryption_key_required');
  return createHash('sha256').update(secret).digest();
}

export function encryptJson(value, secret) {
  const iv = randomBytes(12);
  const cipher = createCipheriv('aes-256-gcm', keyFromSecret(secret), iv);
  const ciphertext = Buffer.concat([cipher.update(JSON.stringify(value), 'utf8'), cipher.final()]);
  return { version: 1, iv: iv.toString('base64url'), tag: cipher.getAuthTag().toString('base64url'), ciphertext: ciphertext.toString('base64url') };
}

export function decryptJson(record, secret) {
  if (!record || record.version !== 1) throw new Error('invalid_encrypted_record');
  const decipher = createDecipheriv('aes-256-gcm', keyFromSecret(secret), Buffer.from(record.iv, 'base64url'));
  decipher.setAuthTag(Buffer.from(record.tag, 'base64url'));
  return JSON.parse(Buffer.concat([decipher.update(Buffer.from(record.ciphertext, 'base64url')), decipher.final()]).toString('utf8'));
}

export class EncryptedJsonStore {
  constructor(file, secret) { this.file = file; this.secret = secret; }
  async read(fallback = null) {
    try { return decryptJson(JSON.parse(await readFile(this.file, 'utf8')), this.secret); }
    catch (error) { if (error.code === 'ENOENT') return fallback; throw error; }
  }
  async write(value) {
    await mkdir(dirname(this.file), { recursive: true });
    const temporary = `${this.file}.${process.pid}.tmp`;
    await writeFile(temporary, JSON.stringify(encryptJson(value, this.secret)), { mode: 0o600 });
    await rename(temporary, this.file);
  }
}
