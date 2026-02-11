CLASS lhc_zi_booking_kp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_kp_m\_booksuppl.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_booking_kp_m RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_kp_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_zi_booking_kp_m IMPLEMENTATION.

  METHOD earlynumbering_cba_bookingsupp.
    DATA : max_booking_suppl_id TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_booking_kp_m
    BY \_booksuppl
    FROM CORRESPONDING #( entities )
    LINK DATA(booking_supplements).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.

      max_booking_suppl_id = REDUCE #( INIT lv_max = CONV /dmo/booking_supplement_id( '0' )
                                   FOR booksuppl IN booking_supplements USING KEY entity
                                   WHERE ( source-travelid = <booking_group>-travelid
                                     AND   source-bookingid = <booking_group>-bookingid )
                                   NEXT lv_max = COND /dmo/booking_supplement_id( WHEN booksuppl-target-bookingsupplementid > lv_max
                                                                                  THEN booksuppl-target-bookingsupplementid
                                                                                  ELSE lv_max )
                                   ).

      max_booking_suppl_id = REDUCE #( INIT lv_max = max_booking_suppl_id
                                    FOR entity IN entities USING KEY entity
                                    WHERE ( travelid = <booking_group>-travelid
                                      AND   bookingid = <booking_group>-bookingid )

                                    FOR target IN entity-%target
                                    NEXT lv_max = COND /dmo/booking_supplement_id( WHEN target-bookingsupplementid > lv_max
                                                                                   THEN target-bookingsupplementid
                                                                                   ELSE lv_max )

                                  ).
    ENDLOOP.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE travelid = <booking_group>-travelid
                                                                          AND bookingid = <booking_group>-bookingid.

      LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).

        APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-zi_booksuppl_kp_m ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).

        IF <booksuppl_wo_numbers>-bookingsupplementid IS INITIAL.
          max_booking_suppl_id += 1.

          <mapped_booksuppl>-bookingsupplementid = max_booking_suppl_id.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m BY \_booking
    FIELDS ( travelid bookingstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking).

    result = VALUE #( FOR ls_booking IN lt_booking
                      ( %tky = ls_booking-%tky

                        %features-%assoc-_booksuppl =   COND #( WHEN ls_booking-bookingstatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )

                      ) ).
  ENDMETHOD.

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
