import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    color: "#ffffff"
    radius: 12
    border.color: "#b9b9b9"
    border.width: 1
    implicitHeight: layout.implicitHeight + 40

    property int blurValue: blurControl.value
    property real darknessValue: -darknessControl.value / 100.0

    property alias modeText: modeControl.currentText
    property alias extraText: extrasControl.currentText

    signal openConfig(string extra)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "CONFIGURACIÓ DEL VÍDEO"
            color: "#969798"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 1
        }

        RowLayout {
            spacing: 30
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Text {
                    text: "Nivell de Blur: " + blurControl.value
                    color: "#969798"
                    font.pixelSize: 12
                }
                Slider {
                    id: blurControl
                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 5
                    snapMode: Slider.SnapAlways
                    value: 30

                    background: Rectangle {
                        x: blurControl.leftPadding
                        y: blurControl.topPadding + blurControl.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: blurControl.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#d7d7d5"

                        Rectangle {
                            width: blurControl.visualPosition * parent.width
                            height: parent.height
                            color: "#e9456c"
                            radius: 2
                        }
                    }
                    handle: Rectangle {
                        x: blurControl.leftPadding + blurControl.visualPosition * (blurControl.availableWidth - width)
                        y: blurControl.topPadding + blurControl.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: blurControl.pressed ? "#be2649" : "#e9456c"
                    }
                }
            }

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Text {
                    text: "Foscor (Darkness): " + darknessControl.value + "%"
                    color: "#969798"
                    font.pixelSize: 12
                }
                Slider {
                    id: darknessControl
                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 5
                    snapMode: Slider.SnapAlways
                    value: 10

                    background: Rectangle {
                        x: darknessControl.leftPadding
                        y: darknessControl.topPadding + darknessControl.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 4
                        width: darknessControl.availableWidth
                        height: implicitHeight
                        radius: 2
                        color: "#d7d7d5"

                        Rectangle {
                            width: darknessControl.visualPosition * parent.width
                            height: parent.height
                            color: "#e9456c"
                            radius: 2
                        }
                    }
                    handle: Rectangle {
                        x: darknessControl.leftPadding + darknessControl.visualPosition * (darknessControl.availableWidth - width)
                        y: darknessControl.topPadding + darknessControl.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: darknessControl.pressed ? "#be2649" : "#e9456c"
                    }
                }
            }

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Text {
                    text: "Mode de Fons"
                    color: "#969798"
                    font.pixelSize: 12
                }
                SegmentedControl {
                    id: modeControl
                    Layout.fillWidth: true
                    model: ["Zoom", "Stretch"]
                    currentIndex: 0
                }
            }
        }

        RowLayout {
            spacing: 30
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text {
                    text: "Mode"
                    color: "#969798"
                    font.pixelSize: 12
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    SegmentedControl {
                        id: extrasControl
                        Layout.fillWidth: true
                        model: ["Normal", "Marc", "PNG Overlay", "Video Overlay"]
                        currentIndex: 0
                    }
                    Button {
                        icon.source: "../assets/config.svg"
                        icon.color: enabled ? "#ffffff" : "#969798"
                        icon.width: 18
                        icon.height: 18
                        enabled: extrasControl.currentText !== "Normal"
                        onClicked: openConfig(extrasControl.currentText)
                        background: Rectangle {
                            color: parent.enabled ? (parent.down ? "#d4365b" : (parent.hovered ? "#e9456c" : "#d4365b")) : "#ffffff"
                            radius: 8
                            border.color: parent.enabled ? (parent.down ? "#d4365b" : (parent.hovered ? "#e9456c" : "#d4365b")) : "#b9b9b9"
                            border.width: 1
                            implicitHeight: 36
                            implicitWidth: 36
                        }
                    }
                }
            }
        }
    }
}
