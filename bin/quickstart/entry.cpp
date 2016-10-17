#include "entry.h"

#include <QtCore/QDir>
#include <QtCore/QProcess>
#include <QtCore/QVariant>
#include <QtWidgets/QMessageBox>
#include <QtWidgets/QPushButton>

Entry::Entry(const QString& declaration)
    : m_command(declaration)
{
    const QChar colon(':');
    if (m_command.contains(colon)) {
        QStringList parts = m_command.split(colon);
        m_shortcut = parts.takeFirst();
        m_command = parts.join(colon);
    }
}

QVector<Entry> Entry::list() {
    return QVector<Entry>();
}

QPushButton* Entry::toButton() const {
    QPushButton* btn = new QPushButton(m_command);
    btn->setProperty("qs-shortcut", m_shortcut);

    const QString command = m_command;
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
