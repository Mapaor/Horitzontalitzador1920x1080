import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Item {
    property int frameWidth: 10
    property string frameColor: "#000000"

    property string overlayPath: ""
    property bool enableOverlayRecolor: false
    property string overlayColor: "#000000"

    function openFramePopup() {
        framePopup.open();
    }
    function openOverlayPopup() {
        overlayPopup.open();
    }

    ColorDialog {
        id: frameColorDialog
        title: "Color del marc"
        selectedColor: frameColor
        onAccepted: frameColor = selectedColor
    }

    ColorDialog {
        id: overlayColorDialog
        title: "Color del recolor"
        selectedColor: overlayColor
        onAccepted: overlayColor = selectedColor
    }

    FileDialog {
        id: overlayImgDialog
        title: "Selecciona Imatge Overlay"
        nameFilters: ["Imatges PNG (*.png)"]
        onAccepted: overlayPath = selectedFile
    }

    Popup {
        id: framePopup
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
                    value: frameWidth
                    onValueChanged: frameWidth = Math.round(value)
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
                    color: frameColor
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

    Popup {
        id: overlayPopup
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
                text: overlayPath === "" ? "Cap imatge seleccionada" : overlayPath.substring(overlayPath.lastIndexOf("/") + 1)
                color: "#000000"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            CheckBox {
                text: "Recolorejar overlay"
                checked: enableOverlayRecolor
                onCheckedChanged: enableOverlayRecolor = checked
                contentItem: Text {
                    text: parent.text
                    color: "#000000"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: parent.indicator.width + parent.spacing
                }
                indicator: Rectangle {
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
                enabled: enableOverlayRecolor
                opacity: enableOverlayRecolor ? 1.0 : 0.5
                spacing: 15
                Text {
                    text: "Color:"
                    color: "#000000"
                }
                Rectangle {
                    width: 32
                    height: 32
                    color: overlayColor
                    border.color: "#b9b9b9"
                    border.width: 2
                    radius: 4
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (enableOverlayRecolor)
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
}
