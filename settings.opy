#!mainFile "main.opy"
#!extension playMoreEffects
#!extension explosionSounds

settings {
    "main": {
        "description": f"Jetpack Cat Racing framework.\n\nMaintained by DragonEngineer & LulledLion.\nAdapted by nebula\nOriginal credit to Jashaal & Roeesun.\n\nEditor Code: {Racer.ShareCode}\nDiscord: {Racer.Discord}\nWebsite: {Racer.Website}",
        "modeName": f"Jetpack Cat Racing {VERSION}"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "mapRotation": "afterGame",
        "spectatorSlots": 3,
        "team1Slots": 0,
        "team2Slots": 10,
        "returnToLobby": "never",
        "swapTeamsAfterMatch": false
    },
    "gamemodes": {
        "skirmish": {
            PRESET_SKIRMISH_MAPS
        },
		"tdm": {
            PRESET_TDM_MAPS
        },
        "general": {
            "gamemodeStartTrigger": "manual",
            "heroLimit": "off",
            "respawnTime%": 10,
            "spawnHealthPacks": "disabled",
            "enableRandomHeroes": true
        }
    },
    "heroes": {
        "allTeams": {
            "jetpackCat": {
                "secondaryFireRechargeRate%": 500,
                "enablePassiveUnlimitedFuel": true,
                "movementSpeed%": 195,
                "enableUlt": false,
                "enableInfiniteAmmo": true
            },
            "shion": {
                "secondaryFireCooldown%": 0,
                "ability2Cooldown%": 0,
                "ability2Duration%": 500,
                "enableUlt": false,
                "enableInfiniteAmmo": true
            },
            "enabledHeroes": [
                Racer.String
            ]
        }
    }
}

