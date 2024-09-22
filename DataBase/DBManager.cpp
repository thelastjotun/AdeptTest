#include "DBManager.h"

///
/// \brief connectionList - список открытых соединений в потоках
///
QHash< QThread *, QSqlDatabase > DBManager::connectionList;

QMutex DBManager::m_mutexDatabase;

const QString DBManager::m_possibleRandomCharacters("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789");

DBManager::DBManager(QObject *parent)
    : QObject{ parent }
{}
///
/// \brief getRandomString - функция генерирует строку со случайными символами
/// \return - возвращает строку со случайными символами
///
QString DBManager::getRandomString()
{
    {
        QString randomString;
        for (int i = 0; i < m_randomStringLength; ++i) {
            int index = rand() % m_possibleRandomCharacters.length();
            QChar nextChar = m_possibleRandomCharacters.at(index);

            randomString.append(nextChar);
        }

        return randomString;
    }
}
