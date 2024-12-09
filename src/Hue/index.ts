// local
import { HueSyncApi } from "./api";

let hue: HueSyncApi;

export async function initHuePlugin(): Promise<void> {
  hue = new HueSyncApi();
}
