import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: previewPopup
    width: 850; height: 520
    anchors.centerIn: Overlay.overlay
    modal: true; focus: true
    background: Rectangle { color: "#d7d7d5"; radius: 12; border.color: "#b9b9b9"; border.width: 1 }
    
    function showImage(image_path) {
        previewImage.source = image_path + "?t=" + new Date().getTime()
        previewPopup.open()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        Text { text: "PREVISUALITZACIÓ"; color: "#969798"; font.pixelSize: 14; font.bold: true; Layout.alignment: Qt.AlignHCenter }

        Image {
            id: previewImage
            Layout.fillWidth: true
            Layout.fillHeight: true
            fillMode: Image.PreserveAspectFit
            cache: false
        }
        
        Button {
        
            HoverHandler { cursorShape: Qt.PointingHandCursor }
            text: "Tancar"
            Layout.alignment: Qt.AlignHCenter
            onClicked: previewPopup.close()
            background: Rectangle {
                color: parent.down ? "#969798" : (parent.hovered ? "#b9b9b9" : "#d7d7d5")
                radius: 8
                border.color: "#b9b9b9"
                implicitWidth: 120; implicitHeight: 40
            }
            contentItem: Text { text: parent.text; color: "#000000"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        }
    }
    onClosed: previewImage.source = ""
}
