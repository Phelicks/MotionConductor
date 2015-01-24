#ifndef WIIINTERPRETER_H
#define WIIINTERPRETER_H

#include <QMainWindow>
#include <QDebug>
#include "wiimote.h"
#include "wiimote_state.h"

class wiiInterpreter : public QWidget
{
    Q_OBJECT
public:
    wiiInterpreter();
    ~wiiInterpreter();
    wiimote *m_wiimote = 0;
    double degrees = 0;
    int getVolume();
    float getValue(float in, float minV, float maxV, float maxOut);
signals:
    void stateChanged();
    void statusMessage(QString message);
private:
    void wiiLoop();
    void log(QString m);
    bool connectWii(unsigned wiimote_index, bool force_hidwrites);
    int mode=0;
    bool modePressed = false;
    double averageOffset=0;
};

#endif // WIIINTERPRETER_H
