import { setTimeout } from "timers";
import { initBrightnessPlugin } from "./Brightness";
import { initHuePlugin } from "./Hue";
import { InitOBSPlugin } from "./OBS";
import { initPushToTalk } from "./PushToTalk";
import { initSpotifyPlugin } from "./Spotify";
import { initVoicemeeterPlugin } from "./Voicemeeter";
import * as wavelink from "./WaveLink";

interface Settings {
  enableBrightness: boolean;
  enableVoicemeeter: boolean;
  enableOBS: boolean;
  enableWaveLink: boolean;
  enablePushToTalk: boolean;
  enableSpotify: boolean;
  enableHue: boolean;
}

let settings: Settings;

// TODO: Handle plugins failing to load better
// This will require rewriting parts of plugins themselves

async function init(): Promise<void> {
  const config: Record<string, any> = await $MM.getSettings();

  settings = {
    enableBrightness: config["brightnessEnabled"] ?? false,
    enableVoicemeeter: config["voicemeeterEnabled"] ?? false,
    enableOBS: config["OBSEnabled"] ?? false,
    enableWaveLink: config["WaveLinkEnabled"] ?? false,
    enablePushToTalk: config["PushToTalkEnabled"] ?? false,
    enableSpotify: config["SpotifyEnabled"] ?? false,
    enableHue: config["HueEnabled"] ?? false,
  };

  if (settings.enableBrightness) {
    console.log("Initializing Brightness plugin");
    initBrightnessPlugin().then(() => {
      console.log("Running Brightness plugin");
    });
  }
  if (settings.enableVoicemeeter) {
    console.log("Initializing Voicemeeter plugin");
    initVoicemeeterPlugin().then(() => {
      console.log("Running Voicemeeter plugin");
    });
  }
  if (settings.enableOBS) {
    console.log("Initializing OBS plugin");
    InitOBSPlugin().then(() => {
      console.log("Running OBS plugin");
    });
  }
  if (settings.enableWaveLink) {
    console.log("Initializing Wave Link plugin");
    wavelink.InitWaveLinkPlugin().then(() => {
      console.log("Running Wave Link plugin");
    });
  }
  if (settings.enablePushToTalk) {
    console.log("Initializing Push To Talk plugin");
    initPushToTalk().then(() => {
      console.log("Running Push To Talk plugin");
    });
  }
  if (settings.enableSpotify) {
    console.log("Initializing Spotify plugin");
    initSpotifyPlugin().then(() => {
      console.log("Running Spotify plugin");
    });
  }
  if (settings.enableHue) {
    console.log("Initializing Hue plugin");
    initHuePlugin().then(() => {
      console.log("Running Hue plugin");
    });
  }
}

init();
