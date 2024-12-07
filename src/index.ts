import { initBrightnessPlugin } from "./Brightness";
import { InitOBSPlugin } from "./OBS";
import { initPushToTalk } from "./PushToTalk";
import { initVoicemeeterPlugin } from "./Voicemeeter";
import * as wavelink from "./WaveLink";

interface Settings {
  enableBrightness: boolean;
  enableVoicemeeter: boolean;
  enableOBS: boolean;
  enableWaveLink: boolean;
  enablePushToTalk: boolean;
}

let settings: Settings;

async function init(): Promise<void> {
  const config: Record<string, any> = await $MM.getSettings();

  settings = {
    enableBrightness: config["brightnessEnabled"] ?? false,
    enableVoicemeeter: config["voicemeeterEnabled"] ?? false,
    enableOBS: config["OBSEnabled"] ?? false,
    enableWaveLink: config["WaveLinkEnabled"] ?? false,
    enablePushToTalk: config["PushToTalkEnabled"] ?? false,
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
  if (settings.enableWaveLink){
    console.log("Running Wave Link plugin");
    await wavelink.InitWaveLinkPlugin();
  }
  if (settings.enablePushToTalk){
    console.log("Running Push To Talk plugin");
    await initPushToTalk();
  }
}

init();
