import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Popup {
    id: overlayPopup

    property string overlayPath: ""
    property bool enableOverlayRecolor: false
    property string overlayColor: "#000000"

    width: 350
    height: 320
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true
    background: Rectangle {
        color: "#ffffff"
        radius: 12
        border.color: "#b9b9b9"
        border.width: 1
    }

    ColorDialog {
        id: overlayColorDialog
        title: "Color del recolor"
        selectedColor: overlayPopup.overlayColor
        onAccepted: overlayPopup.overlayColor = selectedColor
    }

    FileDialog {
        id: overlayImgDialog
        title: "Selecciona Imatge Overlay"
        nameFilters: ["Imatges PNG (*.png)"]
        onAccepted: overlayPopup.overlayPath = selectedFile
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "CONFIGURAR OVERLAY"
            color: "#969798"
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Seleccionar Imatge Overlay"
            Layout.fillWidth: true
            onClicked: overlayImgDialog.open()
            background: Rectangle {
                color: parent.down ? "#969798" : (parent.hovered ? "#b9b9b9" : "#d7d7d5")
                radius: 8
                border.color: "#b9b9b9"
                implicitHeight: 36
            }
            contentItem: Text {
                text: parent.text
                color: "#000000"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            text: overlayPopup.overlayPath === "" ? "Cap imatge seleccionada" : overlayPopup.overlayPath.substring(overlayPopup.overlayPath.lastIndexOf("/") + 1)
            color: "#000000"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        CheckBox {
            text: "Recolorejar overlay"
            checked: overlayPopup.enableOverlayRecolor
            onCheckedChanged: overlayPopup.enableOverlayRecolor = checked
            contentItem: Text {
                text: parent.text
                color: "#000000"
                verticalAlignment: Text.AlignVCenter
                leftPadding: parent.indicator.width + parent.spacing
            }
            indicator: Rectangle {
                y: parent.height / 2 - height / 2
                implicitWidth: 18
                implicitHeight: 18
                radius: 4
                color: parent.checked ? "#d4365b" : "#d7d7d5"
                border.color: "#b9b9b9"
                Text {
                    text: "✓"
                    visible: parent.parent.checked
                    color: "white"
                    anchors.centerIn: parent
                    font.pixelSize: 12
                }
            }
        }

        RowLayout {
            enabled: overlayPopup.enableOverlayRecolor
            opacity: overlayPopup.enableOverlayRecolor ? 1.0 : 0.5
            spacing: 15
            Text {
                text: "Color:"
                color: "#000000"
            }
            Rectangle {
                width: 32
                height: 32
                color: overlayPopup.overlayColor
                border.color: "#b9b9b9"
                border.width: 2
                radius: 4
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (overlayPopup.enableOverlayRecolor)
                            overlayColorDialog.open();
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            text: "Tancar"
            Layout.alignment: Qt.AlignHCenter
            onClicked: overlayPopup.close()
            background: Rectangle {
                color: parent.down ? "#969798" : (parent.hovered ? "#b9b9b9" : "#d7d7d5")
                radius: 8
                border.color: "#b9b9b9"
                implicitWidth: 100
                implicitHeight: 36
            }
            contentItem: Text {
                text: parent.text
                color: "#000000"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
