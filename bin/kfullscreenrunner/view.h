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

#ifndef KFULLSCREENRUNNER_VIEW_H
#define KFULLSCREENRUNNER_VIEW_H

class QGraphicsScene;
class QGraphicsView;
#include <QWidget>
class KAction;
class KActionCollection;
class KfsrItem;

class KfsrView : public QWidget
{
	public:
		KfsrView();
	protected:
		virtual void focusOutEvent(QFocusEvent* event);
		virtual void keyPressEvent(QKeyEvent* event);
		virtual void paintEvent(QPaintEvent* event);
		virtual void showEvent(QShowEvent* event);
	private:
		KActionCollection* m_actionCollection;
		KAction* m_triggerAction;
		QGraphicsView* m_itemView;
		QGraphicsScene* m_itemScene;
		QList<KfsrItem*> m_items;
};

#endif // KFULLSCREENRUNNER_VIEW_H
