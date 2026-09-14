import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    spacing: 20
    
    property bool canConvert: false
    
    signal previewClicked()
    signal convertClicked()

    Button {

        HoverHandler { cursorShape: Qt.PointingHandCursor }
        text: "Previsualitzar"
        enabled: canConvert
        onClicked: previewClicked()
        Layout.preferredHeight: 45
        Layout.preferredWidth: 160
        background: Rectangle {
            color: parent.enabled ? (parent.down ? "#b9b9b9" : (parent.hovered ? "#969798" : "transparent")) : "transparent"
            radius: 8
            border.color: parent.enabled ? "#d4365b" : "#b9b9b9"
            border.width: 2
        }
        contentItem: Text {
            text: parent.text
            color: parent.enabled ? "#d4365b" : "#b9b9b9"
            font.bold: true
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    
    Button {
    
        HoverHandler { cursorShape: Qt.PointingHandCursor }
        text: "Convertir"
        enabled: canConvert
        onClicked: convertClicked()
        Layout.preferredHeight: 45
        Layout.preferredWidth: 200
        background: Rectangle {
            color: parent.enabled ? (parent.down ? "#be2649" : (parent.hovered ? "#d4365b" : "#e9456c")) : "#d7d7d5"
            radius: 8
        }
        contentItem: Text {
            text: parent.text
            color: parent.enabled ? "#ffffff" : "#b9b9b9"
            font.bold: true
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
