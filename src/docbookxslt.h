/*
    This file is part of KDE Frameworks - KDocTools
    The following contributors changed the signatures of the functions
    exported here:

    SPDX-FileCopyrightText: 2001 Stephan Kulow <coolo@kde.org>
    SPDX-FileCopyrightText: 2005 Frerich Raabe <raabe@kde.org>
    SPDX-FileCopyrightText: 2010 Albert Astals Cid <aacid@kde.org>
    SPDX-FileCopyrightText: 2010, 2016, 2017 Luigi Toscano <luigi.toscano@tiscali.it>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef _KDOCTOOLS_XSLT_H_
#define _KDOCTOOLS_XSLT_H_

#include <QList>
#include <QStandardPaths>
#include <kdoctools_export.h>

class QByteArray;
class QString;

/*!
 * \namespace KDocTools
 * \inheaderfile docbookxslt.h
 * \inmodule KDocTools
 * \brief Utility methods to generate documentation in various format from DocBook files.
 */
namespace KDocTools
{
/*!
 * Transform and return the content of file with the specified XSLT stylesheet
 * (both already in memory) using the optional parameters.
 */
KDOCTOOLS_EXPORT QString transform(const QString &file, const QString &stylesheet, const QList<const char *> &params = QList<const char *>());

/*!
 * Extract the content of a single file from the content string
 * generated by the transformation scripts.
 * \since 5.32
 */
KDOCTOOLS_EXPORT QByteArray extractFileToBuffer(const QString &content, const QString &filename);

/*!
 * Save the content (compressed) in the specified filename.
 */
KDOCTOOLS_EXPORT bool saveToCache(const QString &contents, const QString &filename);

/*!
 * Initialize the XML catalog used by XSLT functions from the standard
 *  directories or from the specified srcdir.
 */
KDOCTOOLS_EXPORT void setupStandardDirs(const QString &srcdir = QString());

/*!
 * Find a specified file amongst the resource shipped with KDocTools.
 */
KDOCTOOLS_EXPORT QString locateFileInDtdResource(const QString &file, const QStandardPaths::LocateOptions option = QStandardPaths::LocateFile);

/*!
 * Returns the directories which can contain documentation.
 * \since 5.36
 */
KDOCTOOLS_EXPORT QStringList documentationDirs();

}

#endif
