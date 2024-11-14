import { initBrightnessPlugin } from "./Brightness";
import { initVoicemeeterPlugin } from "./Voicemeeter";

interface Settings {
  enableBrightness: boolean;
  enableVoicemeeter: boolean;
}

let settings: Settings;

async function init(): Promise<void> {
  const config: Record<string, any> = await $MM.getSettings();

  settings = {
    enableBrightness: config["brightnessEnabled"] ?? false,
    enableVoicemeeter: config["voicemeeterEnabled"] ?? false,
  };

  if (settings.enableBrightness) {
    await initBrightnessPlugin();
  }
  if (settings.enableVoicemeeter){
    await initVoicemeeterPlugin();
  }
}

init();
