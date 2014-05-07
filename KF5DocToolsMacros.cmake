# Copyright (c) 2006-2009 Alexander Neundorf, <neundorf@kde.org>
# Copyright (c) 2006, 2007, Laurent Montel, <montel@kde.org>
# Copyright (c) 2007 Matthias Kretz <kretz@kde.org>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#  KDOCTOOLS_CREATE_HANDBOOK( docbookfile [INSTALL_DESTINATION installdest] [SUBDIR subdir])
#   Create the handbook from the docbookfile (using meinproc5)
#   The resulting handbook will be installed to <installdest> when using
#   INSTALL_DESTINATION <installdest>, or to <installdest>/<subdir> if
#   SUBDIR <subdir> is specified.
#
#  KDOCTOOLS_CREATE_MANPAGE( docbookfile section [INSTALL_DESTINATION installdest])
#   Create the manpage for the specified section from the docbookfile (using meinproc5)
#   The resulting manpage will be installed to <installdest> when using
#   INSTALL_DESTINATION <installdest>.
#
#  KDOCTOOLS_INSTALL(podir)
#   Search for docbook files in <podir> and install them to the standard
#   location.
#   This is a convenience function which relies on all docbooks being kept in
#   <podir>/<lang>/docs, where <lang> is the language the docbooks are written
#   in.
#
#   Within this directory, files ending with .[0-9].docbook are installed using
#   KDOCTOOLS_CREATE_MANPAGE, other .docbook files are installed using
#   KDOCTOOLS_CREATE_HANDBOOK.
#
#   For example, given the following directory structure:
#
#    po/
#      fr/
#        docs/
#          kioslave5/
#            fooslave/
#              index.docbook
#          footool.1.docbook
#          footool.conf.5.docbook
#          index.docbook
#
#   KDOCTOOLS_INSTALL(po) does the following:
#   - Create man pages from footool.1.docbook and footool.conf.5.docbook,
#     install them in ${MAN_INSTALL_DIR}/fr
#   - Create handbooks from index.docbook files, install the one from the
#     fooslave/ directory in ${HTML_INSTALL_DIR}/fr/kioslave5/fooslave
#     and the one from the docs/ directory in $[HTML_INSTALL_DIR}/fr
#
#   If ${HTML_INSTALL_DIR} is not set, share/doc/HTML is used instead.
#   If ${MAN_INSTALL_DIR} is not set, share/man/<lang> is used instead.
#
#  KDOCTOOLS_MEINPROC_EXECUTABLE - the meinproc5 executable
#
#  KDOCTOOLS_SERIALIZE_TOOL - wrapper to serialize potentially resource-intensive commands during
#                      parallel builds (set to 'icecc' when using icecream)
#
# The following variables are defined for the various tools required to
# compile KDE software:
#
#  KDOCTOOLS_MEINPROC_EXECUTABLE - the meinproc5 executable
#

set(KDOCTOOLS_SERIALIZE_TOOL "" CACHE STRING "Tool to serialize resource-intensive commands in parallel builds")
set(KDOCTOOLS_MEINPROC_EXECUTABLE "KF5::meinproc5")

if(KDOCTOOLS_SERIALIZE_TOOL)
    # parallel build with many meinproc invocations can consume a huge amount of memory
    set(KDOCTOOLS_MEINPROC_EXECUTABLE ${KDOCTOOLS_SERIALIZE_TOOL} ${KDOCTOOLS_MEINPROC_EXECUTABLE})
endif(KDOCTOOLS_SERIALIZE_TOOL)

function(create_target_name out in)
    string(REGEX REPLACE "[^0-9a-zA-Z]" "-" tmp "${in}")
    set(${out} ${tmp} PARENT_SCOPE)
endfunction()

function (kdoctools_create_handbook docbook)
    # Parse arguments
    set(options)
    set(oneValueArgs INSTALL_DESTINATION SUBDIR)
    set(multiValueArgs)
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Init vars
    get_filename_component(docbook ${docbook} ABSOLUTE)
    file(RELATIVE_PATH src_doc ${CMAKE_CURRENT_SOURCE_DIR} ${docbook})
    get_filename_component(src_dir ${src_doc} DIRECTORY)
    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/${src_dir})
    set(build_doc ${build_dir}/index.cache.bz2)

    # Create some place to store our files
    file(MAKE_DIRECTORY ${build_dir})

    #Bootstrap
    if (_kdoctoolsBootStrapping)
        set(_bootstrapOption "--srcdir=${KDocTools_BINARY_DIR}/src")
    else ()
        set(_bootstrapOption)
    endif ()
    set(_ssheet "${KDOCTOOLS_CUSTOMIZATION_DIR}/kde-chunk.xsl")

    file(GLOB src_docs ${src_dir}/*.docbook)

    add_custom_command(OUTPUT ${build_doc}
        COMMAND ${KDOCTOOLS_MEINPROC_EXECUTABLE} --check ${_bootstrapOption} --cache ${build_doc} ${src_doc}
        DEPENDS ${src_docs} ${_ssheet}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    create_target_name(_targ ${src_doc}-handbook)
    add_custom_target(${_targ} ALL DEPENDS ${build_doc})

    if(KDOCTOOLS_ENABLE_HTMLHANDBOOK)
        set(_htmlDoc ${CMAKE_CURRENT_SOURCE_DIR}/index.html)
        add_custom_command(OUTPUT ${_htmlDoc}
            COMMAND ${KDOCTOOLS_MEINPROC_EXECUTABLE} --check ${_bootstrapOption} -o ${_htmlDoc} ${_input}
            DEPENDS ${_input} ${_ssheet}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
        add_custom_target(htmlhandbook DEPENDS ${_htmlDoc})
    endif(KDOCTOOLS_ENABLE_HTMLHANDBOOK)

    set(installDest "${ARGS_INSTALL_DESTINATION}")
    if(installDest)
        set(subdir "${ARGS_SUBDIR}")
        file(GLOB images ${src_dir}/*.png)
        install(FILES ${build_doc} ${src_docs} ${images} DESTINATION ${installDest}/${subdir})
        # TODO symlinks on non-unix platforms
        if (UNIX)
            # execute some cmake code on make install which creates the symlink
            install(CODE "execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink \"${installDest}/common\" \"\$ENV{DESTDIR}${installDest}/${subdir}/common\" )" )
        endif (UNIX)
    endif()

endfunction()


function (kdoctools_create_manpage docbook section)
    # Parse arguments
    set(options)
    set(oneValueArgs INSTALL_DESTINATION)
    set(multiValueArgs)
    cmake_parse_arguments(ARGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Init vars
    get_filename_component(docbook ${docbook} ABSOLUTE)
    file(RELATIVE_PATH src_doc ${CMAKE_CURRENT_SOURCE_DIR} ${docbook})
    get_filename_component(src_dir ${src_doc} DIRECTORY)
    set(build_dir ${CMAKE_CURRENT_BINARY_DIR}/${src_dir})

    get_filename_component(name ${src_doc} NAME)
    string(REGEX REPLACE "^man-(.*)\\.${section}\\.docbook$" "\\1" name ${name})
    set(build_doc ${build_dir}/${name}.${section})

    # Create some place to store our files
    file(MAKE_DIRECTORY ${build_dir})

    #Bootstrap
    if (_kdoctoolsBootStrapping)
        set(_bootstrapOption "--srcdir=${KDocTools_BINARY_DIR}/src")
    else ()
        set(_bootstrapOption)
    endif ()
    set(_ssheet "${KDOCTOOLS_CUSTOMIZATION_DIR}/kde-include-man.xsl")

    add_custom_command(OUTPUT ${build_doc}
        COMMAND ${KDOCTOOLS_MEINPROC_EXECUTABLE} --stylesheet ${_ssheet} --check ${_bootstrapOption} ${CMAKE_CURRENT_SOURCE_DIR}/${src_doc}
        DEPENDS ${src_doc} ${_ssheet}
        WORKING_DIRECTORY ${build_dir}
    )

    create_target_name(_targ ${src_doc}-manpage)
    add_custom_target(${_targ} ALL DEPENDS "${build_doc}")

    if(ARGS_INSTALL_DESTINATION)
        install(FILES ${build_doc} DESTINATION ${ARGS_INSTALL_DESTINATION}/man${section})
    endif()
endfunction()


function(kdoctools_install podir)
    file(GLOB lang_dirs "${podir}/*")
    if (NOT MAN_INSTALL_DIR)
        set(MAN_INSTALL_DIR share/man)
    endif()
    if (NOT HTML_INSTALL_DIR)
        set(HTML_INSTALL_DIR share/doc/HTML)
    endif()
    foreach(lang_dir ${lang_dirs})
        get_filename_component(lang ${lang_dir} NAME)

        file(GLOB_RECURSE docbooks "${lang_dir}/docs/*.docbook")
        foreach(docbook ${docbooks})
            string(REGEX MATCH "\\.([0-9])\\.docbook" match ${docbook})
            if (match)
                kdoctools_create_manpage(${docbook} ${CMAKE_MATCH_1}
                    INSTALL_DESTINATION ${MAN_INSTALL_DIR}/${lang}
                )
            else()
                string(REGEX MATCH "docs/(.*)/.*.docbook" match ${docbook})
                if (match)
                    set(extra_args SUBDIR ${CMAKE_MATCH_1})
                endif()
                kdoctools_create_handbook(${docbook}
                    INSTALL_DESTINATION ${HTML_INSTALL_DIR}/${lang}
                    ${extra_args}
                )
            endif()
        endforeach()
    endforeach()
endfunction()
