#ifndef AUDIOTRACKS_H
#define AUDIOTRACKS_H
#include <QMediaPlayer>
#include <string>
using namespace std;

struct instrumentsArray{ bool instruments[5]; };

class AudioTracks
{
public:
    AudioTracks();
    void setMultitrackAudio(int currentIndex,
                            QMediaPlayer & drums,
                            QMediaPlayer & guitar,
                            QMediaPlayer & piano,
                            QMediaPlayer & voice);
    void setInstruments(bool voice, bool piano,
                        bool guitar, bool bass, bool drums);
    void setArtist(QString artist);
    void setTrackName(QString track);
    QString getArtist();
    QString getTrackName();
    struct instrumentsArray getInstruments();

private:
    QString artistName;
    QString trackName;
    struct instrumentsArray i;
    QString path = "./MusicFiles/";
};

#endif // AUDIOTRACKS_H




