ALTER TABLE uploads ADD COLUMN ip_version TEXT NOT NULL DEFAULT 'v4';

ALTER TABLE aggregates ADD COLUMN ip_version TEXT NOT NULL DEFAULT 'v4';

CREATE INDEX IF NOT EXISTS idx_uploads_geo_carrier_ip_version
  ON uploads(server_province_code, server_carrier, ip_version);
