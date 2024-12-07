import { initButtons, removeButtons } from "./buttons";
import { initMouse } from "./mouse";
import { initWheels } from "./wheels";
import { initXinput } from "./xinput";


// calling .remove() on the button doesn't seem to actually remove it from the list
$MM.onSettingsButtonPress("updateSettings", () => {
  removeButtons();
  initPushToTalk();
});

export async function initPushToTalk() {
  console.log("initialized");
  const settings: Record<string, any> = await $MM.getSettings();
  const codeList: string = settings["keycode"];
  const wheelList: string = settings["wheelkeycodes"];
  const XinputEnable: boolean = settings["XinputEnable"]
  const mouseInputEnable: boolean = settings["mouseInputEnable"];
  const mouseInputRelative: boolean = settings["mouseInputRelative"];

  console.log(`codelist is: ${codeList}`);
  initButtons(codeList);
  initWheels(wheelList);
  if (XinputEnable) {
    initXinput();
  }
  if (mouseInputEnable) {
    initMouse(mouseInputRelative);
  }
}
