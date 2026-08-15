var Hero;
let Project = {
        "jetpackCat": ["dsc.gg/jetpack", "TSB2M", "jetpackcat.racing"],
        "shion": [],
        "doomfist": ["dsc.gg/projectmomentum", "NAPGF", "doom.pk"],
        "genji": ["dsc.gg/genjiparkour", "54CRY", "genji.pk"],
        "kiriko": [],
        "lucio": ["discord.com/invite/G9QBCDY", "luciosurfleague.com"],
        "mercy": ["discord.gg/mercyparkour", "mercyparkour.codes"],
    }
let Result = `
enum Hero:
	JETPACKCAT = Hero.JETPACK_CAT,
    JUNKERQUEEN = Hero.JUNKER_QUEEN,
    WRECKINGBALL = Hero.WRECKING_BALL,

enum Racer:
    Hero = Hero.${Hero.toUpperCase()}
    String = "${Hero}"
    StringLC = "${Hero.toLowerCase()}"
    StringUC = "${Hero.toUpperCase()}"
    Discord = "${Project[Hero][0] ?? ''}"
    ShareCode = "${Project[Hero][1] ?? 'XXXXX'}"
    Website = "${Project[Hero][2] ?? ''}"
`;
Result;