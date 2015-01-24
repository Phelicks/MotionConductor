#include "audioTracks.h"
#include <QMediaPlaylist>
#include <QFileDialog>
#include <QDir>
#include <QMediaPlayer>

/**
 * @brief AudioTracks::AudioTracks
 * Orientierung der Songs an der ersten Tonspur ("audioTrack1")
 */
AudioTracks::AudioTracks()
{
}

void AudioTracks::setInstruments(bool voice, bool piano,
                                 bool guitar, bool bass, bool drums)
{
    i.instruments[0] = voice;
    i.instruments[1] = piano;
    i.instruments[2] = guitar;
    i.instruments[3] = bass;
    i.instruments[4] = drums;
}

void AudioTracks::setArtist(QString artist)
{
    artistName = artist;
}

void AudioTracks::setTrackName(QString track)
{
    trackName = track;
}

QString AudioTracks::getArtist()
{
    return artistName;
}

QString AudioTracks::getTrackName()
{
    return trackName;
}

struct instrumentsArray AudioTracks::getInstruments()
{
    return i;
}

/**
 * @brief AudioTracks::setMultitrackAudio
 * Spielt die zu dem ausgewählten Musikstück
 * passenden Tonspuren ab.
 *
 * @param currentIndex Index des aktuellen Musikstücks
 * @param audioTrack2 etc. Tonspuren, die zu audioTrack1 gehören
 */
void AudioTracks::setMultitrackAudio(int currentIndex,
                                QMediaPlayer & drums,
                                QMediaPlayer & guitar,
                                QMediaPlayer & piano,
                                QMediaPlayer & voice){
    //Das erste Musikstück aus der Playlist
    if(currentIndex == 0){
       drums.setMedia(QUrl(path + "Actions_DevilsWords_drums.mp3")); //drums
       guitar.setMedia(QUrl(path + "Actions_DevilsWords_guitar.mp3")); //guitar
       voice.setMedia(QUrl(path + "Actions_DevilsWords_voice.mp3")); //voice
       piano.stop();
       setInstruments(true, false, true, true, true);
       setArtist("Actions");
       setTrackName("Devils Words");
     }
     else if(currentIndex == 1){
        drums.setMedia(QUrl(path + "Andrew Cole - Dead Rosees_drums.mp3"));
        guitar.setMedia(QUrl(path + "Andrew Cole - Dead Rosees_guitar.mp3"));
        piano.setMedia(QUrl(path + "Andrew Cole - Dead Rosees_piano.mp3"));
        voice.setMedia(QUrl(path + "Andrew Cole - Dead Rosees_voice.mp3"));
        setInstruments(true, true, true, true, true);
        setArtist("Andrew Cole");
        setTrackName("Dead Roses");
     }
     else if(currentIndex == 2){
        drums.setMedia(QUrl(path + "Butterfly Effect - An Ultraviolet Apology_drums.mp3"));
        guitar.setMedia(QUrl(path + "Butterfly Effect - An Ultraviolet Apology_guitar.mp3"));
        voice.setMedia(QUrl(path + "Butterfly Effect - An Ultraviolet Apology_voice.mp3"));
        piano.stop();
        setInstruments(true, false, true, true, true);
        setArtist("Butterfly Effect");
        setTrackName("An Ultraviolet Apology");
    }
    else if(currentIndex == 3){
        drums.setMedia(QUrl(path + "James May - On The Line_drums.mp3"));
        guitar.setMedia(QUrl(path + "James May - On The Line_guitar.mp3"));
        voice.setMedia(QUrl(path + "James May - On The Line_voices.mp3"));
        piano.stop();
        setInstruments(true, false, true, true, true);
        setArtist("James May");
        setTrackName("On The Line");
    }
    else if(currentIndex == 4){
        drums.setMedia(QUrl(path + "Jay Menon - Through My Eyes_drums.mp3"));
        guitar.setMedia(QUrl(path + "Jay Menon - Through My Eyes_guitars.mp3"));
        piano.setMedia(QUrl(path + "Jay Menon - Through My Eyes_piano and synth.mp3"));
        voice.setMedia(QUrl(path + "Jay Menon - Through My Eyes_vioce.mp3"));
        setInstruments(true, true, true, true, true);
        setArtist("Jay Menon");
        setTrackName("Through My Eyes");
    }
    else if(currentIndex == 5){
        drums.setMedia(QUrl(path + "Jesper Buhl Trio - What Is This Thiing Called Love_drums.mp3"));
        piano.setMedia(QUrl(path + "Jesper Buhl Trio - What Is This Thiing Called Love_piano.mp3"));
        voice.stop();
        guitar.stop();
        setInstruments(false, true, false, true, true);
        setArtist("Jesper Buhl Trio");
        setTrackName("What Is This Thing Called Love");
    }

    if(i.instruments[0] == true) //voice
        voice.play();
    if(i.instruments[1] == true) //piano
        piano.play();
    if(i.instruments[2] == true) //guitar
        guitar.play();
    if(i.instruments[4] == true) //drums
        drums.play();
    }
