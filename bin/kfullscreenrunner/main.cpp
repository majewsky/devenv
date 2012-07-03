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

#include <cstdio>
#include <KDE/KAboutData>
#include <KDE/KCmdLineArgs>
#include <KDE/KLocalizedString>
#include <KDE/KUniqueApplication>

int main(int argc, char** argv)
{
	KAboutData about(
		"kfullscreenrunner", 0,
		ki18n("KFullscreenRunner"), "0.0.1",
		ki18n("A simple application launcher"),
		KAboutData::License_GPL, ki18n("Copyright 2010 Stefan Majewsky")
	);
	KCmdLineArgs::init(argc, argv, &about);
	KUniqueApplication::addCmdLineOptions();

	if (!KUniqueApplication::start()) {
		fprintf(stderr, "KFullscreenRunner is already running!\n");
		return 0;
	}

	KUniqueApplication app;
	QApplication::setStyle("oxygen");
	new KfsrView;
	return app.exec();
}
