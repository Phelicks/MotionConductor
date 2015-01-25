#include "wiiinterpreter.h"
#include <thread>

wiiInterpreter::wiiInterpreter()
{
    int maxAttempts = 100;
    int connectionAttempts = 0;
    bool success = false;

    do
    {
        success = connectWii(0xFFFFFFFF, false);
    }
    while (success == false && connectionAttempts++ < maxAttempts);

    if(success)
    {
        m_wiimote->SetLEDs(0x0F);

        std::thread test (&wiiInterpreter::wiiLoop, this);
        test.detach();
    }
    else
    {
        m_wiimote = 0;
        qDebug() << "no wiimote found";
    }
}

wiiInterpreter::~wiiInterpreter()
{
    if(m_wiimote != 0)m_wiimote->SetLEDs(0x00);
    delete m_wiimote;
}

void wiiInterpreter::wiiLoop()
{
    Sleep(1000);
    log("starting wiiLoop...");

    //Wait for MotionPlus
    log("wating for MotionPlus...");
    while(!m_wiimote->MotionPlusEnabled())Sleep(1);
    log("found MotionPlus!");
    Sleep(2000);

    //MotionPlus Calibration
    log("start calibration now...");
    m_wiimote->SetLEDs(0x09);
    int i=0;
    averageOffset = m_wiimote->MotionPlus.Speed.Yaw;
    while(i<200)
    {
        averageOffset += m_wiimote->MotionPlus.Speed.Yaw;
        averageOffset /= 2;
        i++;
        while(m_wiimote->RefreshState() == NO_CHANGE)Sleep(1);
    }
    log("average offset: " + QString::number(averageOffset));
    log("IR Mode: " + QString::number(m_wiimote->IR.Mode)); //<< " (OFF:" << m_wiimote->IR.OFF<< " BASIC:" << m_wiimote->IR.BASIC<< " EXTENDED:" << m_wiimote->IR.EXTENDED<<")";
    m_wiimote->SetLEDs(0x0F);

    //Main loop
    while(true)
    {

        //Check Button Input
        m_wiimote->SetRumble(m_wiimote->Button.One());
        if(m_wiimote->Button.Minus())degrees = 0;

        //Check Mode
        if(m_wiimote->Button.Plus() && !modePressed)
        {
            mode++;
            mode = mode%4;
            log(QString::number(mode));
            modePressed = true;
            if(mode == 0)m_wiimote->SetLEDs(0x01);
            if(mode == 1)m_wiimote->SetLEDs(0x02);
            if(mode == 2)m_wiimote->SetLEDs(0x04);
            if(mode == 3)m_wiimote->SetLEDs(0x08);
        }
        else if(!m_wiimote->Button.Plus())
        {
            modePressed = false;
        }

        //Check IR Input
        float dotX = 0;
        bool multiplePoints = false;
        for(int index=0; index<4; index++)
        {
            if(m_wiimote->IR.Dot[index].X != 0 && m_wiimote->IR.Dot[index].bVisible)
            {
                if(dotX != 0)
                {
                    multiplePoints = true;
                }
                else
                {
                    dotX = m_wiimote->IR.Dot[index].X;
                }
            }
        }

        if(multiplePoints)
        {
           log("More than one point");
        }
        else if(dotX > 0.4 && dotX < 0.6)
        {
           degrees = 0;
           if(mode == 3)m_wiimote->SetRumble(true);
           log("Reset");
        }

        //Calculate Degrees
        double m = (m_wiimote->MotionPlus.Speed.Yaw-averageOffset)*0.01;//3.14159265358979323846f/360.0; //*(2000/440);//Movement (timer.nsecsElapsed()/(50000.0)
        if(abs(m) < 0.002){
            averageOffset += m_wiimote->MotionPlus.Speed.Yaw;
            averageOffset /= 2;
        }
        degrees += m;

        //notify main window and wait
        emit stateChanged();
        while(m_wiimote->RefreshState() == NO_CHANGE)Sleep(1);
    }
}

void on_state_change (wiimote			  &remote,
                      state_change_flags  changed,
                      const wiimote_state &new_state)
{
    // NOTE: don't access the public state from the 'remote' object here, as it will
    //		  be out-of-date (it's only updated via RefreshState() calls, and these
    //		  are reserved for the main application so it can be sure the values
    //		  stay consistent between calls).  Instead query 'new_state' only.

    // the wiimote just connected
    if (changed & CONNECTED)
    {
        if (new_state.ExtensionType != wiimote::BALANCE_BOARD)
        {
            if (new_state.bExtension)
                remote.SetReportType(wiimote::IN_BUTTONS_ACCEL_IR_EXT); // no IR dots
            else
                remote.SetReportType(wiimote::IN_BUTTONS_ACCEL_IR);		//    IR dots
        }
    }
    // a MotionPlus was detected
    if (changed & MOTIONPLUS_DETECTED)
    {
        // enable it if there isn't a normal extension plugged into it
        // (MotionPlus devices don't report like normal extensions until
        //  enabled - and then, other extensions attached to it will no longer be
        //  reported (so disable the M+ when you want to access them again).
        if (remote.ExtensionType == wiimote_state::NONE) {
            bool res = remote.EnableMotionPlus();
            _ASSERT(res);
        }
    }
    // an extension is connected to the MotionPlus
    else if (changed & MOTIONPLUS_EXTENSION_CONNECTED)
    {
        // We can't read it if the MotionPlus is currently enabled, so disable it:
        if (remote.MotionPlusEnabled())
            remote.DisableMotionPlus();
    }
    // an extension disconnected from the MotionPlus
    else if (changed & MOTIONPLUS_EXTENSION_DISCONNECTED)
    {
        // enable the MotionPlus data again:
        if (remote.MotionPlusConnected())
            remote.EnableMotionPlus();
    }
    // another extension was just connected:
    else if (changed & EXTENSION_CONNECTED)
    {
        // switch to a report mode that includes the extension data (we will
        //  loose the IR dot sizes)
        // note: there is no need to set report types for a Balance Board.
        if (!remote.IsBalanceBoard())
            remote.SetReportType(wiimote::IN_BUTTONS_ACCEL_IR_EXT);
    }
    // extension was just disconnected:
    else if (changed & EXTENSION_DISCONNECTED)
    {
        //test = false;
        // use a non-extension report mode (this gives us back the IR dot sizes)
        remote.SetReportType(wiimote::IN_BUTTONS_ACCEL_IR);
    }
}

bool wiiInterpreter::connectWii(unsigned wiimote_index, bool force_hidwrites)
{
    if(m_wiimote == 0)
    {
        m_wiimote = new wiimote();
        m_wiimote->ChangedCallback = on_state_change;
        m_wiimote->CallbackTriggerFlags = (state_change_flags)(CONNECTED | EXTENSION_CHANGED | MOTIONPLUS_CHANGED);
    }
    return m_wiimote->Connect(wiimote_index, force_hidwrites);
}

void wiiInterpreter::log(QString m)
{
    emit statusMessage(m);
}

int wiiInterpreter::getVolume()
{
    float min = -90.0;
    float max = 90.0;
    int value = 100;
    float volume = m_wiimote->Acceleration.Orientation.Pitch;
    float p = min(1.0, max(0.0, (volume-min)/(max-min)));
    return value*p;
}

float wiiInterpreter::getValue(float in, float minV, float maxV, float maxOut)
{
    float p = min(1.0, max(0.0, (in-minV)/(maxV-minV)));
    return maxOut*p;
}
