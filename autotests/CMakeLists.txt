add_test(
  NAME meinproc_template
  COMMAND meinproc5 --srcdir ${CMAKE_CURRENT_BINARY_DIR}/../src ${CMAKE_CURRENT_SOURCE_DIR}/../src/template.docbook
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

set(CTEST_ENVIRONMENT "QT_LOGGING_RULES=kf5.kdoctools=true")

add_test(kdoctools_install ${CMAKE_CTEST_COMMAND}
    --build-and-test
    "${CMAKE_CURRENT_SOURCE_DIR}/kdoctools-install"
    "${CMAKE_CURRENT_BINARY_DIR}/kdoctools-install"
    --build-generator ${CMAKE_GENERATOR}
    --build-makeprogram ${CMAKE_MAKE_PROGRAM}
    --build-target install
    --build-options
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/kdoctools-install/destdir"
        "-DKF5DocTools_DIR=${CMAKE_BINARY_DIR}/cmake"
        "-DKDOCTOOLS_CUSTOMIZATION_DIR=${KDOCTOOLS_CUSTOMIZATION_DIR}"
        "-DKDOCTOOLS_ENABLE_HTMLHANDBOOK=1"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
    --test-command ${CMAKE_COMMAND}
        "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/kdoctools-install/destdir"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/kdoctools-install/test.cmake")
