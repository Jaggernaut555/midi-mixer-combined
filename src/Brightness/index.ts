import { Assignment, ButtonType } from "midi-mixer-plugin";
import { refreshDdcciMonitorInfo } from "./ddcci";
import { MonitorInfo, refreshMonitors } from "./util";
import { refreshWmiMonitorInfo } from "./wmi";

const monitors = new Map<string, MonitorInfo>();

let refreshButton: ButtonType;

export async function initBrightnessPlugin(): Promise<void> {
  refreshMonitors(monitors);
  refreshButton = new ButtonType("Refresh Monitors", {
    name: "Refresh Monitor List",
    active: true,
  });

  refreshButton.on("pressed", () => {
    refreshMonitors(monitors);
  });
}
