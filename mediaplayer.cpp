#include "mediaplayer.h"
#include "wiimote.h"
#include <QFileDialog>
#include <QDir>
#include <QMediaPlaylist>
#include <iostream>

/**
 * @brief MediaPlayer::MediaPlayer
 * Orientierung der Songs an der ersten Tonspur ("bass")
 */
MediaPlayer::MediaPlayer()
{
    QString path = "C:/Users/Phelicks/Desktop/WiiMote/AVPRG_MusicFiles/";
    playlist = new QMediaPlaylist();
    playlist->addMedia(QUrl::fromLocalFile(path + "Actions_DevilsWords_bass.mp3")); // Track 1
    playlist->addMedia(QUrl::fromLocalFile(path + "Andrew Cole - Dead Rosees_bass.mp3")); // Track 2
    playlist->addMedia(QUrl::fromLocalFile(path + "Butterfly Effect - An Ultraviolet Apology_bass.mp3")); // Track 3
    playlist->addMedia(QUrl::fromLocalFile(path + "James May - On The Line_bass.mp3")); // Track 4
    playlist->addMedia(QUrl::fromLocalFile(path + "Jay Menon - Through My Eyes_bass.mp3")); // Track 5
    playlist->addMedia(QUrl::fromLocalFile(path + "Jesper Buhl Trio - What Is This Thiing Called Love_bass.mp3")); // Track 6
    bass.setPlaylist(playlist);

    wiiInt = new wiiInterpreter();
    connect(wiiInt, SIGNAL(stateChanged()), this, SLOT(updateSelected()));
    connect(wiiInt, SIGNAL(stateChanged()), this, SLOT(updateMasterVolume()));
    connect(wiiInt, SIGNAL(stateChanged()), this, SLOT(updatePlayStatus()));
    connect(wiiInt, SIGNAL(stateChanged()), this, SLOT(updateSpeed()));
    connect(wiiInt, SIGNAL(statusMessage(QString)), this, SLOT(showStatus(QString)));

    timeNextPrev = new QElapsedTimer();
    timeSpeed = new QElapsedTimer();

    setVolume_bass(0);
    setVolume_drums(0);
    setVolume_guitar(0);
    setVolume_piano(0);
    setVolume_voice(0);
}

MediaPlayer::~MediaPlayer()
{
    delete wiiInt;
}

/**
 * @brief MediaPlayer::hasVoice
 * @return true if track has voice
 */
bool MediaPlayer::hasVoice()
{
    struct instrumentsArray instruments = multitrack.getInstruments();
    return instruments.instruments[0];
}

/**
 * @brief MediaPlayer::hasPiano
 * @return true if track has piano
 */
bool MediaPlayer::hasPiano()
{
    struct instrumentsArray instruments = multitrack.getInstruments();
    return instruments.instruments[1];
}

/**
 * @brief MediaPlayer::hasGuitar
 * @return true if track has guitar
 */
bool MediaPlayer::hasGuitar()
{
    struct instrumentsArray instruments = multitrack.getInstruments();
    return instruments.instruments[2];
}

/**
 * @brief MediaPlayer::hasBass
 * @return true if track has bass
 */
bool MediaPlayer::hasBass()
{
    struct instrumentsArray instruments = multitrack.getInstruments();
    return instruments.instruments[3];
}

/**
 * @brief MediaPlayer::hasDrums
 * @return drums
 */
bool MediaPlayer::hasDrums()
{
    struct instrumentsArray instruments = multitrack.getInstruments();
    return instruments.instruments[4];
}

QString MediaPlayer::getNameOfCurrentTrack()
{
    return multitrack.getTrackName();
}

QString MediaPlayer::getArtistOfCurrentTrack()
{
    return multitrack.getArtist();
}

int MediaPlayer::getDuration()
{
    int dur = bass.duration();

    return dur;
}

void MediaPlayer::playAllAudiotracks()
{
    multitrack.setMultitrackAudio(playlist->currentIndex(), drums, guitar, piano, voice);
}

/**
 * @brief MediaPlayer::start_pause
 * Start and pause
 */
void MediaPlayer::start_pause()
{
    // Startet immer bei Nummer 1 der Playlist
    if(bass.state()== QMediaPlayer::StoppedState){

        bass.play();
        playState = 1;

        multitrack.setMultitrackAudio(playlist->currentIndex(), drums, guitar, piano, voice);
        // Damit beim neuen Lied auch alle dazugehörigen Tracks abgespielt werden
        connect(playlist, SIGNAL(currentIndexChanged(int)), SLOT(playAllAudiotracks()));
        setVolume_bass(50);
        setVolume_drums(50);
        setVolume_guitar(50);
        setVolume_piano(50);
        setVolume_voice(50);

    }
    else if(bass.state()== QMediaPlayer::PlayingState){
        bass.pause();
        voice.pause();
        piano.pause();
        guitar.pause();
        drums.pause();
        playState = 2;
    }
    else if(bass.state() == QMediaPlayer::PausedState && bass.state()!= QMediaPlayer::StoppedState){
        struct instrumentsArray i = multitrack.getInstruments();
        if(i.instruments[0] == true) //voice
            voice.play();
        if(i.instruments[1] == true) //piano
            piano.play();
        if(i.instruments[2] == true) //guitar
            guitar.play();
        if(i.instruments[4] == true) //drums
            drums.play();
        bass.play();
        playState = 1;
    }

}

/**
 * @brief MediaPlayer::stop Stop all audiotracks
 */
void MediaPlayer::stop()
{
    bass.stop();
    drums.stop();
    guitar.stop();
    piano.stop();
    voice.stop();
}

/**
 * @brief MediaPlayer::setMasterVolume bekommt value und addiert
 * diesen auf die aktuelle value. Lautstärke kommt dabei nicht über
 * den Wert 100 und Tonspuren, die stumm geschaltet, d.h. auf 0
 * gesetzt sind, werden nicht mit angehoben.
 *
 * @param value
 */
void MediaPlayer::setMasterVolume(int value)
{
    if((volArray.volumes[0] + value) > 100){ setVolume_bass(100); }
    else if (volArray.volumes[0]+ value < 0){ setVolume_bass(0); }
    else if (volArray.volumes[0] > 0){ setVolume_bass(volArray.volumes[0] + value);}

    if((volArray.volumes[1] + value) > 100){ setVolume_drums(100); }
    else if (volArray.volumes[1]+ value < 0){ setVolume_drums(0); }
    else if (volArray.volumes[1] > 0){  setVolume_drums(volArray.volumes[1] + value); }

    if((volArray.volumes[2] + value) > 100){ setVolume_guitar(100); }
    else if (volArray.volumes[2]+ value < 0){ setVolume_guitar(0); }
    else if (volArray.volumes[2] > 0){  setVolume_guitar(volArray.volumes[2] + value); }

    if((volArray.volumes[3] + value) > 100){ setVolume_piano(100); }
    else if (volArray.volumes[3]+ value < 0){ setVolume_piano(0); }
    else if (volArray.volumes[3] > 0){  setVolume_piano(volArray.volumes[3] + value); }

    if((volArray.volumes[4] + value) > 100){ setVolume_voice(100); }
    else if (volArray.volumes[4]+ value < 0){ setVolume_voice(0); }
    else if (volArray.volumes[4] > 0){  setVolume_voice(volArray.volumes[4] + value); }
}

void MediaPlayer::previousTrack()
{

    if(bass.state() == QMediaPlayer::PausedState || bass.state()== QMediaPlayer::StoppedState)
    {
        start_pause();
    }
    playState = 3;
    playStatus = true;

    if(playlist->currentIndex() == 0){
        playlist->setCurrentIndex(playlist->mediaCount()-1);
    }
    else{
        playlist->previous();
    }
    setVolume_bass(50);
    setVolume_drums(50);
    setVolume_guitar(50);
    setVolume_piano(50);
    setVolume_voice(50);
}

void MediaPlayer::nextTrack()
{
    if(bass.state() == QMediaPlayer::PausedState || bass.state()== QMediaPlayer::StoppedState)
    {
        start_pause();
    }
    playState = 3;
    playStatus = true;

    if(playlist->currentIndex() == playlist->mediaCount()-1){
        playlist->setCurrentIndex(0);
    }
    else{
        playlist->next();
    }
    setVolume_bass(50);
    setVolume_drums(50);
    setVolume_guitar(50);
    setVolume_piano(50);
    setVolume_voice(50);
}

/**
 * @brief MediaPlayer::setPlaybackRate
 * PlaybackRate: By default this value is 1.0
 * Higher than 1.0: increase rate of play
 * Less than 0: media will rewind!
 *
 * @param value
 */
void MediaPlayer::setPlaybackRate(float value)
{

    //qreal value = valueF * 2.0;
    bass.setPlaybackRate(value);
    drums.setPlaybackRate(value);
    guitar.setPlaybackRate(value);
    piano.setPlaybackRate(value);
    voice.setPlaybackRate(value);
    playbackRate = value;
}

/**
 * @brief MediaPlayer::resetPlaybackRate
 * Playback rate of the original track.
 */
void MediaPlayer::resetPlaybackRate()
{
    bass.setPlaybackRate(1.0);
    drums.setPlaybackRate(1.0);
    guitar.setPlaybackRate(1.0);
    piano.setPlaybackRate(1.0);
    voice.setPlaybackRate(1.0);
}

void MediaPlayer::setVolume_bass(int value)
{
    bass.setVolume(value);
    volArray.volumes[0] = value;
}

void MediaPlayer::setVolume_drums(int value)
{
    drums.setVolume(value);
    volArray.volumes[1] = value;
}

void MediaPlayer::setVolume_guitar(int value)
{
    guitar.setVolume(value);
    volArray.volumes[2] = value;
}

void MediaPlayer::setVolume_piano(int value)
{
    piano.setVolume(value);
    volArray.volumes[3] = value;
}

void MediaPlayer::setVolume_voice(int value)
{
    voice.setVolume(value);
    volArray.volumes[4] = value;
}

void MediaPlayer::showStatus(QString message)
{
    //ui->statusBar->showMessage(message, 2000);
    qDebug() << message;
}

int MediaPlayer::getMasterVolume()
{
    return 100-(wiiInt->getValue(wiiInt->m_wiimote->Acceleration.Y, -0.5, 0.5, 100));
}

int MediaPlayer::getArrayVolume(int i)
{
    return min(100, max(0, volArray.volumes[i]));
}

float MediaPlayer::getSpeed()
{
    float p = wiiInt->getValue(wiiInt->m_wiimote->Acceleration.X, -1.0, 1.0, 1.0);
    //int h = p*10.0;
    //qDebug() << h/10.0;
    return p;
}

void MediaPlayer::updateSelected()
{
    if(isAPressed() || bass.state()== QMediaPlayer::StoppedState)return;

    //Count the number of Tracks
    int trackCount = 0; // start with 2 for prev and next
    if(hasVoice())  trackCount++;
    if(hasPiano())  trackCount++;
    if(hasGuitar()) trackCount++;
    if(hasBass())   trackCount++;
    if(hasDrums())  trackCount++;

    //get selected track
    float degrees = 90.0;
    float degPerTrack = degrees/trackCount;
    float currentDeg = wiiInt->degrees;
    int selectedTrack = min((trackCount-1), max(0, (currentDeg+degrees/2)/degPerTrack));

    //Voice
    if(selectedTrack == 0 && hasVoice())
    {
        selected = 1;
        selectedTrack = -1;
    }
    else if(hasVoice())
    {
        selectedTrack--;
    }

    //Piano
    if(selectedTrack == 0 && hasPiano())
    {
        selected = 2;
        selectedTrack = -1;
    }
    else if(hasPiano())
    {
        selectedTrack--;
    }

    //Guitar
    if(selectedTrack == 0 && hasGuitar())
    {
        selected = 4;
        selectedTrack = -1;
    }
    else if(hasGuitar())
    {
        selectedTrack--;
    }

    //Bass
    if(selectedTrack == 0 && hasBass())
    {
        selected = 8;
        selectedTrack = -1;
    }
    else if(hasBass())
    {
        selectedTrack--;
    }

    //Drums
    if(selectedTrack == 0 && hasDrums())
    {
        selected = 16;
        selectedTrack = -1;
    }
    else if(hasDrums())
    {
        selectedTrack--;
    }

    //Next and Previous
    if(currentDeg < -90 || currentDeg > 90)
    {
        if(!isOnNextPrev){
            timeNextPrev->start();
            //qDebug() << "Timer started";
        }
        else
        {
            int elapsed = timeNextPrev->elapsed();
            if(elapsed > 1000 && elapsed < 1200)
            {
                wiiInt->m_wiimote->SetRumble(true);
            }
            else if(elapsed > 1500 && elapsed < 1700)
            {
                wiiInt->m_wiimote->SetRumble(true);
            }
            else if(elapsed > 2000 && elapsed < 2200)
            {
                wiiInt->m_wiimote->SetRumble(true);
            }
            else if(elapsed > 2200 && !nextSelected)
            {
                if(currentDeg > 0) nextTrack();
                else previousTrack();
                nextSelected = true;
            }
            else
            {
                wiiInt->m_wiimote->SetRumble(false);
            }
        }
        selected = 0;
        isOnNextPrev = true;
    }
    else
    {
        if(isOnNextPrev)wiiInt->m_wiimote->SetRumble(false);
        nextSelected = false;
        isOnNextPrev = false;
    }

}

void MediaPlayer::updateMasterVolume()
{
    if(wiiInt->m_wiimote->Button.A())return;
    float acc = -wiiInt->m_wiimote->Acceleration.Y;
    if(acc > 0.8)
    {
        setMasterVolume(1);
    }

    if(acc < -0.8)
    {
        setMasterVolume(-1);
    }
}

void MediaPlayer::updatePlayStatus()
{
    if(wiiInt->m_wiimote->Button.B())
    {
        if(!playStatus)
        {
            start_pause();
        }
        playStatus = true;
    }
    else
    {
        playStatus = false;
    }
}

void MediaPlayer::updateSpeed()
{
    if(getSpeed() < 0.2 || getSpeed() > 0.8)
    {
        if(!speedStarted)
        {
            timeSpeed->start();
            speedStarted = true;
        }
        if(timeSpeed->elapsed() > 1000)
        {
            if(!speedSet)
            {
                if(getSpeed() > 0.5)setPlaybackRate(2);
                else setPlaybackRate(0.5);
                speedSet = true;
            }
        }
    }
    else
    {
        if(speedSet)
        {
            setPlaybackRate(1);
        }

        speedStarted = false;
        speedSet = false;
    }
}

int MediaPlayer::stateChanged()
{
    if(playState != 0){
        int s = playState;
        playState = 0;
        //qDebug() << "state: " << s;
        return s;
    }
    return 0;
}

int MediaPlayer::getAverageVolume()
{
    int avg = 0;
    int c = 0;

    for(int i=0; i < 5; i++)
    {
        if(volArray.volumes[i] > 0)
        {
            avg += volArray.volumes[i];
            c++;
        }
    }
    if(c == 0)return 0;
    return max(0, min(100, avg/c));
}

bool MediaPlayer::isVoiceSelected()
{
    return selected & 0x01;
}

bool MediaPlayer::isPianoSelected()
{
    return selected & 0x02;
}

bool MediaPlayer::isGuitarSelected()
{
    return selected & 0x04;
}

bool MediaPlayer::isBassSelected()
{
    return selected & 0x08;
}

bool MediaPlayer::isDrumsSelected()
{
    return selected & 0x10;
}

bool MediaPlayer::isAPressed()
{
    return wiiInt->m_wiimote->Button.A();
}

float MediaPlayer::getPlaybackRate()
{
    return playbackRate;
}
