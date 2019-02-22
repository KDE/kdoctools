# Try to find DocBook XML 4.x DTD.
# By default it will find version 4.5. A different version can be specified
# as parameter for find_package().
# Once done, it will define:
#
#  DocBookXML4_FOUND - system has the requested DocBook4 XML DTDs
#  DocBookXML4_DTD_VERSION - the version of requested DocBook4
#     XML DTD
#  DocBookXML4_DTD_DIR - the directory containing the definition of
#     the DocBook4 XML

# Copyright (c) 2010, 2014 Luigi Toscano, <luigi.toscano@tiscali.it>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.


if (NOT DocBookXML_FIND_VERSION)
     set(DocBookXML_FIND_VERSION "4.5")
endif ()

set (DocBookXML4_DTD_VERSION ${DocBookXML_FIND_VERSION}
     CACHE INTERNAL "Required version of DocBook4 XML DTDs")

include(FeatureSummary)
set_package_properties(DocBookXML4 PROPERTIES DESCRIPTION "DocBook XML 4"
                       URL "http://www.oasis-open.org/docbook/xml/${DocBookXML4_DTD_VERSION}"
                      )

function (locate_version version found_dir)

    set (DTD_PATH_LIST
        ${CMAKE_INSTALL_DATAROOTDIR}/xml/docbook/schema/dtd/${version}
        ${CMAKE_INSTALL_DATAROOTDIR}/xml/docbook/xml-dtd-${version}
        ${CMAKE_INSTALL_DATAROOTDIR}/sgml/docbook/xml-dtd-${version}
        ${CMAKE_INSTALL_DATAROOTDIR}/xml/docbook/${version}
        #for building on Mac with docbook installed by homebrew
        opt/docbook/docbook/xml/${version}
    )

    find_path (searched_dir docbookx.dtd
        PATHS ${CMAKE_SYSTEM_PREFIX_PATH}
        PATH_SUFFIXES ${DTD_PATH_LIST}
    )

    if (NOT searched_dir)
        # hacks for systems that use the package version in the DTD dirs,
        # e.g. Fedora, OpenSolaris
        set (DTD_PATH_LIST)
        foreach (DTD_PREFIX_ITER ${CMAKE_SYSTEM_PREFIX_PATH})
            file(GLOB DTD_SUFFIX_ITER RELATIVE ${DTD_PREFIX_ITER}
                ${DTD_PREFIX_ITER}/share/sgml/docbook/xml-dtd-${version}-*
            )
            if (DTD_SUFFIX_ITER)
                list (APPEND DTD_PATH_LIST ${DTD_SUFFIX_ITER})
            endif ()
        endforeach ()

        find_path (searched_dir docbookx.dtd
            PATHS ${CMAKE_SYSTEM_PREFIX_PATH}
            PATH_SUFFIXES ${DTD_PATH_LIST}
        )
    endif ()
    if (searched_dir)
        set (${found_dir} ${searched_dir} PARENT_SCOPE)
    else()
        message(WARNING "${found_dir}: Could not find docbookx.dtd in ${CMAKE_SYSTEM_PREFIX_PATH} with suffixes ${DTD_PATH_LIST}")
    endif()
endfunction()


locate_version (${DocBookXML4_DTD_VERSION} DocBookXML4_DTD_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args (DocBookXML4
    REQUIRED_VARS DocBookXML4_DTD_DIR DocBookXML4_DTD_VERSION
    FOUND_VAR DocBookXML4_FOUND)

mark_as_advanced (DocBookXML4_DTD_DIR DocBookXML4_DTD_VERSION)
