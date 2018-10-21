# Encode an URI according to RFC 2396
# kdoctools_encode_uri takes a variable name and it encodes
# its value according to RFC 2396 (minus few reserved characters)
# overwriting the original value.
#
# Copyright (c) 2014 Luigi Toscano, <luigi.toscano@tiscali.it>
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

function(kdoctools_encode_uri _original_uri)
    find_package(Perl REQUIRED)
    find_package(PerlModules COMPONENTS URI::Escape REQUIRED)
    # properly encode the URI
    string(REPLACE "\"" "\\\"" escaped_uri "${${_original_uri}}")
    execute_process(COMMAND ${PERL_EXECUTABLE} -MURI::Escape -e "print uri_escape_utf8(\"${escaped_uri}\", \"^A-Za-z0-9\\-\\._~\\/:\");"
                    OUTPUT_VARIABLE encoded_uri
                    RESULT_VARIABLE res_encoding
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT ${res_encoding} EQUAL 0)
        message(FATAL_ERROR "Problem while encoding the URI ${${_original_uri}}")
    endif()
    set(${_original_uri} "${encoded_uri}" PARENT_SCOPE)
endfunction()
