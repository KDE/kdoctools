/*
 * This file is part of KDE Frameworks - KDocTools
 * The following contributors changed the signatures of the functions
 * exported here:
 * Copyright (C) 2001 Stephan Kulow <coolo@kde.org>
 * Copyright (C) 2005 Frerich Raabe <raabe@kde.org>
 * Copyright (C) 2010 Albert Astals Cid <aacid@kde.org>
 * Copyright (C) 2010, 2016, 2017 Luigi Toscano <luigi.toscano@tiscali.it>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef _KDOCTOOLS_XSLT_H_
#define _KDOCTOOLS_XSLT_H_

#include <kdoctools_export.h>
#include <QStandardPaths>
#include <QVector>

class QByteArray;
class QString;

/**
 * @namespace KDocTools
 * Utility methods to generate documentation in various format from DocBook files
 */
namespace KDocTools {

/**
 * Transform and return the content of file with the specified XSLT stylesheet
 * (both already in memory) using the optional parameters.
 */
KDOCTOOLS_EXPORT QString transform(const QString &file, const QString &stylesheet,
                                   const QVector<const char *> &params = QVector<const char *>());

/**
 * Extract the content of a single file from the content string
 * generated by the transformation scripts.
 * @since 5.32
 */
KDOCTOOLS_EXPORT QByteArray extractFileToBuffer(const QString &content, const QString &filename);

/**
 * Save the content (compressed) in the specified filename.
 */
KDOCTOOLS_EXPORT bool saveToCache(const QString &contents, const QString &filename);

/**
 * Initialize the XML catalog used by XSLT functions from the standard
   directories or from the specified srcdir.
 */
KDOCTOOLS_EXPORT void setupStandardDirs(const QString &srcdir = QString());


/**
 * Find a specified file amongst the resource shipped with KDocTools.
 */
KDOCTOOLS_EXPORT QString locateFileInDtdResource(const QString &file, const QStandardPaths::LocateOptions option=QStandardPaths::LocateFile);

/**
 * Returns the directories which can contain documentation.
 * @since 5.36
 */
KDOCTOOLS_EXPORT QStringList documentationDirs();

}

#endif
