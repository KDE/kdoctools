add_test(
  NAME meinproc_template
  COMMAND meinproc5 ${CMAKE_CURRENT_SOURCE_DIR}/../src/template.docbook
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

