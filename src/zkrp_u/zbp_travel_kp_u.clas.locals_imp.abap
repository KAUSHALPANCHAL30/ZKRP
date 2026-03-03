CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Travel.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Travel.

    METHODS read FOR READ
      IMPORTING keys FOR READ Travel RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Travel.

    METHODS rba_Booking FOR READ
      IMPORTING keys_rba FOR READ Travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
      IMPORTING entities_cba FOR CREATE Travel\_Booking.

    TYPES : tt_failed   TYPE TABLE FOR FAILED  zi_travel_kp_u\\Travel,
            tt_reported TYPE TABLE FOR REPORTED zi_travel_kp_u\\travel.

    METHODS map_messages
      IMPORTING
        cid          TYPE abp_behv_cid   OPTIONAL
        travel_id    TYPE /dmo/travel_id OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_failed
        reported     TYPE tt_reported.

    TYPES : tt_booking_failed   TYPE TABLE FOR FAILED  zi_booking_kp_u,
            tt_booking_reported TYPE TABLE FOR REPORTED zi_booking_kp_u.

    METHODS map_messages_assoc_to_booking
      IMPORTING
        cid          TYPE string
        is_dependend TYPE abap_bool DEFAULT abap_false
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        failed       TYPE tt_booking_failed
        reported     TYPE tt_booking_reported.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_kp_u IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travel_read_results)
    FAILED failed.

    result = VALUE #( FOR travel_read_result IN travel_read_results (
                                          %tky = travel_read_result-%tky
                                          %assoc-_Booking = COND #( WHEN travel_read_result-OverallStatus = 'B' OR travel_read_result-OverallStatus = 'X'
                                                                    THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled ) ) ).


  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA : ls_travel_in    TYPE /dmo/travel,
           ls_travel_out   TYPE /dmo/travel,
           lv_failed_added TYPE abap_boolean,
           lt_messages     TYPE /dmo/t_message.


    LOOP AT entities INTO DATA(ls_entity).

      ls_travel_in = CORRESPONDING #( ls_entity MAPPING FROM ENTITY USING CONTROL ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
          et_messages       = lt_messages.


      map_messages(
       EXPORTING
       cid = ls_entity-%cid
       messages = lt_messages
       IMPORTING
       failed_added = lv_failed_added
       CHANGING
       failed = failed-travel
       reported = reported-travel
       ).

      IF lv_failed_added = abap_false.

        INSERT VALUE #( %cid = ls_entity-%cid
                        TravelID = ls_travel_out-travel_id )  INTO TABLE mapped-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD update.
    DATA : ls_travel_in TYPE /dmo/travel,
           ls_travelx   TYPE /dmo/s_travel_inx,
           lt_messages  TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_update>).

      ls_travel_in = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      ls_travelx-travel_id = <travel_update>-TravelID.
      ls_travelx-_intx = CORRESPONDING #( <travel_update> MAPPING FROM ENTITY ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
          is_travelx  = ls_travelx
        IMPORTING
          et_messages = lt_messages.


      map_messages(
       EXPORTING
       cid       = <travel_update>-%cid_ref
       travel_id = <travel_update>-TravelID
       messages  = lt_messages
       CHANGING
       failed   = failed-travel
       reported = reported-travel
       ).

    ENDLOOP.


  ENDMETHOD.

  METHOD delete.
    DATA : lt_messages  TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <ls_keys>-TravelID
        IMPORTING
          et_messages  = lt_messages.


      map_messages(
       EXPORTING
       cid       = <ls_keys>-%cid_ref
       travel_id = <ls_keys>-TravelID
       messages  = lt_messages
       CHANGING
       failed   = failed-travel
       reported = reported-travel
       ).

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    DATA : ls_travel_out TYPE /dmo/travel,
           lt_messages   TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>) GROUP BY <ls_keys>-%tky.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <ls_keys>-TravelID
        IMPORTING
          es_travel    = ls_travel_out
          et_messages  = lt_messages.


      map_messages(
       EXPORTING
       travel_id = <ls_keys>-TravelID
       messages  = lt_messages
       IMPORTING
       failed_added = DATA(failed_added)
       CHANGING
       failed   = failed-travel
       reported = reported-travel
       ).

      IF failed_added = abap_false.
        INSERT CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ) INTO TABLE result.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD lock.

    TRY.
        DATA(lr_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = '/DMO/ETRAVEL' ).
      CATCH cx_abap_lock_failure INTO DATA(lo_lock_fail).

        RAISE SHORTDUMP lo_lock_fail.
    ENDTRY.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      TRY.
          lr_lock->enqueue(
          it_parameter  = VALUE #( ( name = 'TRAVEL_ID' value = REF #( <ls_keys>-travelid ) ) )
          ).

        CATCH cx_abap_foreign_lock INTO DATA(lr_fo_lock).
        CATCH cx_abap_lock_failure INTO lo_lock_fail.
          map_messages(
            EXPORTING
              travel_id    = <ls_keys>-TravelID
              messages     = VALUE #( ( msgid = '/DMO/CM_FLIGHT_LEGAC'
                                        msgty = 'E'
                                        msgno = '032'
                                        msgv1 = <ls_keys>-TravelID
                                        msgv2 = lr_fo_lock->user_name ) )
            CHANGING
              failed       = failed-travel
              reported     = reported-travel
          ).

          "handle exception
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.

  METHOD rba_Booking.
  ENDMETHOD.

  METHOD cba_Booking.
    DATA : booking_old     TYPE /dmo/t_booking,
           booking         TYPE /dmo/booking,
           last_booking_id TYPE /dmo/booking_id VALUE '0',
           messages        TYPE /dmo/t_message.


    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<travel>).

      DATA(travelid) = <travel>-TravelID.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = travelid
        IMPORTING
          et_booking   = booking_old
          et_messages  = messages.

      map_messages(
        EXPORTING
          cid          = <travel>-%cid_ref
          travel_id    = <travel>-TravelID
          messages     = messages
        IMPORTING
        failed_added   = DATA(failed_added)
        CHANGING
          failed       = failed-travel
          reported     = reported-travel
      ).

      IF failed_added EQ abap_true.
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking>).
          map_messages_assoc_to_booking(
          EXPORTING
            cid          = <booking>-%cid
            is_dependend = abap_true
            messages     = messages
          CHANGING
            failed       = failed-booking
            reported     = reported-booking ).
        ENDLOOP.
      ELSE.
        last_booking_id = VALUE #( booking_old[ lines( booking_old ) ]-booking_id OPTIONAL ).

        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_create>).

          booking = CORRESPONDING #(  <booking_create> MAPPING FROM ENTITY USING CONTROL ).

          last_booking_id += 1.
          booking-booking_id = last_booking_id.

          CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
            EXPORTING
              is_travel   = VALUE /dmo/s_travel_in( travel_id = travelid )
              is_travelx  = VALUE /dmo/s_travel_inx( travel_id = travelid )
              it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
              it_bookingx = VALUE /dmo/t_booking_inx(
                                            ( booking_id = booking-booking_id
                                              action_code = /dmo/if_flight_legacy=>action_code-create ) )
            IMPORTING
              et_messages = messages.

          map_messages_assoc_to_booking(
            EXPORTING
              cid          = <booking_create>-%cid
              messages     = messages
            IMPORTING
              failed_added = failed_added
            CHANGING
              failed       = failed-booking
              reported     = reported-booking ).
*
          IF failed_added = abap_false.
            INSERT VALUE #( %cid = <booking_create>-%cid
                            travelid = travelid
                            bookingid = booking-booking_id ) INTO TABLE mapped-booking.
          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD map_messages.
    failed_added = abap_false.

    LOOP AT messages INTO DATA(ls_msg).
      IF ls_msg-msgty = 'E' OR ls_msg-msgty = 'A'.
        APPEND VALUE #(  %cid = cid
                         travelid = travel_id
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

  METHOD map_messages_assoc_to_booking.
    ASSERT cid IS NOT INITIAL.
    failed_added = abap_false.

    LOOP AT messages INTO DATA(ls_msg).
      IF ls_msg-msgty = 'E' OR ls_msg-msgty = 'A'.
        APPEND VALUE #(  %cid = cid
                         %fail-cause = /dmo/cl_travel_auxiliary=>get_cause_from_message(
                                                            msgid  = ls_msg-msgid
                                                            msgno  = ls_msg-msgno
                                                            is_dependend = is_dependend
                                       )
        ) TO failed.

        failed_added = abap_true.

      ENDIF.

      APPEND VALUE #( %cid = cid
                      %msg = new_message(
                                     id       = ls_msg-msgid
                                     number   = ls_msg-msgno
                                     severity = if_abap_behv_message=>severity-error
                                     v1       = ls_msg-msgv1
                                     v2       = ls_msg-msgv2
                                     v3       = ls_msg-msgv3
                                     v4       = ls_msg-msgv4 ) ) TO reported.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
