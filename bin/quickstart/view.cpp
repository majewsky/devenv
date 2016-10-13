#include "view.h"

#include <QtCore/QDir>
#include <QtCore/QProcess>
#include <QtCore/QTimer>
#include <QtGui/QFocusEvent>
#include <QtGui/QKeyEvent>
#include <QtGui/QPainter>
#include <QtWidgets/QApplication>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QMessageBox>
#include <QtWidgets/QPushButton>

View::View() {
    setWindowFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
    setAttribute(Qt::WA_MouseTracking); //TODO: necessary?
    setAttribute(Qt::WA_TranslucentBackground);
    setFocusPolicy(Qt::StrongFocus);
}

void View::focusOutEvent(QFocusEvent* event) {
    if (event->reason() == Qt::ActiveWindowFocusReason) {
        hide();
        QTimer::singleShot(0, QApplication::instance(), SLOT(quit()));
    }
}

void View::keyPressEvent(QKeyEvent* event) {
    //hide on Escape
    if (event->key() == Qt::Key_Escape) {
        hide();
        event->accept();
    }

    //find if this key is registered as a shortcut (we cannot use the
    //QAbstractButton::shortcut functionality for this since it will insist on
    //adding an Alt modifier to the shortcut)
    const QString text = event->text();
    for (QObject* obj: children()) {
        if (QPushButton* btn = qobject_cast<QPushButton*>(obj)) {
            if (btn->property("qs-shortcut") == text) {
                btn->animateClick();
            }
        }
    }
}

void View::paintEvent(QPaintEvent* event) {
    Q_UNUSED(event)
    QColor bgColor(Qt::black);
    bgColor.setAlpha(192);
    QPainter(this).fillRect(rect(), bgColor);
}

void View::showEvent(QShowEvent* event) {
    Q_UNUSED(event)
    setFocus(Qt::OtherFocusReason);
    setWindowState(Qt::WindowActive | Qt::WindowMaximized);
}

static QPushButton* makeButton(const QString& command, const QString& shortcut) {
    QPushButton* btn = new QPushButton(command);
    btn->setProperty("qs-shortcut", shortcut);

    QObject::connect(btn, &QAbstractButton::clicked, [command, btn]() {
        if (!QProcess::startDetached(command, QStringList(), QDir::homePath())) {
            QMessageBox::critical(0,
                QStringLiteral("quickstart"),
                QStringLiteral("Failed to start %1").arg(command)
            );
        }
        btn->window()->hide();
    });

    return btn;
}

void View::setupButtons(const QStringList& commands) {
    QGridLayout* layout = new QGridLayout(this);

    for (int i = 0; i < commands.size(); ++i) {
        QString command = commands[i];
        QString shortcut;

        const QChar colon(':');
        if (command.contains(colon)) {
            QStringList parts = command.split(colon);
            shortcut = parts.takeFirst();
            command = parts.join(colon);
        }

        layout->addWidget(makeButton(command, shortcut), i + 1, 1);
    }

    layout->setColumnStretch(0, 1);
    layout->setColumnStretch(2, 1);
    layout->setRowStretch(0, 1);
    layout->setRowStretch(commands.size() + 1, 1);
}
