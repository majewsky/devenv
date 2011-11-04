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

#include "view.h"
#include "item.h"

#include <cmath>
#include <QBoxLayout>
#include <QGraphicsGridLayout>
#include <QGraphicsScene>
#include <QGraphicsView>
#include <QKeyEvent>
#include <QPainter>
#include <KAction>
#include <KActionCollection>
#include <KLocalizedString>
#include <KWindowSystem>

KfsrView::KfsrView()
	: m_actionCollection(new KActionCollection(this))
	, m_triggerAction(new KAction(i18n("Trigger interface"), this))
	, m_itemView(new QGraphicsView(this))
	, m_itemScene(new QGraphicsScene(this))
{
	//setup widget
	setWindowFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowStaysOnTopHint);
	setAttribute(Qt::WA_DeleteOnClose, false);
	setAttribute(Qt::WA_MouseTracking); //TODO: necessary?
	setAttribute(Qt::WA_TranslucentBackground);
	setWindowState(Qt::WindowActive | Qt::WindowMaximized);
	KWindowSystem::self()->setOnAllDesktops(winId(), true);
	//TODO: prevent user from minimizing/maximizing the window
	//TODO: do not show on pager
	//setup widget contents (basic)
	setFocusPolicy(Qt::StrongFocus);
	QBoxLayout* layout = new QBoxLayout(QBoxLayout::TopToBottom);
	setLayout(layout);
	//setup actions
	m_actionCollection->addAction("trigger-fullscreenrunner", m_triggerAction);
	m_triggerAction->setGlobalShortcut(KShortcut(Qt::META | Qt::Key_Space));
	connect(m_triggerAction, SIGNAL(triggered()), SLOT(show()));
	//setup translucent itemview
	layout->addWidget(m_itemView);
	m_itemView->viewport()->setAutoFillBackground(false);
	m_itemView->setFrameStyle(QFrame::NoFrame);
	m_itemView->setFocusPolicy(Qt::NoFocus);
	//setup itemscene
	m_itemView->setScene(m_itemScene);
	QGraphicsWidget* container = new QGraphicsWidget;
	m_itemScene->addItem(container);
	container->QObject::setParent(m_itemScene);
	QGraphicsGridLayout* itemLayout = new QGraphicsGridLayout(container);
	//hardcoded launcher-key associations
	typedef QPair<QString, QString> QStringPair;
	QList<QStringPair> hardcodedAssociations;
	hardcodedAssociations << QStringPair("Konqueror", "k");
	hardcodedAssociations << QStringPair("Firefox", "f");
	hardcodedAssociations << QStringPair("Chromium", "c");
	hardcodedAssociations << QStringPair("Konsole", "o");
	hardcodedAssociations << QStringPair("KMail", "m");
	hardcodedAssociations << QStringPair("Amarok", "a");
	//create items
	foreach (const QStringPair& association, hardcodedAssociations)
	{
		KfsrItem* item = new KfsrItem;
		item->setApplication(association.first);
		item->setShortcut(association.second);
		connect(item, SIGNAL(triggered()), SLOT(hide()));
		m_items << item;
	}
	//arrange items
	QList<KfsrItem*>::const_iterator it1 = m_items.begin(), it2 = m_items.end();
	const int layoutWidth = ceil(sqrt((double) m_items.count()));
	for (int y = 0; it1 != it2; ++y)
		for (int x = 0; it1 != it2 && x < layoutWidth; ++x, ++it1)
			itemLayout->addItem(*it1, y, x);
}

void KfsrView::focusOutEvent(QFocusEvent* event)
{
	Q_UNUSED(event)
	hide();
}

void KfsrView::keyPressEvent(QKeyEvent* event)
{
	if (event->key() == Qt::Key_Escape)
	{
		hide();
		event->accept();
	}
	else
	{
		//check event triggers
		const QString trigger = event->text();
		foreach (KfsrItem* item, m_items)
			if (item->checkShortcut(trigger))
			{
				item->trigger();
				event->accept();
				hide();
			}
	}
}

void KfsrView::paintEvent(QPaintEvent* event)
{
	Q_UNUSED(event)
	QColor bgColor(Qt::black);
	bgColor.setAlpha(192);
	QPainter(this).fillRect(rect(), bgColor);
}

void KfsrView::showEvent(QShowEvent* event)
{
	Q_UNUSED(event)
	setFocus(Qt::OtherFocusReason);
	setWindowState(Qt::WindowActive | Qt::WindowMaximized);
}
