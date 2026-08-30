import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Rectangle {
    Layout.fillWidth: true
    // When no video, make it massive
    Layout.preferredHeight: videoPath === "" ? 400 : 90
    color: "#000000"
    radius: 12
    border.color: "#b9b9b9"
    border.width: 1
    
    // Animate the height transition
    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    }
    
    property string videoPath: ""
    property string outputName: ""
    property string outputDir: ""

    onVideoPathChanged: {
        if (videoPath !== "") {
            var path = videoPath.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            var nameWithExt = path.substring(path.lastIndexOf("/") + 1)
            var name = nameWithExt.substring(0, nameWithExt.lastIndexOf("."))
            if(name === "") name = nameWithExt;
            outputName = name + "_16x9"
            
            var dir = path.substring(0, path.lastIndexOf("/"))
            outputDir = "file:///" + dir
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        
        DropArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            onDropped: (drop) => {
                if (drop.hasUrls && drop.urls.length > 0) {
                    videoPath = drop.urls[0]
                }
            }
            Rectangle {
                anchors.fill: parent
                color: parent.containsDrag ? "#d4365b" : "transparent"
                opacity: parent.containsDrag ? 0.1 : 1.0
                radius: 8
                border.color: parent.containsDrag ? "#d4365b" : "#b9b9b9"
                border.width: videoPath === "" ? 2 : 1
            }
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 15
                
                Text {
                    text: videoPath === "" ? "📥 Arrossega el vídeo aquí" : "Vídeo: " + videoPath.substring(videoPath.lastIndexOf("/")+1)
                    color: parent.parent.containsDrag ? "#d4365b" : (videoPath === "" ? "#969798" : "#000000")
                    font.pixelSize: videoPath === "" ? 18 : 14
                    font.bold: videoPath !== ""
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Button {
                    text: "o seleccionar fitxer..."
                    visible: videoPath === ""
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: inputDialog.open()
                    background: Rectangle {
                        color: parent.down ? "#969798" : (parent.hovered ? "#b9b9b9" : "#d7d7d5")
                        radius: 8
                        border.color: "#b9b9b9"
                        implicitWidth: 180
                        implicitHeight: 40
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: "Canviar vídeo..."
                    visible: videoPath !== ""
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: inputDialog.open()
                    background: Rectangle { color: "transparent" }
                    contentItem: Text {
                        text: parent.text
                        color: parent.hovered ? "#be2649" : "#d4365b"
                        font.underline: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    FileDialog {
        id: inputDialog
        title: "Selecciona un vídeo"
        nameFilters: ["Vídeos (*.mp4 *.mov *.mkv *.avi *.webm)"]
        onAccepted: videoPath = selectedFile
    }
}
