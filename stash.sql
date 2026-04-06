CREATE TABLE IF NOT EXISTS `player_stashes` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(100) NOT NULL, -- De identifier van de eigenaar (bijv. 'char1:abcd...')
    `name` VARCHAR(100) NOT NULL,  -- De naam die je in de tablet hebt ingevuld
    `coords` LONGTEXT NOT NULL,    -- De locatie (X, Y, Z) opgeslagen als JSON tekst
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;