# Encode an URI according to RFC 2396
# kdoctools_encode_uri takes a variable name and it encodes
# its value according to RFC 2396 (minus few reserved characters)
# overwriting the original value.
#
# Copyright (c) 2014 Luigi Toscano, <luigi.toscano@tiscali.it>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

function(kdoctools_encode_uri _original_uri)
    find_package(Perl REQUIRED)
    # properly encode the URI
    string(REPLACE "\"" "\\\"" escaped_uri "${${_original_uri}}")
    execute_process(COMMAND perl -MURI::Escape -e "print uri_escape_utf8(\"${escaped_uri}\", \"^A-Za-z0-9\\-\\._~\\/\");"
                    OUTPUT_VARIABLE encoded_uri
                    RESULT_VARIABLE res_encoding
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT ${res_encoding} EQUAL 0)
        message(FATAL_ERROR "Problem while encoding the URI ${${_original_uri}}")
    endif()
    set(${_original_uri} "${encoded_uri}" PARENT_SCOPE)
endfunction()
