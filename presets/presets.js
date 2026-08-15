var preset;
var result = `macro EDITOR_ON = ${preset === 0}\n`;
data = {
    /* Key: [ file_path, skirmish_maps, TDM_maps ] */
    example: ["Map_Data.opy", `"workshopExpanse", "workshopIsland"`, `"workshopExpanseNight", "workshopIslandNight"`],
    1: ["1_LulledLionJPC1.opy", `"eichenwalde"`, ``],
    2: ["2_LulledLionShion1.opy", `"eichenwalde"`, ``],
}
if (preset === 0){
    result += "#!define PRESET_SKIRMISH_MAPS /**/\n#!define PRESET_TDM_MAPS /**/\n#!define PRESET_MAP_DATA /**/\n";
}
else if (preset in data) {
    result += `#!define PRESET_SKIRMISH_MAPS "enabledMaps": [${data[preset][1].toLowerCase()}]\n`;
    result += `#!define PRESET_TDM_MAPS "enabledMaps": [${data[preset][2].toLowerCase()}]\n`;
    result += `#!define PRESET_MAP_DATA #!include "presets/${data[preset][0]}"\n`;
}
else{
    throw new RangeError("Preset Not Found!");
}
result;