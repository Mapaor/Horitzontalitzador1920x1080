import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ComboBox { HoverHandler { cursorShape: Qt.PointingHandCursor }
    id: formatCombo
    model: ["MP4 • H.264", "MOV • H.264", "MOV • ProRes 422", "AVI • AVC-Intra 100", "MXF • AVC-Intra 100", "MXF • DNxHR HQ"]
    currentIndex: 0
    Layout.preferredWidth: 140

    background: Rectangle {
        color: "#d7d7d5"
        radius: 8
        border.color: "#b9b9b9"
        border.width: 1
    }

    contentItem: Text {
        text: formatCombo.currentText
        color: "#000000"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: 8
        rightPadding: 24
    }

    indicator: Canvas {
        id: canvas
        x: formatCombo.width - width - 12
        y: formatCombo.topPadding + (formatCombo.availableHeight - height) / 2
        width: 10
        height: 6
        contextType: "2d"
        
        rotation: formatCombo.popup.visible ? 180 : 0

        Connections {
            target: formatCombo
            function onPressedChanged() {
                canvas.requestPaint();
            }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = "#969798";
            context.fill();
        }
    }

    delegate: ItemDelegate { HoverHandler { cursorShape: Qt.PointingHandCursor }
        id: delegateItem
        width: ListView.view.width
        contentItem: Text {
            text: modelData
            color: "#000000"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: 8
        }
        background: Item {
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: index > 0 ? -1 : 0
                color: index === formatCombo.currentIndex ? "#b9b9b9" : (delegateItem.hovered || delegateItem.highlighted ? "#c9c9c9" : "transparent")
                radius: 4
            }

            Rectangle {
                width: parent.width - 16
                height: 1
                color: "#b9b9b9"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                visible: index < formatCombo.count - 1
            }
        }
    }

    popup: Popup {
        y: formatCombo.height - 1
        width: 200
        implicitHeight: contentItem.implicitHeight + 8
        padding: 4

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: formatCombo.popup.visible ? formatCombo.delegateModel : null
            currentIndex: formatCombo.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: "#d7d7d5"
            border.color: "#b9b9b9"
            radius: 8
        }
    }
}
