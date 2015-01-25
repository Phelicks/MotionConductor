import QtQuick 2.3
import QtQuick 2.4
import QtQuick 2.1
import QtQuick 2.0

import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3
import QtMultimedia 5.0
import QtQml 2.2 // for Component QML Type


ApplicationWindow {
    title: qsTr("MusikGesten")
    visible: true

    //nicht 16:9 wegen Taskleiste
    width: 1600
    height: 900

    minimumWidth: 1200 //75
    minimumHeight: 675

    Loader{
        sourceComponent: style
    }


    property int seconds: 0
    property int minutes: 0
    property int endMinutes: 0
    property bool cutCurrentGoPreviousTrack : false
    property bool cutCurrentGoNextTrack : false

    property int songDuration : 0
    property string songName : "Play your music!"
    property string songArtist : ""

    property bool visibleVoice : true
    property bool visiblePiano : true
    property bool visibleGuitar : true
    property bool visibleBass : true
    property bool visibleDrums : true

    property int masterVolumeValue: 20
    property real masterSpeedValue: 0.5

    property int voiceVolumeValue: 20
    property int pianoVolumeValue: 20
    property int guitarVolumeValue: 20
    property int bassVolumeValue: 20
    property int drumsVolumeValue: 20

    property int state: 0;




    Component{
        id:style
        Rectangle {
            color: "#191d1d"
            width: 1920
            height: 1080
        }
    }



    ColumnLayout{

        id: mainLayout
        spacing: 0
        anchors.fill: parent
        anchors.rightMargin: 50
        anchors.topMargin: 75
        anchors.bottomMargin: 40
        //        anchors.leftMargin: 50


        ColumnLayout{
            id: wholeUpperPart
            spacing: 0
            Layout.minimumHeight: 100
            Layout.fillHeight: true
            Layout.minimumWidth: 800
            Layout.fillWidth: true

            RowLayout{
                id: trackTextLayout
                spacing: 0
                Layout.fillWidth:  true
                Layout.minimumWidth: 800
                Layout.fillHeight: true
                Layout.minimumHeight: 60

                Rectangle {
                    id: rectTitelArtistString
                    color: "#191d1d"

                    anchors.leftMargin: 50
                    anchors.fill: parent
                    Layout.fillWidth: true
                    Layout.minimumWidth: 650

                    FontLoader {
                        id: robotoThin;
                        source: "content/fonts/Roboto-Thin.ttf"
                    }

                    Text{
                        id: songLabel
                        text: songName
                        color: "#00ebe1"
                        font.family: robotoThin.name
                        font.pointSize: parent.height/5 //22

                        wrapMode: Text.WordWrap
                        Layout.fillHeight: true
                    }

                    Text{
                        id: artistLabel
                        text: songArtist
                        font.family: robotoThin.name
                        color: "#00ebe1"
                        font.pointSize: parent.height/7 //17

                        wrapMode: Text.WordWrap

                        Layout.fillHeight: true
                        anchors.left: songLabel.left
                        anchors.top: songLabel.bottom
                    }
                }
                Rectangle {
                    id: rectLautstGeschw
                    color: "#191d1d"

                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                    Layout.maximumWidth: 250
                    Layout.fillHeight: true

                    RowLayout{
                        id: layoutVolumeSpeed
                        spacing: 0
                        anchors.fill: parent

                        Rectangle{
                            id: recVolume
                            color: "#191d1d"
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            anchors.right: recGeschwText.left
                            anchors.rightMargin: 40

                            ProgressBar{
                                id: volumeProgressBar
                                value: masterVolumeValue

                                ///////////////////////////////////////////////////////////////////////////////////////////////////
                                minimumValue: 0 //minimaler Wert anpassen!
                                maximumValue: 100 //maximaler Wert anpassen!

                                orientation: Qt.Vertical
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                anchors.right: recVolume.right

                                style: ProgressBarStyle{
                                    background: Rectangle {
                                                color: "#4c5c5b"
                                                implicitWidth: recVolume.height
                                                implicitHeight: recVolume.height/3.5
                                    }
                                    progress: Rectangle{
                                        color: "#00ebe1"
                                    }
                                }
                            }
                        }

                         Rectangle{
                             id: recGeschwText
                             color: "#191d1d"

                             Layout.fillWidth: true
                             Layout.minimumWidth: layoutVolumeSpeed.height//140
                             Layout.maximumWidth: layoutVolumeSpeed.height //150

                             Layout.fillHeight: true
                             anchors.right: layoutVolumeSpeed.right

                             Canvas {
                                 id: canvas
                                 width: recGeschwText.height
                                 height: recGeschwText.height
                                 antialiasing: true

                                 property color primaryColor: "#4c5c5b"
                                 property color secondaryColor: "#00ebe1"

                                 property real centerWidth: recGeschwText.height / 2
                                 property real centerHeight: recGeschwText.height / 2
                                 property real radius: Math.min(canvas.width, canvas.height) / 2 - lineWidth/2

                                 property real lineWidth: recGeschwText.height / 14 //12
                                 property real minimumValue: 0
                                 property real maximumValue: 1

                                 property real currentValue: masterSpeedValue //wert kommt von wii fernbedienung

                                 // this is the angle that splits the circle in two arcs
                                 // first arc is drawn from 0 radians to angle radians
                                 // second arc is angle radians to 2*PI radians
                                 property real angle: (currentValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI

                                 // we want both circle to start / end at 12 o'clock
                                 // without this offset we would start / end at 9 o'clock
                                 property real angleOffset: -Math.PI / 2

                                 property string geschwText: ""

                                 onPrimaryColorChanged: requestPaint()
                                 onSecondaryColorChanged: requestPaint()
                                 onMinimumValueChanged: requestPaint()
                                 onMaximumValueChanged: requestPaint()
                                 onCurrentValueChanged: requestPaint()

                                 onPaint: {
                                     var ctx = getContext("2d");
                                     ctx.save();
                                     ctx.clearRect(0, 0, canvas.width, canvas.height);

                                     // First, thinner arc
                                     // From angle to 2*PI
                                     ctx.beginPath();
                                     ctx.lineWidth = lineWidth;
                                     ctx.strokeStyle = primaryColor;
                                     ctx.arc(canvas.centerWidth,
                                             canvas.centerHeight,
                                             canvas.radius,
                                             angleOffset + canvas.angle,
                                             angleOffset + 2*Math.PI);
                                     ctx.stroke();

                                     // Second, thicker arc
                                     // From 0 to angle
                                     ctx.beginPath();
                                     ctx.lineWidth = lineWidth;
                                     ctx.strokeStyle = canvas.secondaryColor;
                                     ctx.arc(canvas.centerWidth,
                                             canvas.centerHeight,
                                             canvas.radius,
                                             canvas.angleOffset,
                                             canvas.angleOffset + canvas.angle);
                                     ctx.stroke();
                                     ctx.restore();
                                 }

                                 Text {
                                     anchors.centerIn: parent
                                     text: canvas.geschwText

                                     font.family: robotoThin.name
                                     font.pointSize: parent.height/7
                                     color: "#00ebe1"
                                     wrapMode: Text.WordWrap
                                 }

                             }
                        }
                    }
                }
            }

            RowLayout{
                id: statusleistenLayout
                spacing: 0
                Layout.minimumHeight: 30
                Layout.fillHeight: true
                Layout.minimumWidth: 800


                Timer {
                    // haupttimer; für laufende Zeit und statusbalken
                    id: timerPlayState
                    interval: 16//16;
                    running: true;
                    repeat: true;
                    triggeredOnStart: true

                    onTriggered: {
                        state = mediaPlayer.stateChanged();
                        if(state == 1)
                        {
                            timerProgressStatusBar.running = true
                            timerlaufendeZeit.running = true
                            imgPlay.opacity = 0
                            imgPause.opacity = 1
                        }
                        else if (state == 2)
                        {
                            timerProgressStatusBar.running = false
                            timerlaufendeZeit.running = false
                            imgPlay.opacity = 1
                            imgPause.opacity = 0
                        }
                        else if (state == 3)
                        {
                            progressStatusBar.value = 0
                            timerProgressStatusBar.running = true
                            timerlaufendeZeit.running = true
                            imgPlay.opacity = 0
                            imgPause.opacity = 1
                        }

                        //Angaben zu Lautstärke der einzelnen Spuren

                        //voice
                        if(mediaPlayer.isVoiceSelected())
                        {
                            if(mediaPlayer.isAPressed())
                            {
                                mediaPlayer.setVolume_voice(mediaPlayer.getMasterVolume()); //zusammen mit vorheriger Zeile "weg" kommentieren
                            }
                            imgMikro.source = "images/mikro_selected.png";
                        }
                        else
                        {
                            imgMikro.source = "images/mikro_grey.png";
                        }

                        //piano
                        if(mediaPlayer.isPianoSelected())
                        {
                            if(mediaPlayer.isAPressed())
                            {
                                mediaPlayer.setVolume_piano(mediaPlayer.getMasterVolume()); //zusammen mit vorheriger Zeile "weg" kommentieren
                            }
                            imgPiano.source = "images/piano_selected.png";
                        }
                        else
                        {
                            imgPiano.source = "images/piano_grey.png";
                        }

                        //guitar
                        if(mediaPlayer.isGuitarSelected())
                        {
                            if(mediaPlayer.isAPressed())
                            {
                                mediaPlayer.setVolume_guitar(mediaPlayer.getMasterVolume()); //zusammen mit vorheriger Zeile "weg" kommentieren
                            }
                            imgGuitar.source = "images/guitar_selected.png";
                        }
                        else
                        {
                            imgGuitar.source = "images/guitar_grey.png";
                        }

                        //bass
                        if(mediaPlayer.isBassSelected())
                        {
                            if(mediaPlayer.isAPressed())
                            {
                                mediaPlayer.setVolume_bass(mediaPlayer.getMasterVolume()); //zusammen mit vorheriger Zeile "weg" kommentieren
                            }
                            imgBass.source = "images/bass_selected.png";
                        }
                        else
                        {
                            imgBass.source = "images/bass_grey.png";
                        }

                        //drums
                        if(mediaPlayer.isDrumsSelected())
                        {
                            if(mediaPlayer.isAPressed())
                            {
                                mediaPlayer.setVolume_drums(mediaPlayer.getMasterVolume()); //zusammen mit vorheriger Zeile "weg" kommentieren
                            }
                            imgDrums.source = "images/drums_selected.png";
                        }
                        else
                        {
                            imgDrums.source = "images/drums_grey.png";
                        }

                        voiceVolumeValue = mediaPlayer.getArrayVolume(4);
                        pianoVolumeValue = mediaPlayer.getArrayVolume(3);
                        guitarVolumeValue = mediaPlayer.getArrayVolume(2);
                        drumsVolumeValue = mediaPlayer.getArrayVolume(1);
                        bassVolumeValue = mediaPlayer.getArrayVolume(0);
                    }
                }

                Rectangle{
                    id:rectLeftMargin
                    color: "#191d1d"
                    width: 50
                    Layout.fillHeight: true
                }

                Rectangle{
                    id:rectLaufendeZeit
                    color: "#191d1d"

                    Layout.fillWidth: true
                    Layout.minimumWidth: 40
                    Layout.maximumWidth: 80
                    Layout.fillHeight: true

                    Timer {
                        // nur für die Ausgabe der Zeit, wert kommt von progressStatusBar
                        id: timerlaufendeZeit
                        interval: 500//16;
                        running: false;
                        repeat: true;
                        triggeredOnStart: true

                        onTriggered: {
                            var now = Math.round(progressStatusBar.value);
                            seconds = Math.round(now / 1000);
                            textLaufendeZeit.text = Qt.formatTime(new Date(0, 0, 0, minutes, seconds), 'hh:mm');

//                            console.log('progressStatusBar.maximumValue', progressStatusBar.maximumValue); // get correct number
//                            console.log('textGeamt', textGesamtzeit.text); //
//                            console.log('songDurationGlobal', songDuration); //
                           // console.log('progressStatusBar.value', progressStatusBar.value); //
//                            console.log('mediaPlayer.hasPiano()', mediaPlayer.hasPiano()); //
                         }
                    }

                    Text{
                        id: textLaufendeZeit
                        text: "00:00" // wert kommt von timerLaufendeZeit
                        font.family: robotoThin.name
                        color: "#00ebe1"
                        font.pointSize: parent.height/5 //13

                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft

                    }
                }

                Rectangle{
                    id: rectStatusleiste
                    color: "#191d1d"

                    Layout.fillWidth: true
                    Layout.minimumWidth: 670
                    Layout.fillHeight: true


                    Timer {
                        // haupttimer; für laufende Zeit und statusbalken
                        id: timerProgressStatusBar
                        interval: 16//16;
                        running: false;
                        repeat: true;
                        triggeredOnStart: true

                        onTriggered: {

                            //DARSTELLUNG
                            songDuration = mediaPlayer.getDuration();
                            songName = mediaPlayer.getNameOfCurrentTrack();
                            songArtist = mediaPlayer.getArtistOfCurrentTrack();

                            visibleVoice = mediaPlayer.hasVoice();
                            visiblePiano = mediaPlayer.hasPiano();
                            visibleGuitar = mediaPlayer.hasGuitar();
                            visibleBass = mediaPlayer.hasBass();
                            visibleDrums = mediaPlayer.hasDrums();

                            progressStatusBar.value = progressStatusBar.value + (16*mediaPlayer.getPlaybackRate());

 ///////////////////////////////////////////////////////////////////////////////////////////////////
                             //Angaben zu masterVolume
                            masterVolumeValue = mediaPlayer.getAverageVolume();//hier Methode von Felix die Wert der Wii fernbedienung liefert
                            //mediaPlayer.setMasterVolume(masterVolumeValue); //zusammen mit vorheriger Zeile "weg" kommentieren

                            // Angaben zu masterSpeed
                            //mediaPlayer.setPlaybackRate(masterSpeedValue); //zusammen mit vorheriger Zeile "weg" kommentieren


                            masterSpeedValue = mediaPlayer.getSpeed();//hier Methode von Felix die Wert der Wii fernbedienung liefert
                            canvas.geschwText  = mediaPlayer.getPlaybackRate() + "x";//canvas.currentValue * 2 + "x";

                        }
                    }

                    ProgressBar {
                        id: progressStatusBar
                        value: 0 //Timerangabe kommt von timerProgressStatusBar
                        minimumValue: 0
       ///////////////////////////////////////////////////////////////////
                        maximumValue:  songDuration//271000 //mediaPlayer.getDuration() Liedlaenge hier: 4:31 SONGDURATION!!!!!!!!!!!!

                        anchors.top: rectStatusleiste.top
                        anchors.centerIn: rectStatusleiste


                        style: ProgressBarStyle{
                            background: Rectangle {
//                                        radius: 2
                                        color: "#1a3e3e"
                                        implicitWidth: rectStatusleiste.width
                                        implicitHeight: rectStatusleiste.height /15
                                    }
                            progress: Rectangle{
                                color: "#00ebe1"
                        }
                    }
                }
            }

                Rectangle{
                    id:rectGesamtzeit
                    color: "#191d1d"

                    Layout.fillWidth: true
                    Layout.minimumWidth: 40
                    Layout.maximumWidth: 80
                    Layout.fillHeight: true

                    Text{

                        id: textGesamtzeit
                        text: Qt.formatTime(new Date(0, 0, 0, endMinutes, Math.round(songDuration/1000)), 'hh:mm') //"3:99"
                        font.family: robotoThin.name
                        color: "#00ebe1"
                        font.pointSize: parent.height/5 //13


                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight

                    }
                }
            }
        }

        RowLayout{
            id:wholeLowerPart
            spacing: 0

            Layout.minimumHeight: 350
            Layout.fillHeight: true
            Layout.minimumWidth: 850


            Rectangle {
                id:rectListRahmen
                color: "#191d1d"
                //color: "white"
                //opacity: 0.2

                Layout.fillWidth: true
                Layout.minimumWidth: 260
                Layout.maximumWidth: 355
                Layout.fillHeight: true

                Rectangle{
                    id:rectTrackliste
                    color: "#1a3e3e"
//                    color: "red"
                    anchors.fill: parent
                    anchors.topMargin: 35
                    anchors.rightMargin: 40

                        Rectangle{
                            id: rectPlayliste
                            color: "#1a3e3e"

                            anchors.fill: parent
//                            Layout.fillWidth: true
                            Layout.minimumWidth: 170
                            Layout.maximumWidth: 310

                            anchors.topMargin: 15
                            anchors.bottomMargin: 5
                            anchors.leftMargin: 12
                            anchors.rightMargin: 1


                            Text{
                               id: textPlayliste
                               font.family: robotoThin.name
                               fontSizeMode: Text.Fit
                               minimumPointSize: 6
                               font.pointSize: 10.2  //64
                               font.bold: true
                               wrapMode: Text.WordWrap
                               color: "#000000"
                               lineHeight: 1.4 //rectPlayliste.height /textPlayliste.lineCount /30 //17.5 //durch Anzahl der Zeilen!!! 16
                               lineHeightMode: Text.ProportionalHeight
                               height: rectPlayliste.height
                               width: rectPlayliste.width

                               verticalAlignment: Text.AlignTop
                               horizontalAlignment: Text.AlignLeft

                               text:"3:14   Devils Words
           - Actions
4:12    Dead Rosees
           - Andrew Cole
5:41    An Ultraviolet Apology
           - Butterfly Effect
4:15    On The Line
           - James May
4:10    Through My Eyes
           - Jay Menon
6:15    What Is This Thing Called Love
           - Jesper Buhl Trio"

                            }
                        }
                    }
//                }


                Rectangle {
                    id: recPauseButton
                    color: "#00ebe1"
                    height: parent.height/11
                    width: parent.height/11
                    radius: 40

                    Image {
                        id: imgPlay
                        opacity : 1
                        anchors.fill: parent
                        source: "images/play.png"
                        smooth: true
                        MouseArea {
                            id: mouseTestArea
                            anchors.fill: parent
                            onClicked: {

                                mediaPlayer.start_pause()

                                //Track starten
                                if(imgPlay.opacity == 1){
                                    //instrumente.color = "khaki"
                                    timerProgressStatusBar.running = true;
                                    timerlaufendeZeit.running = true;

                                    imgPlay.opacity = 0;
                                    imgPause.opacity = 1;

                                    //Track pausieren
                                }else if(imgPlay.opacity == 0){
                                    timerProgressStatusBar.running = false
                                    timerlaufendeZeit.running = false
                                    imgPlay.opacity = 1
                                    imgPause.opacity = 0
                                }


                            }
                        }

                    }
                    Image {
                        id: imgPause
                        anchors.fill: parent;
                        source: "images/pause.png";
                        smooth: true
                        opacity: 0
                    }
                    anchors.right: rectTrackliste.right
                    anchors.rightMargin: - recPauseButton.height/2 //position des pausbuttons an der trackliste
                    anchors.top: rectTrackliste.top
                    anchors.topMargin: - recPauseButton.height/2 //position des pausbuttons an der trackliste
                }
            }

            Rectangle{
                id: instrumente
                color: "transparent"
//                opacity: 0.2
                Layout.fillWidth:  true
                Layout.minimumWidth: 590
                Layout.fillHeight: true

               RowLayout{
                   id: layoutInstruments
                   spacing: 0
                   anchors.fill: parent

                   anchors.topMargin: layoutInstruments.height/ 4 //120
                   anchors.bottomMargin: layoutInstruments.height/ 4.15 //90

                   property real trennlinie : 5
                   property real trennlinieDivident: 3.5
                   property real marginDivident: 3

                   property real verbindungslinieDivident: 120

                   Rectangle{
                       id: recAlwaysMargin
                       color: "transparent"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columLayoutRecAlwaysMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recAlwaysVerbindMikro
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columLayoutRecAlwaysMargin.width
                               anchors.top: columLayoutRecAlwaysMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }


                           Rectangle{
                               id:recGreyAlwaysMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recAlwaysMargin.bottom
                               anchors.topMargin: recAlwaysMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recAlwaysMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recAlwaysMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }
                   Rectangle{
                       id: recMikro
                       visible: visibleVoice
                       color: "#191d1d"
                       Layout.fillHeight: true
                       Layout.fillWidth: true

                       ColumnLayout{
                           id:layoutMikro
                           anchors.fill: parent

                           Rectangle{
                               id: recVerbindMikro
                               color: "#4c5c5b"
                               Layout.fillWidth: true
                               Layout.fillHeight: true
                               Layout.maximumHeight: layoutMikro.height/ layoutInstruments.verbindungslinieDivident
                               anchors.top: recImgMikro.top
                               anchors.topMargin: recImgMikro.height/ 2

                           }

                           Rectangle{
                               id: recImgMikro
                               color: "transparent"
                               anchors.fill: parent
                               anchors.bottomMargin: recMikro.height /1.3

                               Layout.maximumHeight: recMikro.height /5
                               anchors.top: layoutMikro.top
                               anchors.leftMargin: recVerbindMikro.width/2.9
                               anchors.rightMargin: recVerbindMikro.width/2.9


                               Image{
                                   id: imgMikro
                                   anchors.fill: parent
                                   fillMode: Image.PreserveAspectFit
                                   source: "images/mikro_grey.png";
                                   smooth: true
                               }                               
                           }

                           Rectangle{
                               id: recVolumeMikro
                               color: "transparent"
                               anchors.fill: parent
                               anchors.topMargin: recMikro.height/1.4
                               anchors.bottom: recMikro.bottom


                               ProgressBar{
                                   id: volumeMikroProgressBar
                                   value: voiceVolumeValue //angabe kommt von Wii Fernbedienung
                                   minimumValue: 0
                                   maximumValue: 100 //max Volumewert

                                   orientation: Qt.Vertical
                                   anchors.centerIn: recVolumeMikro

                                   style: ProgressBarStyle{
                                       background: Rectangle {
                                                   color: "#4c5c5b"
                                                   implicitWidth: recVolumeMikro.height // / 5 //recMikro.width/2
                                                   implicitHeight: recVolumeMikro.height / 3.5 //breite durch 3,5
                                       }
                                       progress: Rectangle{
                                           color: "#00ebe1"
                                       }
                                   }
                               }
                           }
                       }

                   }
                   Rectangle{
                       id: recMikroMargin
                       visible: visibleVoice
                       color: "transparent" //#191d1d"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columnLayoutRecMikroMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recMarginVerbindMikro
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columnLayoutRecMikroMargin.width
                               anchors.top: columnLayoutRecMikroMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }


                           Rectangle{
                               id:recGreyMikroMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recMikroMargin.bottom
                               anchors.topMargin: recMikroMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recMikroMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recMikroMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }                   

                   Rectangle{
                       id: recPiano
                       visible: visiblePiano
                       color: "transparent"
                       Layout.fillHeight: true
                       Layout.fillWidth: true

                       ColumnLayout{
                           id:layoutPiano
                           anchors.fill: parent

                           Rectangle{
                               id: recVerbindPiano
                               color: "#4c5c5b"
                               Layout.fillWidth: true
                               Layout.fillHeight: true
                               Layout.maximumHeight: layoutPiano.height/ layoutInstruments.verbindungslinieDivident
                               anchors.top: recImgPiano.top
                               anchors.topMargin: recImgPiano.height/ 2
                           }

                           Rectangle{
                               id: recImgPiano
                               color: "transparent"
//                               opacity: 0.3
                               anchors.fill: parent
                               anchors.bottomMargin: recPiano.height /1.3

                               Layout.maximumHeight: recPiano.height /5
                               anchors.top: layoutPiano.top
                               anchors.leftMargin: recVerbindPiano.width / 7//50
                               anchors.rightMargin: recVerbindPiano.width / 7 //50

                               Image{
                                   id: imgPiano
                                   anchors.fill: parent
                                   fillMode: Image.PreserveAspectFit
                                   source: "images/piano_grey.png";
                                   smooth: true
                               }
                           }

                           Rectangle{
                               id: recVolumePiano
                               color: "transparent"
                               anchors.fill: parent
                               anchors.topMargin: recPiano.height/1.4
                               anchors.bottom: recPiano.bottom


                               ProgressBar{
                                   id: volumePianoProgressBar
                                   value: pianoVolumeValue //angabe kommt von Wii Fernbedienung
                                   minimumValue: 0
                                   maximumValue: 100 //max Volumewert

                                   orientation: Qt.Vertical
                                   anchors.centerIn: recVolumePiano

                                   style: ProgressBarStyle{
                                       background: Rectangle {
                                                   color: "#4c5c5b"
                                                   implicitWidth: recVolumePiano.height // / 5 //recMikro.width/2
                                                   implicitHeight: recVolumePiano.height / 3.5 //breite durch 3,5
                                       }
                                       progress: Rectangle{
                                           color: "#00ebe1"
                                       }
                                   }
                               }
                           }
                       }

                   }
                   Rectangle{
                       id: recPianoMargin                       
                       visible: visiblePiano
                       color: "#191d1d"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columnLayoutRecPianoMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recPianoMarginVerbindPiano
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columnLayoutRecPianoMargin.width
                               anchors.top: columnLayoutRecPianoMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }

                           Rectangle{
                               id:recGreyPianoMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recPianoMargin.bottom
                               anchors.topMargin: recPianoMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recPianoMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recPianoMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }
                   Rectangle{
                       id: recGuitar
                       visible: visibleGuitar
                       color: "transparent"
                       Layout.fillHeight: true
                       Layout.fillWidth: true

                       ColumnLayout{
                           id:layoutGuitar
                           anchors.fill: parent

                           Rectangle{
                               id: recVerbindGuitar
                               color: "#4c5c5b"
                               Layout.fillWidth: true
                               Layout.fillHeight: true
                               Layout.maximumHeight: layoutGuitar.height/ layoutInstruments.verbindungslinieDivident
                               anchors.top: recImgGuitar.top
                               anchors.topMargin: recImgGuitar.height/ 2
                           }

                           Rectangle{
                               id: recImgGuitar
                               color: "transparent"
//                               opacity: 0.3
                               anchors.fill: parent
                               anchors.bottomMargin: recGuitar.height /1.3

                               Layout.maximumHeight: recGuitar.height /5
                               anchors.top: layoutGuitar.top
                               anchors.leftMargin: recVerbindGuitar.width /11
                               anchors.rightMargin: recVerbindGuitar.width /11

                               Image{
                                   id: imgGuitar
                                   anchors.fill: parent
                                   fillMode: Image.PreserveAspectFit
                                   source: "images/guitar_grey.png";
                                   smooth: true
                               }
                           }

                           Rectangle{
                               id: recVolumeGuitar
                               color: "transparent"
                               anchors.fill: parent
                               anchors.topMargin: recGuitar.height/1.4
                               anchors.bottom: recGuitar.bottom

                               ProgressBar{
                                   id: volumeGuitarProgressBar
                                   value: guitarVolumeValue //angabe kommt von Wii Fernbedienung
                                   minimumValue: 0
                                   maximumValue: 100 //max Volumewert

                                   orientation: Qt.Vertical
                                   anchors.centerIn: recVolumeGuitar

                                   style: ProgressBarStyle{
                                       background: Rectangle {
                                                   color: "#4c5c5b"
                                                   implicitWidth: recVolumeGuitar.height // / 5 //recMikro.width/2
                                                   implicitHeight: recVolumeGuitar.height / 3.5 //breite durch 3,5
                                       }
                                       progress: Rectangle{
                                           color: "#00ebe1"
                                       }
                                   }
                               }
                           }
                       }

                   }
                   Rectangle{
                       id: recGuitarMargin
                       visible: visibleGuitar
                       color: "#191d1d"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columnLayoutRecGuitarMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recMarginVerbindGuitar
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columnLayoutRecGuitarMargin.width
                               anchors.top: columnLayoutRecGuitarMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }

                           Rectangle{
                               id:recGreyGuitarMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recGuitarMargin.bottom
                               anchors.topMargin: recGuitarMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recGuitarMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recGuitarMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }
                   Rectangle{
                       id: recBass
                       visible: visibleBass
                       color: "transparent"
                       Layout.fillHeight: true
                       Layout.fillWidth: true

                       ColumnLayout{
                           id:layoutBass
                           anchors.fill: parent

                           Rectangle{
                               id: recVerbindBass
                               color: "#4c5c5b"
                               Layout.fillWidth: true
                               Layout.fillHeight: true
                               Layout.maximumHeight: layoutBass.height/ layoutInstruments.verbindungslinieDivident
                               anchors.top: recImgBass.top
                               anchors.topMargin: recImgBass.height/ 2
                           }

                           Rectangle{
                               id: recImgBass
                               color: "transparent"
//                               opacity: 0.3
                               anchors.fill: parent
                               anchors.bottomMargin: recBass.height /1.3

                               Layout.maximumHeight: recBass.height /5
                               anchors.top: layoutBass.top
                               anchors.leftMargin: recVerbindBass.width /11
                               anchors.rightMargin: recVerbindBass.width /11

                               Image{
                                   id: imgBass
                                   anchors.fill: parent
                                   fillMode: Image.PreserveAspectFit
                                   source: "images/bass_grey.png";
                                   smooth: true
                               }
                           }

                           Rectangle{
                               id: recVolumeBass
                               color: "transparent"
                               anchors.fill: parent
                               anchors.topMargin: recBass.height/1.4
                               anchors.bottom: recBass.bottom

                               ProgressBar{
                                   id: volumeBassProgressBar
                                   value: bassVolumeValue //angabe kommt von Wii Fernbedienung
                                   minimumValue: 0
                                   maximumValue: 100 //max Volumewert

                                   orientation: Qt.Vertical
                                   anchors.centerIn: recVolumeBass

                                   style: ProgressBarStyle{
                                       background: Rectangle {
                                                   color: "#4c5c5b"
                                                   implicitWidth: recVolumeBass.height // / 5 //recMikro.width/2
                                                   implicitHeight: recVolumeBass.height / 3.5 //breite durch 3,5
                                       }
                                       progress: Rectangle{
                                           color: "#00ebe1"
                                       }
                                   }
                               }
                           }
                       }
                   }
                   Rectangle{
                       id: recBassMargin
                       visible: visibleBass
                       color: "#191d1d"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columnLayoutRecBassMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recMarginVerbindBass
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columnLayoutRecBassMargin.width
                               anchors.top: columnLayoutRecBassMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }


                           Rectangle{
                               id:recGreyBassMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recBassMargin.bottom
                               anchors.topMargin: recBassMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recBassMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recBassMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }
                   Rectangle{
                       id: recDrums
                       visible: visibleDrums
                       color: "transparent"
                       Layout.fillHeight: true
                       Layout.fillWidth: true

                       ColumnLayout{
                           id:layoutDrums
                           anchors.fill: parent

                           Rectangle{
                               id: recVerbindDrums
                               color: "#4c5c5b"
                               Layout.fillWidth: true
                               Layout.fillHeight: true
                               Layout.maximumHeight: layoutDrums.height/ layoutInstruments.verbindungslinieDivident
                               anchors.top: recImgDrums.top
                               anchors.topMargin: recImgDrums.height/ 2
                           }

                           Rectangle{
                               id: recImgDrums
                               color: "transparent"
//                               opacity: 0.3
                               anchors.fill: parent
                               anchors.bottomMargin: recDrums.height /1.3

                               Layout.maximumHeight: recDrums.height /5
                               anchors.top: layoutDrums.top
                               anchors.leftMargin: recVerbindDrums.width /4.2
                               anchors.rightMargin: recVerbindDrums.width /4.2

                               Image{
                                   id: imgDrums
                                   anchors.fill: parent
                                   fillMode: Image.PreserveAspectFit
                                   source: "images/drums_grey.png";
                                   smooth: true
                               }
                           }

                           Rectangle{
                               id: recVolumeDrums
                               color: "transparent"
                               anchors.fill: parent
                               anchors.topMargin: recDrums.height/1.4
                               anchors.bottom: recDrums.bottom

                               ProgressBar{
                                   id: volumeDrumsProgressBar
                                   value: drumsVolumeValue//angabe kommt von Wii Fernbedienung
                                   minimumValue: 0
                                   maximumValue: 100 //max Volumewert

                                   orientation: Qt.Vertical
                                   anchors.centerIn: recVolumeDrums

                                   style: ProgressBarStyle{
                                       background: Rectangle {
                                                   color: "#4c5c5b"
                                                   implicitWidth: recVolumeDrums.height // / 5 //recMikro.width/2
                                                   implicitHeight: recVolumeDrums.height / 3.5 //breite durch 3,5
                                       }
                                       progress: Rectangle{
                                           color: "#00ebe1"
                                       }
                                   }
                               }
                           }
                       }
                   }
                   Rectangle{
                       id: recDrumsMargin
                       visible: visibleDrums
                       color: "#191d1d"
                       Layout.fillHeight: true
                       width: layoutInstruments.trennlinie

                       ColumnLayout{
                           id: columnLayoutRecDrumsMargin
                           anchors.fill: parent
                           spacing: 0

                           Rectangle{
                               id: recMarginVerbindDrums
                               color: "#4c5c5b"
                               Layout.fillHeight: true
                               Layout.maximumHeight: recVerbindMikro.height
                               width: columnLayoutRecDrumsMargin.width
                               anchors.top: columnLayoutRecDrumsMargin.top
                               anchors.topMargin: recImgMikro.height/ 2
                           }


                           Rectangle{
                               id:recGreyDrumsMargin
                               color: "#4c5c5b"
                               anchors.fill: parent
                               anchors.bottom: recDrumsMargin.bottom
                               anchors.topMargin: recDrumsMargin.height/ layoutInstruments.trennlinieDivident
                               anchors.leftMargin: recDrumsMargin.width/ layoutInstruments.marginDivident
                               anchors.rightMargin: recDrumsMargin.width/ layoutInstruments.marginDivident
                           }
                       }
                   }
               }
            }
        }
    }

/*/Next and previous Track
    Rectangle{
        id: previousTrack
        opacity: 0.2
        color: "red"
        width: 100
        height: parent.height
        MouseArea{
            id: mouseAreaPreviousTrack
            anchors.fill: parent
 //////////////////////////////////////////////////////////////////////
            hoverEnabled: true
            onEntered: {
                //an Felix: hier vlt ein Timer wie lange man auf den Bereich halten muss zum  vorherigen Track gewechselt wird
                if(timerProgressStatusBar.running == true && timerlaufendeZeit.running == true){
                    cutCurrentGoPreviousTrack = true
                    mediaPlayer.previousTrack();

                    //wenn pausiert und nextTrack gewählt wird, läuft dieser los
                }else if(timerProgressStatusBar.running == false && timerlaufendeZeit.running == false){
                    cutCurrentGoPreviousTrack = true
                    mediaPlayer.previousTrack()
                    songDuration = mediaPlayer.getDuration()
                    songName = mediaPlayer.getNameOfCurrentTrack();
                    songArtist = mediaPlayer.getArtistOfCurrentTrack();
                    visibleVoice = mediaPlayer.hasVoice();
                    visiblePiano = mediaPlayer.hasPiano();
                    visibleGuitar = mediaPlayer.hasGuitar();
                    visibleBass = mediaPlayer.hasBass();
                    visibleDrums = mediaPlayer.hasDrums();

                    mediaPlayer.start_pause()

                    timerProgressStatusBar.running = true
                    timerlaufendeZeit.running = true
                    imgPlay.opacity = 0
                    imgPause.opacity = 1
                }
            }
            onExited: {

            }

        }
    }

    Rectangle{
        id: nextTrack
        opacity: 0.2
        color: "red"
        width: 100
        height: parent.height
        anchors.right: parent.right
        MouseArea{
            id: mouseAreaNextTrack
            anchors.fill: parent            
    //////////////////////////////////////////////////////////////////////
            hoverEnabled: true
            onEntered: {
                //an Felix: hier vlt ein Timer wie lange man auf den Bereich halten muss zum  vorherigen Track gewechselt wird
                if(timerProgressStatusBar.running == true && timerlaufendeZeit.running == true){
                     cutCurrentGoNextTrack = true
                     mediaPlayer.nextTrack()

                    //wenn pausiert und nextTrack gewählt wird, läuft dieser los
                }else if(timerProgressStatusBar.running == false && timerlaufendeZeit.running == false){
                    cutCurrentGoPreviousTrack = true
                    mediaPlayer.previousTrack();
                    songDuration = mediaPlayer.getDuration();
                    songName = mediaPlayer.getNameOfCurrentTrack();
                    songArtist = mediaPlayer.getArtistOfCurrentTrack();
                    visibleVoice = mediaPlayer.hasVoice();
                    visiblePiano = mediaPlayer.hasPiano();
                    visibleGuitar = mediaPlayer.hasGuitar();
                    visibleBass = mediaPlayer.hasBass();
                    visibleDrums = mediaPlayer.hasDrums();

                    mediaPlayer.start_pause()
                    timerProgressStatusBar.running = true
                    timerlaufendeZeit.running = true
                    imgPlay.opacity = 0
                    imgPause.opacity = 1

                }

            }
            onExited: {

            }

        }
    }

*/
}

