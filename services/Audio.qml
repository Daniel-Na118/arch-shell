pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: !!sink?.audio?.muted
    readonly property real volume: sink?.audio?.volume ?? 0

    function setVolume(newVolume) {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1.0, newVolume));
        }
    }

    function incrementVolume(amount) {
        if (amount === undefined) amount = 0.05;
        setVolume(volume + amount);
    }

    function decrementVolume(amount) {
        if (amount === undefined) amount = 0.05;
        setVolume(volume - amount);
    }
}
