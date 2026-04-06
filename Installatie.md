📥 Installatie
Download het script en plaats de map fs_stash in je resources map.

Voer de SQL uit in je database (HeidiSQL, phpMyAdmin, etc.):

SQL
CREATE TABLE IF NOT EXISTS `player_stashes` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `owner` VARCHAR(100) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `coords` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

Voeg het item toe aan je server. Ga naar ox_inventory/data/items.lua en voeg dit toe:

Lua
['stash_tablet'] = {
    label = 'Kluis Verkoop Tablet',
    weight = 500,
    stack = false,
    close = true,
    description = 'Een tablet om kluis-locaties te registreren en te verkopen.'
},
Voeg toe aan server.cfg:
Zorg dat het script na alle OX-scripts start.

Codefragment
ensure oxmysql
ensure ox_lib
ensure es_extended
ensure ox_target
ensure ox_inventory
ensure fs_stash

🎮 Hoe te gebruiken
Plaatsen: Zorg dat je een stash_tablet in je inventory hebt.

Verkopen: Gebruik het item. Er opent zich een menu. Vul hier het Server ID van de koper in, de naam van de kluis (bijv. "Geheime Opslag"), en de prijs.

Accepteren: De koper krijgt een popup op zijn scherm. Zodra deze accepteert, wordt het geld afgeschreven, krijgt de verkoper betaald, en wordt de kluis op de exacte locatie voor je voeten geplaatst.

Interactie: Druk op ALT (of je ingestelde target key) op de plek waar de kluis is geplaatst om hem te openen of te verwijderen.

🐛 Veelvoorkomende Problemen
Error: attempt to compare number with table bij het starten?
Zorg dat je de meest recente code gebruikt uit deze repository. De database inlaad-functie is specifiek gebouwd met ipairs om te voorkomen dat lege of corrupte database query's de server laten crashen.

Ik zie de kluis niet?
Dit klopt! Het script is prop-vrij gemaakt voor betere server performance. Je gebruikt alleen de Third-Eye (ox_target) om de interactie te vinden op de plek waar hij geplaatst is (radius van 1.2m).

Gemaakt voor FiveM Roleplay Servers. Volledig geoptimaliseerd voor OX.
