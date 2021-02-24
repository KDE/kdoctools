
#include "../config-kdoctools.h"
#include "docbookxslt.h"
#include "docbookxslt_p.h"
#include "loggingcategory.h"
#include "meinproc_common.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QList>
#include <QStandardPaths>
#include <QString>

#include <QUrl>

#include <libexslt/exslt.h>
#include <libxml/HTMLtree.h>
#include <libxml/debugXML.h>
#include <libxml/parserInternals.h>
#include <libxml/xmlIO.h>
#include <libxml/xmlmemory.h>
#include <libxml/xmlversion.h>
#include <libxslt/transform.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/xsltconfig.h>
#include <libxslt/xsltutils.h>

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <qplatformdefs.h>
#include <string.h>

using namespace KDocTools;

#ifndef _WIN32
extern "C" int xmlLoadExtDtdDefaultValue;
#endif

class MyPair
{
public:
    QString word;
    int base;
};

typedef QList<MyPair> PairList;

#define DIE(x)                                                                                                                                                 \
    do {                                                                                                                                                       \
        qCCritical(KDocToolsLog) << "Error:" << x;                                                                                                             \
        exit(1);                                                                                                                                               \
    } while (0)

void parseEntry(PairList &list, xmlNodePtr cur, int base)
{
    if (!cur) {
        return;
    }

    base += atoi((const char *)xmlGetProp(cur, (const xmlChar *)"header"));
    if (base > 10) { // 10 is the maximum
        base = 10;
    }

    /* We don't care what the top level element name is */
    cur = cur->xmlChildrenNode;
    while (cur != nullptr) {
        if (cur->type == XML_TEXT_NODE) {
            QString words = QString::fromUtf8((char *)cur->content);
            const QStringList wlist = words.simplified().split(QLatin1Char(' '), Qt::SkipEmptyParts);
            for (QStringList::ConstIterator it = wlist.begin(); it != wlist.end(); ++it) {
                MyPair m;
                m.word = *it;
                m.base = base;
                list.append(m);
            }
        } else if (!xmlStrcmp(cur->name, (const xmlChar *)"entry")) {
            parseEntry(list, cur, base);
        }

        cur = cur->next;
    }
}

int main(int argc, char **argv)
{
    // xsltSetGenericDebugFunc(stderr, NULL);

    /*options.add("stylesheet <xsl>", ki18n("Stylesheet to use"));
    options.add("stdout", ki18n("Output whole document to stdout"));
    options.add("o");
    options.add("output <file>", ki18n("Output whole document to file"));
    options.add("htdig", ki18n("Create a ht://dig compatible index"));
    options.add("check", ki18n("Check the document for validity"));
    options.add("cache <file>", ki18n("Create a cache file for the document"));
    options.add("srcdir <dir>", ki18n("Set the srcdir, for kdelibs"));
    options.add("param <key>=<value>", ki18n("Parameters to pass to the stylesheet"));
    options.add("+xml", ki18n("The file to transform"));*/

    QCoreApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("meinproc"));
    app.setApplicationVersion(QStringLiteral("5.0"));

    QCommandLineParser parser;
    parser.setApplicationDescription(QCoreApplication::translate("main", "KDE Translator for XML"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addOption(
        QCommandLineOption(QStringList() << QStringLiteral("stylesheet"), QCoreApplication::translate("main", "Stylesheet to use"), QStringLiteral("xsl")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("stdout"), QCoreApplication::translate("main", "Output whole document to stdout")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("o") << QStringLiteral("output"),
                                        QCoreApplication::translate("main", "Output whole document to file"),
                                        QStringLiteral("file")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("check"), QCoreApplication::translate("main", "Check the document for validity")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("cache"),
                                        QCoreApplication::translate("main", "Create a cache file for the document"),
                                        QStringLiteral("file")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("srcdir"),
                                        QCoreApplication::translate("main", "Set the srcdir, for kdoctools"),
                                        QStringLiteral("dir")));
    parser.addOption(QCommandLineOption(QStringList() << QStringLiteral("param"),
                                        QCoreApplication::translate("main", "Parameters to pass to the stylesheet"),
                                        QStringLiteral("key=value")));
    parser.addPositionalArgument(QStringLiteral("xml"), QCoreApplication::translate("main", "The file to transform"));
    parser.process(app);

    if (parser.positionalArguments().count() != 1) {
        parser.showHelp();
        return (1);
    }

    exsltRegisterAll();

    // Need to set SRCDIR before calling setupStandardDirs
    QString srcdir;
    if (parser.isSet(QStringLiteral("srcdir"))) {
        srcdir = QDir(parser.value(QStringLiteral("srcdir"))).absolutePath();
    }
    setupStandardDirs(srcdir);

    LIBXML_TEST_VERSION

    const QString checkFilename = parser.positionalArguments().first();
    CheckFileResult ckr = checkFile(checkFilename);
    switch (ckr) {
    case CheckFileSuccess:
        break;
    case CheckFileDoesNotExist:
        DIE("File" << checkFilename << "does not exist.");
    case CheckFileIsNotFile:
        DIE(checkFilename << "is not a file.");
    case CheckFileIsNotReadable:
        DIE("File" << checkFilename << "is not readable.");
    }

    if (parser.isSet(QStringLiteral("check"))) {
        QStringList lst = getKDocToolsCatalogs();
        if (lst.isEmpty()) {
            DIE("Could not find kdoctools catalogs");
        }
        QByteArray catalogs = lst.join(" ").toLocal8Bit();
        QString exe;
#if defined(XMLLINT)
        exe = QStringLiteral(XMLLINT);
#endif
        if (!QFileInfo(exe).isExecutable()) {
            exe = QStandardPaths::findExecutable(QStringLiteral("xmllint"));
        }

        CheckResult cr = check(checkFilename, exe, catalogs);
        switch (cr) {
        case CheckSuccess:
            break;
        case CheckNoXmllint:
            DIE("Could not find xmllint");
        case CheckNoOut:
            DIE("`xmllint --noout` outputted text");
        }
    }

    QVector<const char *> params;
    {
        const QStringList paramList = parser.values(QStringLiteral("param"));
        QStringList::ConstIterator it = paramList.constBegin();
        QStringList::ConstIterator end = paramList.constEnd();
        for (; it != end; ++it) {
            const QString tuple = *it;
            const int ch = tuple.indexOf(QLatin1Char('='));
            if (ch == -1) {
                DIE("Key-Value tuple" << tuple << "lacks a '='!");
            }
            params.append(qstrdup(tuple.left(ch).toUtf8().constData()));
            params.append(qstrdup(tuple.mid(ch + 1).toUtf8().constData()));
        }
    }
    params.append(nullptr);

    QString tss = parser.value(QStringLiteral("stylesheet"));
    if (tss.isEmpty()) {
        tss = QStringLiteral("customization/kde-chunk.xsl");
    }

    QString tssPath = locateFileInDtdResource(tss);
    if (tssPath.isEmpty()) {
        DIE("Unable to find the stylesheet named" << tss << "in dtd resources");
    }
#ifndef MEINPROC_NO_KARCHIVE
    const QString cache = parser.value(QStringLiteral("cache"));
#else
    if (parser.isSet("cache")) {
        qCWarning(KDocToolsLog) << QCoreApplication::translate(
            "main",
            "The cache option is not available, please re-compile with KArchive support. See MEINPROC_NO_KARCHIVE in KDocTools");
    }
#endif
    const bool usingStdOut = parser.isSet(QStringLiteral("stdout"));
    const bool usingOutput = parser.isSet(QStringLiteral("output"));
    const QString outputOption = parser.value(QStringLiteral("output"));

    QString output = transform(checkFilename, tssPath, params);
    if (output.isEmpty()) {
        DIE("Unable to parse" << checkFilename);
    }

#ifndef MEINPROC_NO_KARCHIVE
    if (!cache.isEmpty()) {
        if (!saveToCache(output, cache)) {
            qCWarning(KDocToolsLog) << QCoreApplication::translate("main", "Could not write to cache file %1.").arg(cache);
        }
        goto end;
    }
#endif

    doOutput(output, usingStdOut, usingOutput, outputOption, true /* replaceCharset */);
#ifndef MEINPROC_NO_KARCHIVE
end:
#endif
    xmlCleanupParser();
    xmlMemoryDump();
    return (0);
}
