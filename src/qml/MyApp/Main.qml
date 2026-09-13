import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

Window {
    id: mainWindow
    width: 800
    height: 600
    visible: true
    title: "Horitzontalitzador3Cat"
    color: "#e0e0e0"

    property bool isPreviewing: false
    property bool isConverting: false
    property bool isVideoLoaded: videoPath !== ""

    // Global State properties
    property string videoPath: ioPanel.videoPath
    property string outputDir: ioPanel.outputDir
    property string outputName: ioPanel.outputName

    property int blurValue: configPanel.blurValue
    property real darknessValue: configPanel.darknessValue
    property string modeText: configPanel.modeText
    property string extraText: configPanel.extraText

    property int frameWidth: appPopups.frameWidth
    property string frameColor: appPopups.frameColor
    property string overlayPath: appPopups.overlayPath
    property bool enableOverlayRecolor: appPopups.enableOverlayRecolor
    property string overlayColor: appPopups.overlayColor

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Text {
            text: "HORITZONTALITZADOR 1920×1080"
            color: "#d4365b"
            font.pixelSize: 28
            font.bold: true
            font.family: "Segoe UI"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            visible: true
        }

        Item {
            Layout.fillHeight: true
            visible: !mainWindow.isVideoLoaded
        }

        IoPanel {
            id: ioPanel
            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
            visible: !mainWindow.isVideoLoaded
        }

        ConfigPanel {
            id: configPanel
            Layout.fillWidth: true
            visible: mainWindow.isVideoLoaded
            onOpenConfig: extra => {
                if (extra === "Marc")
                    appPopups.openFramePopup();
                else if (extra === "Overlay")
                    appPopups.openOverlayPopup();
                else if (extra === "Fons animat")
                    appPopups.openAnimatedBgPopup(mainWindow.videoPath);
            }
        }

        FooterPanel {
            id: footerPanel
            Layout.fillWidth: true
            visible: mainWindow.isVideoLoaded

            outputDir: mainWindow.outputDir
            outputName: mainWindow.outputName

            onOutputNameChanged: {
                if (outputName !== ioPanel.outputName)
                    ioPanel.outputName = outputName;
            }
            onOutputDirChanged: {
                if (outputDir !== ioPanel.outputDir)
                    ioPanel.outputDir = outputDir;
            }

            canConvert: mainWindow.videoPath !== "" && !mainWindow.isConverting && !mainWindow.isPreviewing

            onPreviewClicked: {
                footerPanel.setStatus("Generant previsualització...", "white");
                mainWindow.isPreviewing = true;
                videoConverter.preview(mainWindow.videoPath, mainWindow.blurValue, mainWindow.darknessValue, mainWindow.modeText, mainWindow.extraText === "Marc", mainWindow.frameColor, mainWindow.frameWidth, mainWindow.extraText === "Overlay" ? mainWindow.overlayPath : "", mainWindow.enableOverlayRecolor, mainWindow.overlayColor, mainWindow.extraText === "Fons animat" ? appPopups.animatedBgPath : "", appPopups.animatedBgStatus.is_long === true, appPopups.animatedBgStatus.loop_ok === true);
            }

            onConvertClicked: {
                footerPanel.setStatus("Convertint...", "white");
                mainWindow.isConverting = true;
                footerPanel.setProgress(0);
                videoConverter.convert(mainWindow.videoPath, mainWindow.outputDir, mainWindow.outputName, mainWindow.blurValue, mainWindow.darknessValue, mainWindow.modeText, mainWindow.extraText === "Marc", mainWindow.frameColor, mainWindow.frameWidth, mainWindow.extraText === "Overlay" ? mainWindow.overlayPath : "", mainWindow.enableOverlayRecolor, mainWindow.overlayColor, mainWindow.extraText === "Fons animat" ? appPopups.animatedBgPath : "", appPopups.animatedBgStatus.is_long === true, appPopups.animatedBgStatus.loop_ok === true);
            }
        }

        Item {
            Layout.fillHeight: true
        } // Spacer at bottom
    }

    AppPopups {
        id: appPopups
    }

    PreviewPopup {
        id: previewPopup
    }

    Connections {
        target: videoConverter

        function onProgressUpdated(percent) {
            footerPanel.setProgress(percent);
        }

        function onConversionFinished(success, message) {
            mainWindow.isConverting = false;
            footerPanel.setStatus(message, success ? "#7ef0b4" : "#be2649");
            if (success) {
                footerPanel.setProgress(1.0);
            } else {
                footerPanel.setProgress(0.0);
            }
        }

        function onPreviewFinished(success, message, image_path) {
            mainWindow.isPreviewing = false;
            footerPanel.setStatus(success ? "Previsualització llesta" : message, success ? "#7ef0b4" : "#be2649");
            if (success) {
                previewPopup.showImage(image_path);
            }
        }
    }
}
