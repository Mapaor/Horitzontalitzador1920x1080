import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 36
    color: "#d7d7d5"
    radius: 8
    border.color: "#b9b9b9"
    border.width: 1

    property var model: []
    property int currentIndex: 0
    property string currentText: model.length > 0 ? model[currentIndex] : ""

    RowLayout {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 2
        
        Repeater {
            model: root.model
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.currentIndex === index ? "#d4365b" : "transparent"
                radius: 6
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.currentIndex = index
                    cursorShape: Qt.PointingHandCursor
                }
                
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: root.currentIndex === index ? "#000000" : "#969798"
                    font.pixelSize: 12
                    font.bold: root.currentIndex === index
                }
            }
        }
    }
}
