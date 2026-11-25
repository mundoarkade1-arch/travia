import { migrateState } from './model.mjs';

export class MemoryStateStore {
  constructor(initial = null) { this.state = migrateState(initial); }
  async load() { return structuredClone(this.state); }
  async save(next) { this.state = migrateState(next); return this.load(); }
}

export class BrowserStateStore {
  constructor(key = 'travia-data-v1', storage = globalThis.localStorage) { this.key = key; this.storage = storage; }
  async load() { return migrateState(JSON.parse(this.storage.getItem(this.key) || 'null')); }
  async save(next) { const state = migrateState(next); this.storage.setItem(this.key, JSON.stringify(state)); return state; }
}
