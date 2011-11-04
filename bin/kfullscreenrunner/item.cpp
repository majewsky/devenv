/***************************************************************************
 *   Copyright 2010 Stefan Majewsky <majewsky@gmx.net>
 *
 *   This program is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU General Public
 *   License as published by the Free Software Foundation; either
 *   version 2 of the License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 ***************************************************************************/

#include "item.h"

#include <QGraphicsLinearLayout>
#include <QPainter>
#include <KIcon>
#include <KRun>
#include <KServiceTypeTrader>
#include <Plasma/IconWidget>

KfsrIconWidget::KfsrIconWidget(QGraphicsItem* parent)
	: Plasma::IconWidget(parent)
{
}

void KfsrIconWidget::hoverEnterEvent(QGraphicsSceneHoverEvent* event)
{
	emit hoverChanged(true);
	Plasma::IconWidget::hoverEnterEvent(event);
}

void KfsrIconWidget::hoverLeaveEvent(QGraphicsSceneHoverEvent* event)
{
	emit hoverChanged(false);
	Plasma::IconWidget::hoverLeaveEvent(event);
}

KfsrItem::KfsrItem(QGraphicsItem* parent)
	: QGraphicsWidget(parent)
	, m_showingShortcut(false)
	, m_iconWidget(new KfsrIconWidget)
{
	QGraphicsLinearLayout* layout = new QGraphicsLinearLayout(Qt::Vertical, this);
	layout->addItem(m_iconWidget);
	m_iconWidget->setPreferredIconSize(QSizeF(192, 192));
	m_iconWidget->setTextBackgroundColor(Qt::white);
	m_iconWidget->setDrawBackground(true);
	connect(m_iconWidget, SIGNAL(hoverChanged(bool)), SLOT(setShowShortcut(bool)));
	connect(m_iconWidget, SIGNAL(clicked()), SLOT(trigger()));
}

void KfsrItem::setApplication(const QString& appname)
{
	//FIXME: This query has to make some assumptions about how well-formed application entries look like, in order to work with the hardcoded appnames.
	//FIXME: IMO this query depends on the locale.
	static const QString query = QString::fromLatin1("(Type == 'Application') and (GenericName != '') and exist Exec and ('%1' == Name)");
	static const QString query2 = QString::fromLatin1("(Type == 'Application') and (GenericName != '') and exist Exec and ('%1' ~ Name)");
	const KService::List services = KServiceTypeTrader::self()->query("Application", query.arg(appname)) + KServiceTypeTrader::self()->query("Application", query2.arg(appname));
	if (services.isEmpty())
		return;
	m_service = services.value(0);
	//read user-visible contents of the service
	m_serviceIcon = KIcon(m_service->icon());
	if (!m_showingShortcut)
		m_iconWidget->setIcon(m_serviceIcon);
	m_iconWidget->setText(m_service->name());
	m_iconWidget->setInfoText(m_service->genericName());
}

void KfsrItem::setShortcut(const QString& shortcut)
{
	m_shortcut = shortcut.toUpper();
	renderShortcutIcon();
	if (m_showingShortcut)
		m_iconWidget->setIcon(m_shortcutIcon);
}

bool KfsrItem::checkShortcut(const QString& input) const
{
	return m_shortcut.compare(input, Qt::CaseInsensitive) == 0;
}

void KfsrItem::renderShortcutIcon()
{
	m_shortcutIcon = QIcon();
	if (m_shortcut.isEmpty())
		return;
	//render a pixmap from this shortcut at same size as service icon
	const QSize size = m_iconWidget->preferredIconSize().toSize();
	QPixmap pix(size);
	pix.fill(Qt::transparent);
	QPainter painter(&pix);
	//find size of text, in order to scale it to the icon size (using KeepAspectRatio strategy)
	QFontMetrics fm(painter.font());
	const QSizeF textSize = fm.size(Qt::TextSingleLine, m_shortcut);
	const qreal scaling = qMin(
		size.width() / textSize.width(),
		size.height() / textSize.height()
	);
	//change painter transform to include scaling; coordinate (0,0) is center of pixmap
	painter.translate(size.width() / 2.0, size.height() / 2.0);
	painter.scale(scaling, scaling);
	//determine position of text within pixmap, draw text
	QRectF textRect(QPointF(), textSize * scaling);
	textRect.moveCenter(QPoint());
	painter.drawText(textRect, Qt::TextSingleLine | Qt::AlignCenter, m_shortcut);
	painter.end();
	m_shortcutIcon.addPixmap(pix);
}

void KfsrItem::setShowShortcut(bool showShortcut)
{
	if (m_showingShortcut == showShortcut)
		return;
	m_showingShortcut = showShortcut;
	m_iconWidget->setIcon(showShortcut ? m_shortcutIcon : m_serviceIcon);
}

QVariant KfsrItem::itemChange(GraphicsItemChange change, const QVariant& value)
{
	if (change == QGraphicsItem::ItemSceneChange && scene())
		m_iconWidget->installSceneEventFilter(this);
	return QGraphicsObject::itemChange(change, value);
}

bool KfsrItem::sceneEventFilter(QGraphicsItem* watched, QEvent* event)
{
	if (watched != m_iconWidget)
		return QGraphicsObject::sceneEventFilter(watched, event);
	switch ((int) event->type())
	{
		case QEvent::GraphicsSceneHoverEnter:
			setShowShortcut(true);
			break;
		case QEvent::GraphicsSceneHoverLeave:
			setShowShortcut(false);
			break;
	}
	return false;
}

void KfsrItem::trigger()
{
	if (m_service)
	{
		emit triggered();
		KRun::run(*m_service, KUrl::List(), 0);
	}
}

#include "item.moc"
