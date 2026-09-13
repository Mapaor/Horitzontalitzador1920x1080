import QtQuick
import QtQuick.Controls

Item {
    id: root

    property alias frameWidth: framePopup.frameWidth
    property alias frameColor: framePopup.frameColor

    property alias overlayPath: overlayPopup.overlayPath
    property alias enableOverlayRecolor: overlayPopup.enableOverlayRecolor
    property alias overlayColor: overlayPopup.overlayColor

    property alias animatedBgPath: animatedBgPopup.animatedBgPath
    property alias animatedBgStatus: animatedBgPopup.animatedBgStatus
    property alias animatedBgIsValid: animatedBgPopup.animatedBgIsValid

    function openFramePopup() {
        framePopup.open();
    }
    
    function openOverlayPopup() {
        overlayPopup.open();
    }
    
    function openAnimatedBgPopup(inputPath) {
        animatedBgPopup.inputVideoPath = inputPath;
        animatedBgPopup.open();
    }

    FramePopup {
        id: framePopup
    }

    OverlayPopup {
        id: overlayPopup
    }

    AnimatedBgPopup {
        id: animatedBgPopup
    }
}
