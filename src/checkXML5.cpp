/*  This file is part of the KDE project
    Copyright (C) 2015-2016 Ralf Habacker <ralf.habacker@freenet.de>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) version 3, or any
    later version accepted by the membership of KDE e.V. (or its
    successor approved by the membership of KDE e.V.), which shall
    act as a proxy defined in Section 6 of version 3 of the license.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "loggingcategory.h"

#include <QCoreApplication>
#include <QProcess>
#include <QDebug>

#include <stdio.h>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);

    const QStringList arguments = app.arguments();
    if (arguments.count() != 2) {
        qCCritical(KDocToolsLog) << "wrong argument count";
        return (1);
    }

    QProcess meinproc;
    meinproc.start("meinproc5", QStringList() << "--check" << "--stdout" << arguments[1]);
    if (!meinproc.waitForStarted())
        return -2;
    if (!meinproc.waitForFinished())
        return -1;
    fprintf(stderr, "%s", meinproc.readAllStandardError().constData());
    return meinproc.exitCode();
}
