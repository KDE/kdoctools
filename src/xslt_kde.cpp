#include "docbookxslt.h"
#ifndef MEINPROC_NO_KARCHIVE
#include <kfilterdev.h>
#else
#include "loggingcategory.h"
#include <QDebug>
#endif

bool KDocTools::saveToCache(const QString &contents, const QString &filename)
{
#ifndef MEINPROC_NO_KARCHIVE
    KFilterDev fd(filename);

    if (!fd.open(QIODevice::WriteOnly)) {
        return false;
    }

    fd.write(contents.toUtf8());
    fd.close();
#else
    qCWarning(KDocToolsLog) << "This function is dummy because KArchive support has been disabled. "
               "This mode should be enabled only for specific usage on KDE infrastructure.";
    Q_UNUSED(contents)
    Q_UNUSED(filename)
#endif
    return true;
}
