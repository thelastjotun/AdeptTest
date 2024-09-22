#pragma once

#include <QHash>
#include <QMutex>
#include <QMutexLocker>
#include <QObject>
#include <QSqlDatabase>
#include <QThread>

class DBManager : public QObject
{
    Q_OBJECT
public:
    explicit DBManager(QObject *parent = nullptr);
    ///
    /// \brief databaseConnect - Функция создаёт и открывает соединение с базой данных в текущем потоке. Возращает базу данных с открытым соединением
    /// \param newDatabase - База данных, к которой нужно подключиться.
    ///
    [[nodiscard]] static QSqlDatabase databaseConnect(const QSqlDatabase &newDatabase)
    {
        QMutexLocker mutexLocker(&m_mutexDatabase);
        QThread *thread = QThread::currentThread();

        /* Если есть соединение в текущем потоке, возвращаем его. */
        if (connectionList.contains(thread)) {
            return connectionList[thread];
        }

        /* Создаём и открываем соединение с базой данных в текущем потоке. */
        QSqlDatabase databaseConnection = QSqlDatabase::cloneDatabase(newDatabase, getRandomString());
        if (!databaseConnection.open()) {
            return QSqlDatabase();
        }

        connectionList.insert(thread, databaseConnection);

        return databaseConnection;
    }

    ///
    /// \brief databaseDisconnect - Закрывает соединение с базой данных в потоке.
    /// \param thread - Поток, в котором нужно закрыть соединение.
    ///
    static void databaseDisconnect(QThread *thread)
    {
        if (thread) {
            if (connectionList.contains(thread)) {
                if (connectionList[thread].isOpen()) {
                    connectionList[thread].close();
                }

                connectionList.remove(thread);
            }
        }
    }

    ///
    /// \brief connectionList - список открытых соединений в потоках
    ///
    static QHash< QThread *, QSqlDatabase > connectionList;

private:
    ///
    /// \brief getRandomString - возвращает сгенерированную строку со случайными символами
    ///
    static QString getRandomString();

private:
    static QMutex m_mutexDatabase;

    static const quint8 m_randomStringLength = 8;
    static const QString m_possibleRandomCharacters;
};
