CREATE TABLE `crypto_mining_data` (
  `player_id` VARCHAR(50) PRIMARY KEY,
  `xp` INT NOT NULL DEFAULT 0,
  `level` INT NOT NULL DEFAULT 1,
  `lastDailyReward` INT NOT NULL DEFAULT 0
);
