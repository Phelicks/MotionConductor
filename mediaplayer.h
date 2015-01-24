#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include "audioTracks.h"
#include "wiiinterpreter.h"
#include <QMainWindow>
#include <QMediaPlayer>
#include <QMetaType>
#include <QElapsedTimer>

#include <QObject>

struct volumeArray{ int volumes[5]; }; // 0: bass, 1: drums, 2: guitar, 3: piano, 4: voice

class MediaPlayer: public QObject
{
    Q_OBJECT

public:
    explicit MediaPlayer();
    ~MediaPlayer();

public slots:

    int getDuration();
    bool hasVoice();
    bool hasPiano();
    bool hasBass();
    bool hasGuitar();
    bool hasDrums();
    void playAllAudiotracks();
    QString getNameOfCurrentTrack();
    QString getArtistOfCurrentTrack();
    void start_pause();
    void stop();
    void setMasterVolume(int value);
    void previousTrack();
    void nextTrack();
    void setPlaybackRate(float value);
    void resetPlaybackRate();
    void setVolume_bass(int value);
    void setVolume_drums(int value);
    void setVolume_guitar(int value);
    void setVolume_piano(int value);
    void setVolume_voice(int value);
    int getMasterVolume();
    int getArrayVolume(int i);
    float getSpeed();
    bool isVoiceSelected();
    bool isPianoSelected();
    bool isBassSelected();
    bool isGuitarSelected();
    bool isDrumsSelected();
    bool isAPressed();
    int stateChanged();
    float getPlaybackRate();

private slots:
    void updateSelected();
    void updateMasterVolume();
    void updatePlayStatus();
    void updateSpeed();
    void showStatus(QString message);

private:
    QMediaPlayer bass;
    QMediaPlayer drums;
    QMediaPlayer guitar;
    QMediaPlayer piano;
    QMediaPlayer voice;
    struct volumeArray volArray;
    QMediaPlaylist* playlist;
    AudioTracks multitrack;
    long long timerDuration;
    long long timerTrueForAWhile;
    wiiInterpreter *wiiInt;
    int selected = 0;
    QElapsedTimer *timeNextPrev;
    bool isOnNextPrev = false;
    bool nextSelected = false;
    bool playStatus = false;
    int playState = 0;
    QElapsedTimer *timeSpeed;
    bool speedStarted = false;
    bool speedSet = false;
    float playbackRate = 1.0;
};

#endif // MEDIAPLAYER_H
