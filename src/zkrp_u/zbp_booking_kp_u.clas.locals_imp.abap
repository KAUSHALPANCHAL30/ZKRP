CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Booking.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Booking.

    METHODS read FOR READ
      IMPORTING keys FOR READ Booking RESULT result.

    METHODS rba_Travel FOR READ
      IMPORTING keys_rba FOR READ Booking\_Travel FULL result_requested RESULT result LINK association_links.

    TYPES : tt_booking_failed   TYPE TABLE FOR FAILED zi_booking_kp_u,
            tt_booking_reported TYPE TABLE FOR REPORTED zi_booking_kp_u.
    METHODS map_messages
      IMPORTING
        cid          TYPE string OPTIONAL
        travel_id    TYPE /dmo/travel_id OPTIONAL
        booking_id   TYPE /dmo/booking_id OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_booking_failed
        reported     TYPE tt_booking_reported.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD update.

    DATA : booking  TYPE /dmo/booking,
           bookingx TYPE /dmo/s_booking_inx,
           messages TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>).

      booking = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).

      bookingx-_intx = CORRESPONDING #( <booking> MAPPING FROM ENTITY ).
      bookingx-booking_id = <booking>-BookingId.
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-TravelID )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-TravelID )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( bookingx ) )
        IMPORTING
          et_messages = messages.


      map_messages(
       EXPORTING
       cid       = <booking>-%cid_ref
       travel_id = <booking>-TravelID
       booking_id = <booking>-BookingId
       messages  = messages
       CHANGING
       failed   = failed-booking
       reported = reported-booking
       ).

    ENDLOOP.


  ENDMETHOD.

  METHOD delete.
    DATA : messages TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<booking>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = <booking>-TravelID )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <booking>-TravelID )
          it_booking  = VALUE /dmo/t_booking_in( ( booking_id = <booking>-BookingId ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( booking_id = <booking>-BookingId
                                                    action_code = /dmo/if_flight_legacy=>action_code-delete ) )
        IMPORTING
          et_messages = messages.


      map_messages(
       EXPORTING
       cid       = <booking>-%cid_ref
       travel_id = <booking>-TravelID
       booking_id = <booking>-BookingId
       messages  = messages
       CHANGING
       failed   = failed-booking
       reported = reported-booking
       ).

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.

    DATA : travel   TYPE /dmo/travel,
           messages TYPE /dmo/t_message.

    LOOP AT keys_Rba ASSIGNING FIELD-SYMBOL(<booking_by_travel>) GROUP BY <booking_by_travel>-TravelID.
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <booking_by_travel>-TravelID
        IMPORTING
          es_travel    = travel
          et_messages  = messages.

      map_messages(
        EXPORTING
          travel_id    = <booking_by_travel>-TravelID
          booking_id   = <booking_by_travel>-BookingId
          messages     = messages
         IMPORTING
          failed_added = DATA(failed_added)
         CHANGING
          failed       = failed-booking
          reported     = reported-booking ).

      IF failed_added = abap_false.
        LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<travel>) USING KEY entity WHERE TravelID = <booking_by_travel>-TravelID.
          INSERT VALUE #( source-%tky = <travel>-%tky
                          target-travelid = <travel>-TravelID ) INTO TABLE association_links.

          IF result_requested = abap_true.
            APPEND CORRESPONDING #( travel MAPPING TO ENTITY ) TO result.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDLOOP.

    SORT association_links BY target ASCENDING.
    DELETE ADJACENT DUPLICATES FROM association_links COMPARING ALL FIELDS.

    SORT result BY %tky ASCENDING.
    DELETE ADJACENT DUPLICATES FROM result COMPARING ALL FIELDS.

  ENDMETHOD.


  METHOD map_messages.
    failed_added = abap_false.

    LOOP AT messages INTO DATA(ls_msg).
      IF ls_msg-msgty = 'E' OR ls_msg-msgty = 'A'.
        APPEND VALUE #(  %cid = cid
                         travelid = travel_id
                         bookingid = booking_id
                         %fail-cause = zcl_travel_aux_kp_u=>get_cause_from_message(
                                                            msgid  = ls_msg-msgid
                                                            msgno  = ls_msg-msgno
*                                         is_dependend = abap_false
                                       )
        ) TO failed.

        failed_added = abap_true.

      ENDIF.

      reported = VALUE #( ( %cid = cid
                            travelid = travel_id
                            bookingid = booking_id
                            %msg = new_message(
                                     id       = ls_msg-msgid
                                     number   = ls_msg-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = ls_msg-msgv1
                                     v2       = ls_msg-msgv2
                                     v3       = ls_msg-msgv3
                                     v4       = ls_msg-msgv4
                                   ) ) ).


    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
