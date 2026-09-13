import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Popup {
    id: animatedBgPopup

    property string animatedBgPath: ""
    property var animatedBgStatus: ({})
    property bool animatedBgIsValid: false
    property string inputVideoPath: ""
    property bool isAnalyzing: false

    width: 380
    height: 380
    anchors.centerIn: Overlay.overlay
    modal: true
    focus: true

    background: Rectangle {
        color: "#ffffff"
        radius: 12
        border.color: "#b9b9b9"
        border.width: 1
    }

    Connections {
        target: videoConverter
        function onAnimatedBgCheckFinished(res) {
            animatedBgPopup.animatedBgStatus = JSON.parse(res)
            animatedBgPopup.animatedBgIsValid = animatedBgPopup.animatedBgStatus.can_proceed === true
            animatedBgPopup.isAnalyzing = false
        }
    }

    FileDialog {
        id: animatedBgDialog
        title: "Selecciona Vídeo de Fons"
        nameFilters: ["Vídeos MOV (*.mov)"]
        onAccepted: {
            animatedBgPopup.animatedBgPath = selectedFile
            animatedBgPopup.isAnalyzing = true
            videoConverter.check_animated_bg_async(animatedBgPopup.animatedBgPath, animatedBgPopup.inputVideoPath)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "CONFIGURAR FONS ANIMAT"
            color: "#969798"
            font.pixelSize: 14
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: animatedBgPopup.animatedBgPath === "" ? "Seleccionar Vídeo Fons" : "Canviar vídeo"
            Layout.fillWidth: true
            onClicked: animatedBgDialog.open()
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
            text: animatedBgPopup.animatedBgPath === "" ? "Cap vídeo seleccionat" : animatedBgPopup.animatedBgPath.substring(animatedBgPopup.animatedBgPath.lastIndexOf("/") + 1)
            color: "#000000"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#b9b9b9"
            visible: animatedBgPopup.animatedBgPath !== ""
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            visible: animatedBgPopup.animatedBgPath !== ""

            Text {
                text: "Analitzant vídeo..."
                color: "#f59e0b"
                font.bold: true
                font.pixelSize: 12
                visible: animatedBgPopup.isAnalyzing
            }

            ColumnLayout {
                spacing: 5
                visible: !animatedBgPopup.isAnalyzing && Object.keys(animatedBgPopup.animatedBgStatus).length > 0
                
                Text {
                    text: animatedBgPopup.animatedBgStatus.format_msg || ""
                    textFormat: Text.RichText
                    font.bold: true
                    font.pixelSize: 12
                }
                Text {
                    text: animatedBgPopup.animatedBgStatus.loop_msg || ""
                    color: animatedBgPopup.animatedBgStatus.loop_ok ? "#10b981" : (animatedBgPopup.animatedBgStatus.is_long ? "#f59e0b" : "#ef4444")
                    font.bold: true
                    font.pixelSize: 12
                    visible: animatedBgPopup.animatedBgStatus.loop_msg !== undefined && animatedBgPopup.animatedBgStatus.loop_msg !== ""
                }
                Text {
                    text: animatedBgPopup.animatedBgStatus.duration_msg || ""
                    color: animatedBgPopup.animatedBgStatus.is_long ? "#10b981" : (animatedBgPopup.animatedBgStatus.loop_ok ? "#f59e0b" : "#ef4444")
                    font.bold: true
                    font.pixelSize: 12
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                text: "Tancar"
                onClicked: animatedBgPopup.close()
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

            Button {
                text: "Aplicar"
                enabled: animatedBgPopup.animatedBgIsValid && !animatedBgPopup.isAnalyzing
                onClicked: animatedBgPopup.close()
                background: Rectangle {
                    color: parent.enabled ? (parent.down ? "#be2649" : (parent.hovered ? "#d4365b" : "#e9456c")) : "#d7d7d5"
                    radius: 8
                    border.color: parent.enabled ? "#e9456c" : "#b9b9b9"
                    implicitWidth: 100
                    implicitHeight: 36
                }
                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "#ffffff" : "#b9b9b9"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
