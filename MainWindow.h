#pragma once

#include <QMainWindow>

#include "./ui_MainWindow.h"

#include "Server/AdeptServer.h"
#include <QJsonObject>
#include <QListView>

class MainWindow : public QMainWindow, protected Ui::MainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);

public slots:
    void showAllData(const QJsonDocument &document);
    void showData(const QJsonDocument &document);

private:
    AdeptServer m_server;
    QueryExecutor m_queryExequtor;
};
