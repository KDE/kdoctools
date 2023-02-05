cmake_minimum_required(VERSION 3.16)

set(KF_VERSION "5.103.0") # handled by release scripts
set(KF_DEP_VERSION "5.103.0") # handled by release scripts
project(KDocTools VERSION ${KF_VERSION})

# ECM setup
include(FeatureSummary)
find_package(ECM 5.103.0  NO_MODULE)
set_package_properties(ECM PROPERTIES TYPE REQUIRED DESCRIPTION "Extra CMake Modules." URL "https://commits.kde.org/extra-cmake-modules")
feature_summary(WHAT REQUIRED_PACKAGES_NOT_FOUND FATAL_ON_MISSING_REQUIRED_PACKAGES)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)

include(KDEGitCommitHooks)
include(ECMSetupVersion)
include(ECMMarkNonGuiExecutable)
include(ECMQtDeclareLoggingCategory)
include(ECMDeprecationSettings)
include(CMakePackageConfigHelpers)
include(GenerateExportHeader)
include(ECMAddQch)

ecm_setup_version(PROJECT VARIABLE_PREFIX KDOCTOOLS
                        VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/kdoctools_version.h"
                        PACKAGE_VERSION_FILE "${CMAKE_BINARY_DIR}/cmake/KF5DocToolsConfigVersion.cmake"
                        SOVERSION 5)

option(MEINPROC_NO_KARCHIVE "Compile meinproc without KArchive dependency. Only for internal usage on KDE infrastructure." OFF)
option(INSTALL_INTERNAL_TOOLS "Install internal tools too." OFF)
option(BUILD_QCH "Build API documentation in QCH format (for e.g. Qt Assistant, Qt Creator & KDevelop)" OFF)
add_feature_info(QCH ${BUILD_QCH} "API documentation in QCH format (for e.g. Qt Assistant, Qt Creator & KDevelop)")

# Dependencies
set(REQUIRED_QT_VERSION 5.15.2)
find_package(Qt${QT_MAJOR_VERSION}Core ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE)

# KF5 frameworks
if (NOT MEINPROC_NO_KARCHIVE)
   find_package(KF5Archive ${KF_DEP_VERSION} REQUIRED)
else()
   message(WARNING "KArchive dependency has been disabled. This should be done only for internal usage on KDE infrastructure.")
endif()

find_package(KF5I18n ${KF_DEP_VERSION})
set_package_properties(KF5I18n PROPERTIES TYPE OPTIONAL
   PURPOSE "Required to build the KDocTools translations")

find_package(LibXslt)
set_package_properties(LibXslt PROPERTIES
                       URL "http://xmlsoft.org/XSLT"
                       TYPE REQUIRED
                       PURPOSE "Required by the KDE help system to process DocBook XML"
                      )

find_package(LibXml2)
set_package_properties(LibXml2 PROPERTIES
                       URL "http://xmlsoft.org"
                       TYPE REQUIRED
                       PURPOSE "Required by the KDE help system to process DocBook XML"
                      )

if (NOT LIBXML2_XMLLINT_EXECUTABLE)
   message(FATAL_ERROR "xmllint is required to process DocBook XML")
endif()

find_package(DocBookXML4 "4.5")

set_package_properties(DocBookXML4 PROPERTIES
                       TYPE REQUIRED
                       PURPOSE "Required by the KDE help system to process DocBook XML"
                      )

find_package(DocBookXSL)
set_package_properties(DocBookXSL PROPERTIES
                       TYPE REQUIRED
                       PURPOSE "Required by the KDE help system to process DocBook XML"
                      )

remove_definitions(-DQT_NO_CAST_FROM_ASCII)
set(_kdoctoolsBootStrapping TRUE)
set(KDOCTOOLS_CUSTOMIZATION_DIR "${CMAKE_CURRENT_BINARY_DIR}/src/customization/")
if (WIN32)
    set(KDOCTOOLS_MEINPROC_EXECUTABLE          ${EXECUTABLE_OUTPUT_PATH}/${CMAKE_CFG_INTDIR}/meinproc5 )
else ()
    set(KDOCTOOLS_MEINPROC_EXECUTABLE          ${CMAKE_CURRENT_BINARY_DIR}/src/meinproc5${CMAKE_EXECUTABLE_SUFFIX} )
endif ()
include(KF5DocToolsMacros.cmake)

set(KDOCTOOLS_LANGUAGES_LIST af bg ca ca@valencia cs da de el en-GB en eo es et fi fo fr gl he hu id it ja ko lt nds nl nn no pl pt-BR pt ro ru sk sl sq sr sr@latin sr@ijekavian sr@ijekavianlatin sv th tr uk wa xh xx zh-CN zh-TW)

set(CMAKECONFIG_INSTALL_DIR "${KDE_INSTALL_CMAKEPACKAGEDIR}/KF5DocTools")
add_definitions(-DTRANSLATION_DOMAIN=\"kdoctools5\")
ecm_set_disabled_deprecation_versions(
    QT 5.15.2
    KF 5.97
)

if (KF5I18n_FOUND)
    ki18n_install(po)
    kdoctools_install(po)
endif()
add_subdirectory(common)
add_subdirectory(docs)
add_subdirectory(src)
if (BUILD_TESTING)
    add_subdirectory(autotests)
endif()

install(EXPORT KF5DocToolsTargets DESTINATION "${CMAKECONFIG_INSTALL_DIR}" FILE KF5DocToolsTargets.cmake NAMESPACE KF5:: )
install(EXPORT KF5DocToolsToolsTargets DESTINATION "${CMAKECONFIG_INSTALL_DIR}" FILE KF5DocToolsToolsTargets.cmake NAMESPACE KF5:: )

if (BUILD_QCH)
    ecm_install_qch_export(
        TARGETS KF5DocTools_QCH
        FILE "${CMAKE_BINARY_DIR}/cmake/KF5DocToolsQchTargets.cmake"
        DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
        COMPONENT Devel
    )
    set(PACKAGE_INCLUDE_QCHTARGETS "include(\"\${CMAKE_CURRENT_LIST_DIR}/KF5DocToolsQchTargets.cmake\")")
endif()

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/KF5DocToolsConfig.cmake.in"
  "${CMAKE_BINARY_DIR}/cmake/KF5DocToolsConfig.cmake"
  PATH_VARS
    KDE_INSTALL_DATADIR_KF
  INSTALL_DESTINATION  ${CMAKECONFIG_INSTALL_DIR}
)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/KF5DocToolsMacros.cmake ${CMAKE_BINARY_DIR}/cmake/KF5DocToolsMacros.cmake COPYONLY)
# we need a separate copy with local paths for install autotests
export(EXPORT KF5DocToolsTargets FILE ${CMAKE_BINARY_DIR}/cmake/KF5DocToolsTargets.cmake NAMESPACE KF5::)
export(EXPORT KF5DocToolsToolsTargets FILE ${CMAKE_BINARY_DIR}/cmake/KF5DocToolsToolsTargets.cmake NAMESPACE KF5::)

install(FILES
  "${CMAKE_BINARY_DIR}/cmake/KF5DocToolsConfig.cmake"
  "${CMAKE_BINARY_DIR}/cmake/KF5DocToolsConfigVersion.cmake"
  DESTINATION "${CMAKECONFIG_INSTALL_DIR}"
  COMPONENT Devel
)

configure_file(config-kdoctools.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-kdoctools.h )

install( FILES
    KF5DocToolsMacros.cmake
    DESTINATION ${CMAKECONFIG_INSTALL_DIR} COMPONENT Devel )

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)
