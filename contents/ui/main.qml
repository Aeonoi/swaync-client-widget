import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import Qt.labs.platform as Platform
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // Make the plasmoid itself invisible
    preferredRepresentation: Plasmoid.Representation.Invisible

    Platform.SystemTrayIcon {
        id: trayIcon
        visible: true
        icon.name: "notifications"
        tooltip: i18n("SwayNC Notification Center")

        onActivated: {
            if (reason === Platform.SystemTrayIcon.Trigger) {
                executable.exec("swaync-client -t")
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }
}