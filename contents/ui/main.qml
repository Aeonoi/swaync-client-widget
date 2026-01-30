import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import Qt.labs.platform as Platform
import org.kde.plasma.plasma5support as Plasma5Support
import QtQuick.Layouts

PlasmoidItem {
    id: root

    property bool dndEnabled: false

    // Make the plasmoid itself invisible
    preferredRepresentation: Plasmoid.Representation.Invisible

    Platform.SystemTrayIcon {
        id: trayIcon
        visible: true
        icon.name: dndEnabled ? "notifications-disabled" : "notifications"
        // tooltip: "ZZZZ"
        // category: Platform.SystemTrayIcon.SystemServices

        onActivated: {
            if (reason === Platform.SystemTrayIcon.Trigger) { // Left click
                executable.exec("swaync-client -t")
            } else if (reason === Platform.SystemTrayIcon.MiddleClick || reason === Platform.SystemTrayIcon.RightClick) { // Middle click
                dndToggler.exec("swaync-client -d")
            }
        }
    }

    // For single-shot commands like toggling
    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        onNewData: function(source, data) { disconnectSource(source) }
        function exec(cmd) { connectSource(cmd) }
    }

    Plasma5Support.DataSource {
        id: dndToggler
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source)
            // After toggling, check the state
            dndStateChecker.exec("swaync-client -D")
        }
        function exec(cmd) { connectSource(cmd) }
    }

    // For getting the DND state
    Plasma5Support.DataSource {
        id: dndStateChecker
        engine: "executable"
        onNewData: function(source, data) {
            disconnectSource(source)
            if (data["stdout"].trim() === "true") {
                dndEnabled = true
            } else {
                dndEnabled = false
            }
        }
        function exec(cmd) { connectSource(cmd) }
    }

    // Timer to periodically check the DND state
    Timer {
        interval: 2000 // 2 seconds
        running: true
        repeat: true
        onTriggered: dndStateChecker.exec("swaync-client -D")
    }

    Component.onCompleted: {
        // Initial check
        dndStateChecker.exec("swaync-client -D")
    }
}
