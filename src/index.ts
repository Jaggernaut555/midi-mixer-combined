import { initBrightnessPlugin } from "./Brightness";
import { InitOBSPlugin } from "./OBS";
import { initVoicemeeterPlugin } from "./Voicemeeter";

interface Settings {
  enableBrightness: boolean;
  enableVoicemeeter: boolean;
  enableOBS: boolean;
}

let settings: Settings;

async function init(): Promise<void> {
  const config: Record<string, any> = await $MM.getSettings();

  settings = {
    enableBrightness: config["brightnessEnabled"] ?? false,
    enableVoicemeeter: config["voicemeeterEnabled"] ?? false,
    enableOBS: config["OBSEnabled"] ?? false,
  };

  if (settings.enableBrightness) {
    console.log("Running Brightness plugin");
    await initBrightnessPlugin();
  }
  if (settings.enableVoicemeeter){
    console.log("Running Voicemeeter plugin");
    await initVoicemeeterPlugin();
  }
  if (settings.enableOBS){
    console.log("Running OBS plugin");
    await InitOBSPlugin();
  }
}

init();
