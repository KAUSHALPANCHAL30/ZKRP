CLASS lhc_zi_booking_kp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_kp_m\_booksuppl.

ENDCLASS.

CLASS lhc_zi_booking_kp_m IMPLEMENTATION.

  METHOD earlynumbering_cba_bookingsupp.
  ENDMETHOD.


ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
