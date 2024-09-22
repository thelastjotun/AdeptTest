#include "MainWindow.h"

#include <QAbstractListModel>
#include <QHttpServerRequest>
#include <QStringBuilder>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    setupUi(this);

    connect(pbGetAll, &QPushButton::clicked, this, [&]() { showAllData(m_queryExequtor.getAllObjects()); });

    connect(pbGetTime, &QPushButton::clicked, this, [&]() { showData(m_queryExequtor.getSortedGroupByDate()); });

    connect(pbGetDist, &QPushButton::clicked, this, [&]() { showData(m_queryExequtor.getSortedGroupByDistance()); });

    connect(pbGetLetter, &QPushButton::clicked, this, [&]() { showData(m_queryExequtor.getSortedGroupByFirstLetter()); });

    connect(pbGetType, &QPushButton::clicked, this, [&]() {
        showData(m_queryExequtor.getSortedGroupByTypeCount(sbTypeCount->value()));
    });

    connect(&m_server, &AdeptServer::allObjectsChanged, this, &MainWindow::showAllData);
    connect(&m_server, &AdeptServer::byDateChanged, this, &MainWindow::showData);
    connect(&m_server, &AdeptServer::byDistanceChanged, this, &MainWindow::showData);
    connect(&m_server, &AdeptServer::byFirstLetterChanged, this, &MainWindow::showData);
    connect(&m_server, &AdeptServer::byTypeChanged, this, &MainWindow::showData);

    m_server.startServer();
}

void MainWindow::showAllData(const QJsonDocument &document)
{
    lwObjects->clear();

    auto array = document.array();

    for (auto item : array) {
        auto object = item.toObject();

        QString objString = object.value("name").toString() % " " % QString::number(object.value("coord1").toDouble()) % " "
                            % QString::number(object.value("coord2").toDouble()) % " " % object.value("type").toString() % " "
                            % QString::number(object.value("creationTime").toInt());

        lwObjects->addItem(objString);
    }
}

void MainWindow::showData(const QJsonDocument &document)
{
    lwObjects->clear();

    auto array = document.array();

    for (auto item : array) {
        auto object = item.toObject();

        QString objString = object.value("group").toString();

        objString = objString.remove('(');
        objString = objString.remove(')');
        objString.replace(',', " ");

        lwObjects->addItem(objString);
    }
}
