import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    color: "#000000"
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

        Text { text: "CONFIGURACIÓ DEL VÍDEO"; color: "#969798"; font.pixelSize: 12; font.bold: true; font.letterSpacing: 1 }

        RowLayout {
            spacing: 30
            Layout.fillWidth: true
            
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text { text: "Nivell de Blur: " + blurControl.value; color: "#969798"; font.pixelSize: 12 }
                Slider {
                    id: blurControl
                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 5
                    snapMode: Slider.SnapAlways
                    value: 30
                }
            }
            
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text { text: "Foscor (Darkness): " + darknessControl.value + "%"; color: "#969798"; font.pixelSize: 12 }
                Slider {
                    id: darknessControl
                    Layout.fillWidth: true
                    from: 0
                    to: 50
                    stepSize: 5
                    snapMode: Slider.SnapAlways
                    value: 15
                }
            }
        }
        
        RowLayout {
            spacing: 30
            Layout.fillWidth: true
            
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text { text: "Mode de Fons"; color: "#969798"; font.pixelSize: 12 }
                SegmentedControl {
                    id: modeControl
                    Layout.fillWidth: true
                    model: ["Zoom", "Stretch"]
                    currentIndex: 0
                }
            }
            
            ColumnLayout {
                spacing: 8
                Layout.fillWidth: true
                Text { text: "Extres"; color: "#969798"; font.pixelSize: 12 }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    SegmentedControl {
                        id: extrasControl
                        Layout.fillWidth: true
                        model: ["Cap", "Marc", "Overlay"]
                        currentIndex: 0
                    }
                    Button {
                        text: "⚙"
                        font.pixelSize: 16
                        enabled: extrasControl.currentText !== "Cap"
                        onClicked: openConfig(extrasControl.currentText)
                        background: Rectangle {
                            color: parent.enabled ? (parent.down ? "#969798" : (parent.hovered ? "#b9b9b9" : "#d7d7d5")) : "#000000"
                            radius: 8
                            border.color: "#b9b9b9"
                            border.width: 1
                            implicitHeight: 36
                            implicitWidth: 36
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#ffffff" : "#b9b9b9"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
