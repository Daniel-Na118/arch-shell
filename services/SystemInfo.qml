pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
    id: root

    // CPU properties
    property real cpuPerc: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0

    // Memory properties
    property real memUsed: 0
    property real memTotal: 1
    readonly property real memPerc: memUsed / memTotal

    // Battery properties
    readonly property bool hasBattery: UPower.displayDevice.isLaptopBattery
    readonly property real batteryPerc: UPower.displayDevice.percentage
    readonly property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (data) {
                const stats = data.slice(1).map(n => parseInt(n, 10));
                const total = stats.reduce((a, b) => a + b, 0);
                const idle = stats[3] + (stats[4] ?? 0);

                const totalDiff = total - root.lastCpuTotal;
                const idleDiff = idle - root.lastCpuIdle;
                root.cpuPerc = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;

                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const data = text();
            const totalMatch = data.match(/MemTotal: *(\d+)/);
            const availMatch = data.match(/MemAvailable: *(\d+)/);
            
            if (totalMatch && availMatch) {
                root.memTotal = parseInt(totalMatch[1], 10);
                root.memUsed = root.memTotal - parseInt(availMatch[1], 10);
            }
        }
    }

    function formatBytes(kib: real): string {
        const mib = 1024;
        const gib = 1024 * 1024;
        if (kib >= gib) return (kib / gib).toFixed(1) + " GB";
        if (kib >= mib) return (kib / mib).toFixed(1) + " MB";
        return kib.toFixed(0) + " KB";
    }
}
