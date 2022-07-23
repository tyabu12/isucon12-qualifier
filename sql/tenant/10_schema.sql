DROP TABLE IF EXISTS competition;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;

CREATE TABLE competition (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  title TEXT NOT NULL,
  finished_at BIGINT NULL,
  created_at BIGINT NOT NULL,
  created_at_desc BIGINT GENERATED ALWAYS AS (-created_at) STORED NOT NULL,
  updated_at BIGINT NOT NULL
);
CREATE INDEX `competition_tenant_id_created_at` ON `competition`(`tenant_id`, `created_at`);
CREATE INDEX `competition_tenant_id_created_at_desc` ON `competition`(`tenant_id`, `created_at_desc`);

CREATE TABLE player (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  display_name TEXT NOT NULL,
  is_disqualified BOOLEAN NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL
);

CREATE TABLE player_score (
  id VARCHAR(255) NOT NULL PRIMARY KEY,
  tenant_id BIGINT NOT NULL,
  player_id VARCHAR(255) NOT NULL,
  competition_id VARCHAR(255) NOT NULL,
  score BIGINT NOT NULL,
  row_num BIGINT NOT NULL,
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  INDEX `tenant_id` (`tenant_id`)
);
CREATE INDEX `player_score_tenant_id_created_at` ON `player_score`(`tenant_id`, `created_at`);
