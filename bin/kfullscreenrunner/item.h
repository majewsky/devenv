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

#ifndef KFULLSCREENRUNNER_ITEM_H
#define KFULLSCREENRUNNER_ITEM_H

#include <Plasma/IconWidget>
#include <QIcon>
#include <KService>

namespace Plasma
{
	class Label;
};

class KfsrIconWidget : public Plasma::IconWidget
{
	Q_OBJECT
	public:
		KfsrIconWidget(QGraphicsItem* parent = 0);
	protected:
		virtual void hoverEnterEvent(QGraphicsSceneHoverEvent* event);
		virtual void hoverLeaveEvent(QGraphicsSceneHoverEvent* event);
	Q_SIGNALS:
		void hoverChanged(bool hovering);
};

class KfsrItem : public QGraphicsWidget
{
	Q_OBJECT
	public:
		KfsrItem(QGraphicsItem* parent = 0);

		void setApplication(const QString& appname);
		void setShortcut(const QString& shortcut);
		bool checkShortcut(const QString& input) const;
	public Q_SLOTS:
		void setShowShortcut(bool showShortcut);
		void trigger();
	Q_SIGNALS:
		void triggered();
	protected:
		void renderShortcutIcon();
		virtual QVariant itemChange(GraphicsItemChange change, const QVariant& value);
		virtual bool sceneEventFilter(QGraphicsItem* watched, QEvent* event);
	private:
		KService::Ptr m_service;
		QString m_shortcut;
		QIcon m_serviceIcon, m_shortcutIcon;
		bool m_showingShortcut;
		//widgets
		Plasma::IconWidget* m_iconWidget;
		Plasma::Label* m_nameWidget;
		int m_iconTimerId;
};

#endif // KFULLSCREENRUNNER_ITEM_H
