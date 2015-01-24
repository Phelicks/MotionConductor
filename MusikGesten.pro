TEMPLATE = app

QT += qml quick widgets
QT += core gui multimedia
QT += core gui declarative
QT += qml
QT += core




SOURCES += main.cpp \
    wiiinterpreter.cpp \
    wiimote.cpp \
    audioTracks.cpp \
    mediaplayer.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    wiimote_common.h \
    wiimote_state.h \
    wiimote.h \
    wiiinterpreter.h \
    audioTracks.h \
    mediaplayer.h
