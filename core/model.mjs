export const CURRENT_SCHEMA_VERSION = 4;

const defaults = () => ({
  version: CURRENT_SCHEMA_VERSION,
  courses: [],
  tasks: [],
  settings: { semester: 5, limit: 9 },
  notes: {},
  events: [],
  materials: [],
  scenarios: [],
  tutor: { provider: 'OpenAI-compatible', endpoint: '', model: '', messages: [], conversations: {}, activeCourse: 1 }
});

export function migrateState(input) {
  const source = input && typeof input === 'object' ? structuredClone(input) : {};
  const state = Object.assign(defaults(), source);
  state.settings = Object.assign(defaults().settings, source.settings || {});
  state.notes = source.notes && typeof source.notes === 'object' ? source.notes : {};
  state.events = Array.isArray(source.events) ? source.events : [];
  state.materials = Array.isArray(source.materials) ? source.materials : [];
  state.scenarios = Array.isArray(source.scenarios) ? source.scenarios : [];
  state.tasks = Array.isArray(source.tasks) ? source.tasks : [];
  state.courses = Array.isArray(source.courses) ? source.courses : [];
  state.tutor = Object.assign(defaults().tutor, source.tutor || {});
  state.tutor.messages = Array.isArray(state.tutor.messages) ? state.tutor.messages : [];
  state.tutor.conversations = state.tutor.conversations && typeof state.tutor.conversations === 'object' ? state.tutor.conversations : {};
  state.version = CURRENT_SCHEMA_VERSION;
  return state;
}

export function exportMetadata(state) {
  const safe = migrateState(state);
  return { ...safe, exportedAt: new Date().toISOString() };
}

export function buildSyncEnvelope(state, deviceId, previousRevision = 0) {
  if (!deviceId || typeof deviceId !== 'string') throw new Error('device_id_required');
  return {
    schemaVersion: CURRENT_SCHEMA_VERSION,
    deviceId,
    updatedAt: new Date().toISOString(),
    baseRevision: Number(previousRevision) || 0,
    payload: exportMetadata(state)
  };
}

export function mergeSyncStates(local, remote) {
  const left = migrateState(local);
  const right = migrateState(remote);
  const merged = migrateState(left);
  const byId = (items) => new Map(items.filter(item => item && item.id != null).map(item => [String(item.id), item]));
  for (const key of ['tasks', 'events', 'materials', 'scenarios']) {
    const values = byId(left[key]);
    for (const item of right[key]) {
      const id = String(item.id);
      const current = values.get(id);
      if (!current || String(item.updatedAt || '') > String(current.updatedAt || '')) values.set(id, item);
    }
    merged[key] = [...values.values()];
  }
  merged.courses = right.courses.length ? right.courses : left.courses;
  merged.settings = Object.assign({}, left.settings, right.settings);
  merged.notes = Object.assign({}, left.notes, right.notes);
  merged.tutor = Object.assign({}, left.tutor, right.tutor, {
    conversations: Object.assign({}, left.tutor.conversations, right.tutor.conversations)
  });
  return merged;
}
