CREATE TABLE IF NOT EXISTS bad_words (
  id TEXT PRIMARY KEY,
  pattern TEXT NOT NULL UNIQUE,
  reason TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS admin_events (
  id TEXT PRIMARY KEY,
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  reason TEXT NOT NULL DEFAULT '',
  created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_bad_words_pattern ON bad_words(pattern);
CREATE INDEX IF NOT EXISTS idx_admin_events_created_at ON admin_events(created_at);
