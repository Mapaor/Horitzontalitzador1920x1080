import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Popup {
    id: framePopup
    
    property int frameWidth: 10
    property string frameColor: "#000000"
    
    width: 300
    height: 260
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
        id: frameColorDialog
        title: "Color del marc"
        selectedColor: framePopup.frameColor
        onAccepted: framePopup.frameColor = selectedColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "CONFIGURAR MARC"
            color: "#969798"
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        ColumnLayout {
            spacing: 10
            Text {
                text: "Gruix del marc: " + Math.round(frameWidthSlider.value) + "px"
                color: "#000000"
            }
            Slider {
                id: frameWidthSlider
                Layout.fillWidth: true
                from: 2
                to: 50
                stepSize: 1
                value: framePopup.frameWidth
                onValueChanged: framePopup.frameWidth = Math.round(value)
                background: Rectangle {
                    x: frameWidthSlider.leftPadding
                    y: frameWidthSlider.topPadding + frameWidthSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: frameWidthSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: "#d7d7d5"
                    Rectangle {
                        width: frameWidthSlider.visualPosition * parent.width
                        height: parent.height
                        color: "#d4365b"
                        radius: 3
                    }
                }
                handle: Rectangle {
                    x: frameWidthSlider.leftPadding + frameWidthSlider.visualPosition * (frameWidthSlider.availableWidth - width)
                    y: frameWidthSlider.topPadding + frameWidthSlider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: frameWidthSlider.pressed ? "#be2649" : "#d4365b"
                    border.color: "#000000"
                    border.width: 2
                }
            }
        }

        RowLayout {
            spacing: 15
            Text {
                text: "Color:"
                color: "#000000"
            }
            Rectangle {
                width: 32
                height: 32
                color: framePopup.frameColor
                border.color: "#b9b9b9"
                border.width: 2
                radius: 4
                MouseArea {
                    anchors.fill: parent
                    onClicked: frameColorDialog.open()
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            text: "Tancar"
            Layout.alignment: Qt.AlignHCenter
            onClicked: framePopup.close()
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
