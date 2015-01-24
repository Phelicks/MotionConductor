#include <QApplication>
#include <QQmlApplicationEngine>

#include <QQmlContext>
#include <QVariant>
#include <QtQml>

//#include <QDeclarativeView>
#include <QDeclarativePropertyMap>

#include "mediaplayer.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    MediaPlayer mediaPlayer;
    engine.rootContext()->setContextProperty("mediaPlayer", &mediaPlayer);   

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
