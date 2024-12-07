import { ButtonType } from "midi-mixer-plugin";
import { KeyButton, KeysDown, KeysTap, KeysUp, parseKeycode } from "./utils";
import { Hardware, vkToString } from "keysender";

interface PTTButton {
  keyButton: KeyButton;
  pushButton: ButtonType;
  releaseButton: ButtonType;
  tapButton: ButtonType;
}

const handle = new Hardware("Midi-Mixer-PTT-Keyboard");

let buttons: PTTButton[] = [];
export function initButtons(list: string) {
  let codes = list.split(',');

  for (let codeString of codes) {

    let kb = parseKeycode(codeString);

    if (!kb) {
      console.log(`Skipping invalid entry`)
      continue;
    }
    let keyButton = kb;

    let butt: PTTButton = {
      keyButton,
      pushButton: new ButtonType(`PushButton${keyButton.name}`, {
        name: `${keyButton.name} key down`,
        active: true,
      }),
      releaseButton: new ButtonType(`ReleaseButton${keyButton.name}`, {
        name: `${keyButton.name} key up`,
        active: true,
      }),
      tapButton: new ButtonType(`TapButton${keyButton.name}`, {
        name: `${keyButton.name} key tap`,
        active: true,
      }),
    }

    let codes = keyButton.newFormat ? keyButton.codes.map((c) => c.key!) : keyButton.codes.map((c) => vkToString(c.code));

    butt.pushButton.on("pressed", () => {
      // KeysDown(keyButton.codes)
      handle.keyboard.toggleKey(codes, true);
    });

    butt.releaseButton.on("pressed", () => {
      // KeysUp([...keyButton.codes].reverse())
      handle.keyboard.toggleKey(codes, false);
    });

    butt.tapButton.on("pressed", async () => {
      for (let i = 0; i < keyButton.multiplier; i++) {
        // KeysTap(keyButton.codes)
        await handle.keyboard.sendKey(codes);
      }
    });

    buttons.push(butt);
  }
}

export function removeButtons() {
  for (let b of buttons) {
    b.pushButton.remove();
    b.releaseButton.remove();
    b.tapButton.remove();
  }
  buttons = [];
}
