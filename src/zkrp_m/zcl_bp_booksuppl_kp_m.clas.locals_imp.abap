CLASS lhc_zi_booksuppl_kp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booksuppl_kp_m~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zi_booksuppl_kp_m IMPLEMENTATION.

  METHOD calculateTotalPrice.

    DATA : lt_travel TYPE TABLE OF zi_travel_kp_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    lt_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).
    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    EXECUTE recalcTotPrice
    FROM CORRESPONDING #( lt_travel ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
