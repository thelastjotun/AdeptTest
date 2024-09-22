#pragma once

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QSettings>
#include <QSqlError>
#include <QSqlQuery>
#include <QStringBuilder>

class QueryExecutor : public QObject
{
    Q_OBJECT
public:
    explicit QueryExecutor(QObject *parent = nullptr);

public slots:
    ///
    /// \brief getAllObjects - Делает запрос в базу данных для получения всех данных
    ///
    QJsonDocument getAllObjects();

    ///
    /// \brief getSortedGroupByFirstLetter - Делает запрос в базу данных для получения отсортированных по первой букве данных
    ///
    QJsonDocument getSortedGroupByFirstLetter();

    ///
    /// \brief getSortedGroupByTypeCount - Делает запрос в базу данных для получения отсортированных по количеству типов объектов
    /// \param N - количество типов объектов
    ///
    QJsonDocument getSortedGroupByTypeCount(const quint16 &N);

    ///
    /// \brief getSortedGroupByDistance - Делает запрос в базу данных для получения отсортированных по дистанции данных
    ///
    QJsonDocument getSortedGroupByDistance();

    ///
    /// \brief getSortedGroupByDate - Делает запрос в базу данных для получения отсортированных по дате данных
    ///
    QJsonDocument getSortedGroupByDate();

private:
    QSqlDatabase m_database;

    const QString m_databaseSettingsGroup = "sqlDatabaseData/";
};
