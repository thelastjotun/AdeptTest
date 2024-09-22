#pragma once

#include <QFile>
#include <QHttpServer>
#include <QMutex>
#include <QObject>
#include <QPair>
#include <QSslConfiguration>
#include <QSslKey>
#include <QTimer>
#include <QUrl>
#include <QUrlQuery>

#include "../DataBase/QueryExecutor.h"

class AdeptServer : public QObject
{
    Q_OBJECT
public:
    explicit AdeptServer(QObject *parent = nullptr);

    ///
    /// \brief getServerPort - Функция возвращает значение полученного объекта. Геттер для переменной m_serverPort.
    /// \return Возвращает данные записанные в переменную m_serverPort в формате числа.
    ///
    [[nodiscard]] quint16 getServerPort();

    ///
    /// \brief setServerPort - Функция устанавливает значение полученного объекта. Сеттер для переменной m_serverPort.
    /// \param newServerPort - Данные которые нужно установить в m_serverPort в формате числа.
    ///
    void setServerPort(const quint16 &serverPort);

public slots:
    ///
    /// \brief Запускает сервер и отправляет сигнал о старте работы сервера.
    ///
    void startServer();

signals:
    void serverStarted();

    void allObjectsChanged(QJsonDocument);

    void byDateChanged(QJsonDocument);

    void byDistanceChanged(QJsonDocument);

    void byFirstLetterChanged(QJsonDocument);

    void byTypeChanged(QJsonDocument);

private:
    QHash< QString, QString > getQueryParametersFromRequest(const QHttpServerRequest &request);

private:
    QHttpServer m_server;

    QueryExecutor m_queryExecutor;

    quint16 m_serverPort = 8080;
};
