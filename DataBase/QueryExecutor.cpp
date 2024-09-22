#include "QueryExecutor.h"
#include <qpoint.h>

#include "DBManager.h"

QueryExecutor::QueryExecutor(QObject *parent)
    : QObject{ parent }
{
    QSettings settings("/home/thelastjotun/Projects/AdeptTestWidgets/DataBase/config", QSettings::IniFormat);
    m_database = QSqlDatabase::addDatabase(settings.value(m_databaseSettingsGroup % "driver").toString());
    m_database.setHostName(settings.value(m_databaseSettingsGroup % "hostName").toString());
    m_database.setDatabaseName(settings.value(m_databaseSettingsGroup % "dataBaseName").toString());
    m_database.setUserName(settings.value(m_databaseSettingsGroup % "userName").toString());
    m_database.setPassword(settings.value(m_databaseSettingsGroup % "password").toString());
    m_database.setPort(settings.value(m_databaseSettingsGroup % "port").toUInt());

    /* Проверяем соединение с базой данных */
    if (m_database.open()) {
        qDebug() << Q_FUNC_INFO << "Successfully connected to the database";
    } else {
        qDebug() << Q_FUNC_INFO << "Database failed to open in init with error: " % m_database.lastError().text();
    }
}

QJsonDocument QueryExecutor::getAllObjects()
{
    QJsonArray resultArray;

    {
        QSqlQuery query(DBManager::databaseConnect(m_database));

        if (query.prepare("SELECT * FROM objects")) {
            if (query.exec()) {
                QJsonObject obj;

                while (query.next()) {
                    obj.insert("id", query.value(0).toInt());
                    obj.insert("name", query.value(1).toString());
                    obj.insert("coord1", query.value(2).toInt());
                    obj.insert("coor2", query.value(3).toInt());
                    obj.insert("type", query.value(4).toString());
                    obj.insert("creationTime", query.value(5).toInt());
                    resultArray.append(obj);
                }
            } else {
                qDebug() << Q_FUNC_INFO << "SQL query execution: " % query.lastError().text();
            }
        } else {
            qDebug() << Q_FUNC_INFO << "SQL query preparation: " % query.lastError().text();
        }
    }

    DBManager::databaseDisconnect(QThread::currentThread());

    return QJsonDocument{ resultArray };
}

QJsonDocument QueryExecutor::getSortedGroupByFirstLetter()
{
    QJsonArray resultArray;

    {
        QSqlQuery query(DBManager::databaseConnect(m_database));

        if (query.prepare("SELECT getSortedGroupByFirstLetter()")) {
            if (query.exec()) {
                QJsonObject obj;

                while (query.next()) {
                    obj.insert("group", query.value(0).toString());

                    resultArray.append(obj);
                }
            } else {
                qDebug() << Q_FUNC_INFO << "SQL query execution: " % query.lastError().text();
            }
        } else {
            qDebug() << Q_FUNC_INFO << "SQL query preparation: " % query.lastError().text();
        }
    }

    DBManager::databaseDisconnect(QThread::currentThread());

    return QJsonDocument{ resultArray };
}

QJsonDocument QueryExecutor::getSortedGroupByTypeCount(const quint16 &N)
{
    QJsonArray resultArray;

    {
        QSqlQuery query(DBManager::databaseConnect(m_database));

        if (query.prepare(QString("SELECT getSortedGroupByTypeCount(%1)").arg(N))) {
            if (query.exec()) {
                QJsonObject obj;

                while (query.next()) {
                    obj.insert("group", query.value(0).toString());

                    resultArray.append(obj);
                }
            } else {
                qDebug() << Q_FUNC_INFO << "SQL query execution: " % query.lastError().text();
            }
        } else {
            qDebug() << Q_FUNC_INFO << "SQL query preparation: " % query.lastError().text();
        }
    }

    DBManager::databaseDisconnect(QThread::currentThread());

    return QJsonDocument{ resultArray };
}

QJsonDocument QueryExecutor::getSortedGroupByDistance()
{
    QJsonArray resultArray;

    {
        QSqlQuery query(DBManager::databaseConnect(m_database));

        if (query.prepare("SELECT getSortedGroupByDistance()")) {
            if (query.exec()) {
                QJsonObject obj;

                while (query.next()) {
                    obj.insert("group", query.value(0).toString());

                    resultArray.append(obj);
                }
            } else {
                qDebug() << Q_FUNC_INFO << "SQL query execution: " % query.lastError().text();
            }
        } else {
            qDebug() << Q_FUNC_INFO << "SQL query preparation: " % query.lastError().text();
        }
    }

    DBManager::databaseDisconnect(QThread::currentThread());

    return QJsonDocument{ resultArray };
}

QJsonDocument QueryExecutor::getSortedGroupByDate()
{
    QJsonArray resultArray;

    {
        QSqlQuery query(DBManager::databaseConnect(m_database));

        if (query.prepare("SELECT getSortedGroupByDate()")) {
            if (query.exec()) {
                QJsonObject obj;

                while (query.next()) {
                    obj.insert("group", query.value(0).toString());

                    resultArray.append(obj);
                }
            } else {
                qDebug() << Q_FUNC_INFO << "SQL query execution: " % query.lastError().text();
            }
        } else {
            qDebug() << Q_FUNC_INFO << "SQL query preparation: " % query.lastError().text();
        }
    }

    DBManager::databaseDisconnect(QThread::currentThread());

    return QJsonDocument{ resultArray };
}
