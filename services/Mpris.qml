pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    // Get the first available player that is playing, or just the first one
    readonly property MprisPlayer activePlayer: {
        const players = Mpris.players.values;
        if (players.length === 0) return null;
        
        const playing = players.find(p => p.playbackStatus === MprisPlaybackStatus.Playing);
        return playing || players[0];
    }

    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: activePlayer?.playbackStatus === MprisPlaybackStatus.Playing
    
    readonly property string title: activePlayer?.trackTitle || "Not Playing"
    readonly property string artist: activePlayer?.trackArtists.join(", ") || ""
    readonly property url artUrl: activePlayer?.trackArtUrl || ""
    
    function togglePlay() {
        if (activePlayer) activePlayer.togglePlaying();
    }

    function next() {
        if (activePlayer && activePlayer.canGoNext) activePlayer.next();
    }

    function previous() {
        if (activePlayer && activePlayer.canGoPrevious) activePlayer.previous();
    }
}
