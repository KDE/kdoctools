project(kdoctools_install)

find_package(ECM NO_MODULE)
# required by KF5DocToolsMacros
include(KDEInstallDirs)

find_package(KF5DocTools REQUIRED)

add_subdirectory(../../docs docs)
kdoctools_install(po)
