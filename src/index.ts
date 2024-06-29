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

  console.log(settings);
  console.log(config);

  if (settings.enableBrightness) {
    initBrightnessPlugin();
  }
  if (settings.enableVoicemeeter){
    initVoicemeeterPlugin();
  }
}

init();
