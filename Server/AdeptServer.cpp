#include "AdeptServer.h"
#include <QDebug>

AdeptServer::AdeptServer(QObject *parent)
    : QObject{ parent }
{
    m_server.route("/allObjects", QHttpServerRequest::Method::Get, [&](const QHttpServerRequest &request) {
        QJsonDocument responseObject = m_queryExecutor.getAllObjects();

        if (responseObject.isEmpty())
            return QHttpServerResponse("text/plain", "Упс! Что-то пошло не так...");

        emit allObjectsChanged(responseObject);
        return QHttpServerResponse("application/json", responseObject.toJson(QJsonDocument::Compact));
    });

    m_server.route("/byType", QHttpServerRequest::Method::Get, [&](const QHttpServerRequest &request) {
        /* Достаём значения параметров из запроса. */
        QHash< QString, QString > parameters = getQueryParametersFromRequest(request);

        if (!parameters["N"].isEmpty()) {
            QJsonDocument responseObject = m_queryExecutor.getSortedGroupByTypeCount(parameters["N"].toInt());

            if (!responseObject.isEmpty()) {
                emit byTypeChanged(responseObject);
                return QHttpServerResponse("application/json", responseObject.toJson(QJsonDocument::Compact));
            }
        } else {
            return QHttpServerResponse("text/plain", "Неправильно указан параметр!");
        }

        return QHttpServerResponse("text/plain", "Упс! Что-то пошло не так...");
    });

    m_server.route("/byFirstLetter", QHttpServerRequest::Method::Get, [&](const QHttpServerRequest &request) {
        QJsonDocument responseObject = m_queryExecutor.getSortedGroupByFirstLetter();

        if (responseObject.isEmpty())
            return QHttpServerResponse("text/plain", "Упс! Что-то пошло не так...");

        emit byFirstLetterChanged(responseObject);
        return QHttpServerResponse("application/json", responseObject.toJson(QJsonDocument::Compact));
    });

    m_server.route("/byDistance", QHttpServerRequest::Method::Get, [&](const QHttpServerRequest &request) {
        QJsonDocument responseObject = m_queryExecutor.getSortedGroupByDistance();

        if (responseObject.isEmpty())
            return QHttpServerResponse("text/plain", "Упс! Что-то пошло не так...");

        emit byDistanceChanged(responseObject);
        return QHttpServerResponse("application/json", responseObject.toJson(QJsonDocument::Compact));
    });

    m_server.route("/byDate", QHttpServerRequest::Method::Get, [&](const QHttpServerRequest &request) {
        QJsonDocument responseObject = m_queryExecutor.getSortedGroupByDate();

        if (responseObject.isEmpty())
            return QHttpServerResponse("text/plain", "Упс! Что-то пошло не так...");

        emit byDateChanged(responseObject);
        return QHttpServerResponse("application/json", responseObject.toJson(QJsonDocument::Compact));
    });
}

quint16 AdeptServer::getServerPort()
{
    return m_serverPort;
}

void AdeptServer::setServerPort(const quint16 &serverPort)
{
    m_serverPort = serverPort;
}

void AdeptServer::startServer()
{
    if (m_server.listen(QHostAddress::Any, m_serverPort) == m_serverPort) {
        qDebug() << QString("Server started on port: %1").arg(m_serverPort);

        emit serverStarted();
    } else {
        qDebug() << QString("Server not started!");
    }
}

QHash< QString, QString > AdeptServer::getQueryParametersFromRequest(const QHttpServerRequest &request)
{
    QUrlQuery queryParameters(request.query());

    QHash< QString, QString > parameters;
    for (const std::pair< QString, QString > &item : queryParameters.queryItems()) {
        parameters[item.first] = QUrl(item.second).path();
    }

    return parameters;
}
