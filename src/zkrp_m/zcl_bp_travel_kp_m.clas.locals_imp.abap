CLASS lsc_zi_travel_kp_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_kp_m IMPLEMENTATION.

  METHOD save_modified.
    DATA : lt_travel_log   TYPE STANDARD TABLE OF zkp_travel_log.
    DATA : lt_travel_log_c TYPE STANDARD TABLE OF zkp_travel_log.

    IF create-zi_travel_kp_m IS NOT INITIAL.
      lt_travel_log = CORRESPONDING #( create-zi_travel_kp_m ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
        <ls_travel_log>-changing_operation = 'CREATE'.
        GET TIME STAMP FIELD <ls_travel_log>-created_at.

        READ TABLE create-zi_travel_kp_m ASSIGNING FIELD-SYMBOL(<ls_travel>)
        WITH TABLE KEY entity
        COMPONENTS TravelId = <ls_travel_log>-travelid.
        IF sy-subrc = 0.

          IF <ls_travel>-%control-BookingFee = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'Booking Fee'.
            <ls_travel_log>-changed_value = <ls_travel>-BookingFee.
            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_c.
          ENDIF.

          IF <ls_travel>-%control-OverallStatus = cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'Overall Status'.
            <ls_travel_log>-changed_value = <ls_travel>-OverallStatus.
            TRY.
                <ls_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_travel_log> TO lt_travel_log_c.
          ENDIF.
        ENDIF.

      ENDLOOP.

      INSERT zkp_travel_log FROM TABLE @lt_travel_log_c.

    ENDIF.

    IF update-zi_travel_kp_m IS NOT INITIAL.
      CLEAR : lt_travel_log_c.
      lt_travel_log = CORRESPONDING #( update-zi_travel_kp_m ).

      LOOP AT update-zi_travel_kp_m ASSIGNING FIELD-SYMBOL(<ls_log_update>).
        ASSIGN lt_travel_log[ travelid = <ls_log_update>-TravelId ] TO FIELD-SYMBOL(<ls_log_u>).

        <ls_log_u>-changing_operation = 'UPDATE'.
        GET TIME STAMP FIELD <ls_log_u>-created_at.

        IF <ls_log_update>-%control-CustomerId = if_abap_behv=>mk-on.
          <ls_log_u>-changed_field_name = 'Customer Id'.
          <ls_log_u>-changed_value = <ls_log_update>-CustomerId.
          TRY.
              <ls_log_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          APPEND <ls_log_u> TO lt_travel_log_c.
        ENDIF.

        IF <ls_log_update>-%control-Description = if_abap_behv=>mk-on.
          <ls_log_u>-changed_field_name = 'Description'.
          <ls_log_u>-changed_value = <ls_log_update>-Description.
          TRY.
              <ls_log_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.

          APPEND <ls_log_u> TO lt_travel_log_c.
        ENDIF.


      ENDLOOP.

      INSERT zkp_travel_log FROM TABLE @lt_travel_log_c.
    ENDIF.


    IF delete-zi_travel_kp_m IS NOT INITIAL.
      CLEAR : lt_travel_log.
      lt_travel_log = CORRESPONDING #( delete-zi_travel_kp_m ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_log_del>).
        <ls_log_del>-changing_operation = 'DELETE'.
        GET TIME STAMP FIELD <ls_log_del>-created_at.
        TRY.
            <ls_log_u>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
            "handle exception
        ENDTRY.
      ENDLOOP.

      INSERT zkp_travel_log FROM TABLE @lt_travel_log.

    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_travel_kp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_kp_m RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_kp_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_kp_m~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_kp_m~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_kp_m~rejecttravel RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_kp_m RESULT result.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_kp_m~validatecustomer.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_kp_m~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_kp_m~validatestatus.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_kp_m~calculatetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_kp_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_kp_m.

ENDCLASS.

CLASS lhc_zi_travel_kp_m IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(lt_entities) = entities.
    DATA : lt_travel_kp_m TYPE TABLE FOR MAPPED zi_travel_kp_m,
           ls_travel_kp_m LIKE LINE OF lt_travel_kp_m.

    DELETE lt_entities WHERE travelid IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( lt_entities ) )
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lo_error).

        LOOP AT lt_entities INTO DATA(ls_entities).
          APPEND VALUE #( %cid = ls_entities-%cid
                          %key = ls_entities-%key ) TO failed-zi_travel_kp_m.

          APPEND VALUE #( %cid = ls_entities-%cid
                          %key = ls_entities-%key
                          %msg = lo_error ) TO reported-zi_travel_kp_m.

        ENDLOOP.
        EXIT.
    ENDTRY.

    ASSERT lv_qty = lines( lt_entities ).

    DATA(lv_curr_num) = lv_latest_num - lv_qty.

    LOOP AT lt_entities INTO ls_entities.

      lv_curr_num = lv_curr_num + 1.

      ls_travel_kp_m = VALUE #( %cid     = ls_entities-%cid
                                travelid = lv_curr_num ).

      APPEND ls_travel_kp_m TO mapped-zi_travel_kp_m.

*      append value #( %cid = ls_entities-%cid
*                      travelid = lv_curr_num ) to mapped-zi_travel_kp_m.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_booking.
    DATA : lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    BY \_booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>) GROUP BY <ls_group_entity>-travelid.
      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                FOR ls_link IN lt_link_data USING KEY entity
                                WHERE ( source-travelid = <ls_group_entity>-travelid )
                                NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-bookingid
                                                                    THEN ls_link-target-bookingid
                                                                    ELSE lv_max ) ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                 FOR ls_entity IN entities USING KEY entity
                                 WHERE ( travelid = <ls_group_entity>-travelid )
                                 FOR ls_booking IN ls_entity-%target
                                 NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-bookingid
                                                                    THEN ls_booking-bookingid
                                                                    ELSE lv_max ) ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>) USING KEY entity WHERE travelid = <ls_group_entity>-travelid.
        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
          APPEND CORRESPONDING #( <ls_booking> ) TO mapped-zi_booking_kp_m ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <ls_booking>-bookingid IS INITIAL.
            lv_max_booking += 10.
            <ls_new_map_book>-bookingid = lv_max_booking.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD copytravel.

    DATA : it_travel        TYPE TABLE FOR CREATE zi_travel_kp_m,
           it_booking_cba   TYPE TABLE FOR CREATE zi_travel_kp_m\_booking,
           it_booksuppl_cba TYPE TABLE FOR CREATE zi_booking_kp_m\_booksuppl.


    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_wo_cid>) WITH KEY %cid = ''.
    ASSERT <ls_wo_cid> IS NOT ASSIGNED.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_read)
    FAILED DATA(lt_failed).

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m BY \_booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_read )
    RESULT DATA(lt_booking_read).

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_booking_kp_m BY \_booksuppl
    ALL FIELDS WITH CORRESPONDING #( lt_booking_read )
    RESULT DATA(lt_booksuppl_read).

    LOOP AT lt_travel_read ASSIGNING FIELD-SYMBOL(<ls_travel_read>).
*      APPEND INITIAL LINE TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*      <ls_travel>-%cid = keys[ KEY entity travelid = <ls_travel_read>-travelid ]-%cid.
*      <ls_travel>-%data = CORRESPONDING #( <ls_travel_read> EXCEPT travelid ).

      APPEND VALUE #( %cid  = keys[ KEY entity travelid = <ls_travel_read>-travelid ]-%cid
                      %data = CORRESPONDING #( <ls_travel_read> EXCEPT travelid ) )
      TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-begindate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-enddate = cl_abap_context_info=>get_system_date( ) + 15.
      <ls_travel>-overallstatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel>-%cid ) TO it_booking_cba ASSIGNING FIELD-SYMBOL(<it_booking>).

      LOOP AT lt_booking_read ASSIGNING FIELD-SYMBOL(<ls_booking_read>)
                    USING KEY entity WHERE travelid = <ls_travel_read>-travelid.

        APPEND VALUE #( %cid  = <ls_travel>-%cid && <ls_booking_read>-bookingid
                        %data = CORRESPONDING #( <ls_booking_read> EXCEPT travelid ) )
        TO <it_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_new>).

        <ls_booking_new>-bookingstatus = 'N'.

        APPEND VALUE #( %cid_ref = <ls_booking_new>-%cid ) TO it_booksuppl_cba ASSIGNING FIELD-SYMBOL(<it_booksuppl>).

        LOOP AT lt_booksuppl_read ASSIGNING FIELD-SYMBOL(<ls_booksuppl_read>)
                                  USING KEY entity WHERE travelid  = <ls_travel_read>-travelid
                                                     AND bookingid = <ls_booking_read>-bookingid.

          APPEND VALUE #( %cid  = <ls_travel>-%cid && <ls_booking_read>-bookingid && <ls_booksuppl_read>-bookingsupplementid
*                          %data = CORRESPONDING #( <ls_booking_read> EXCEPT travelid bookingid ) )
                          %data = CORRESPONDING #( <ls_booksuppl_read> EXCEPT travelid bookingid ) )
          TO <it_booksuppl>-%target.



        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    CREATE FIELDS ( agencyid customerid begindate enddate bookingfee totalprice currencycode overallstatus description )
    WITH it_travel

    ENTITY zi_travel_kp_m
    CREATE BY \_booking
    FIELDS ( bookingid bookingdate customerid carrierid connectionid flightdate flightprice currencycode bookingstatus )
    WITH it_booking_cba

    ENTITY zi_booking_kp_m
    CREATE BY \_booksuppl
    FIELDS ( bookingsupplementid supplementid price currencycode )
    WITH it_booksuppl_cba

    MAPPED DATA(lt_mapped).

    mapped-zi_travel_kp_m = lt_mapped-zi_travel_kp_m.


  ENDMETHOD.

  METHOD accepttravel.
    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR ls_keys IN keys ( %tky          = ls_keys-%tky
                                        overallstatus = 'A' ) ).
*    REPORTED DATA(lt_travel).

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).
  ENDMETHOD.


  METHOD rejecttravel.
    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR ls_keys IN keys ( %tky          = ls_keys-%tky
                                        overallstatus = 'X' ) ).
*    REPORTED DATA(lt_travel).

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    FIELDS ( travelid overallstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                      ( %tky = ls_travel-%tky
                        %features-%action-accepttravel = COND #( WHEN ls_travel-overallstatus = 'A'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )

                        %features-%action-rejecttravel = COND #( WHEN ls_travel-overallstatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )

                        %features-%assoc-_booking =   COND #( WHEN ls_travel-overallstatus = 'X'
                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                 ELSE if_abap_behv=>fc-o-enabled )

                      ) ).

  ENDMETHOD.

  METHOD validatecustomer.

    READ ENTITY IN LOCAL MODE zi_travel_kp_m
    FIELDS ( customerid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = customerid ).

    DELETE lt_cust WHERE customer_id IS INITIAL.
    IF lt_cust IS NOT INITIAL.
      SELECT
      FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_cust
      WHERE customer_id = @lt_cust-customer_id
      INTO TABLE @DATA(lt_cust_db).
      IF sy-subrc = 0.
      ENDIF.
    ENDIF.

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-customerid IS INITIAL
      OR NOT line_exists( lt_cust_db[ customer_id = <ls_travel>-customerid ] ).

        APPEND VALUE #( %tky = <ls_travel>-%tky ) TO failed-zi_travel_kp_m.
        APPEND VALUE #( %tky                = <ls_travel>-%tky
                        %msg                = NEW /dmo/cm_flight_messages(
                        textid      = /dmo/cm_flight_messages=>customer_unkown
                        customer_id = <ls_travel>-customerid
                        severity    = if_abap_behv_message=>severity-error )
                        %element-customerid = if_abap_behv=>mk-on

                      ) TO reported-zi_travel_kp_m.


      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatedates.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    FIELDS ( begindate enddate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(travel).
      IF travel-enddate < travel-begindate.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_kp_m.
        APPEND VALUE #( %tky               = travel-%tky
                        %msg               = NEW /dmo/cm_flight_messages(
                        textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                        severity   = if_abap_behv_message=>severity-error
                        begin_date = travel-begindate
                        end_date   = travel-enddate
                        travel_id  = travel-travelid )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on

                      ) TO reported-zi_travel_kp_m.
      ELSEIF travel-begindate < cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_kp_m.

        APPEND VALUE #( %tky               = travel-%tky
                        %msg               = NEW /dmo/cm_flight_messages(
                        textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                        severity = if_abap_behv_message=>severity-error )
                        %element-begindate = if_abap_behv=>mk-on
                        %element-enddate   = if_abap_behv=>mk-on

        ) TO reported-zi_travel_kp_m.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatestatus.
    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    FIELDS ( overallstatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    LOOP AT lt_travel INTO DATA(travel).
      CASE travel-overallstatus.
        WHEN:'A'.
        WHEN:'X'.
        WHEN:'O'.
        WHEN OTHERS.
          APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_kp_m.

          APPEND VALUE #( %tky                   = travel-%tky
                          %msg                   = NEW /dmo/cm_flight_messages(
                          textid   = /dmo/cm_flight_messages=>status_invalid
                          severity = if_abap_behv_message=>severity-error
                          status   = travel-overallstatus )
                          %element-overallstatus = if_abap_behv=>mk-on ) TO reported-zi_travel_kp_m.
      ENDCASE.
    ENDLOOP.




  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    EXECUTE recalcTotPrice
    FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD recalctotprice.

    TYPES : BEGIN OF ty_total,
              price TYPE  /dmo/booking_fee,
              curr  TYPE /dmo/currency_code,
            END OF ty_total.

    DATA : lt_total TYPE TABLE OF ty_total.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).
    DELETE lt_travel WHERE CurrencyCode IS INITIAL.

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( lt_travel )
    RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_booking_kp_m BY \_BookSuppl
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( lt_ba_booking )
    RESULT DATA(lt_ba_booksuppl).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_total = VALUE #( ( price = <ls_Travel>-BookingFee curr = <ls_Travel>-CurrencyCode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<ls_booking>) USING KEY entity
                                            WHERE TravelId = <ls_travel>-TravelId
                                              AND CurrencyCode IS NOT INITIAL.

        APPEND VALUE #( price = <ls_booking>-FlightPrice curr = <ls_booking>-CurrencyCode ) TO lt_Total.


        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>) USING KEY entity
                                              WHERE TravelId = <ls_booking>-TravelId
                                                AND BookingId = <ls_booking>-BookingId
                                                AND CurrencyCode IS NOT INITIAL.

          APPEND VALUE #( price = <ls_booksuppl>-Price curr = <ls_booksuppl>-CurrencyCode ) TO lt_Total.


        ENDLOOP.

      ENDLOOP.

      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<ls_total>).

        IF <ls_total>-curr = <ls_travel>-CurrencyCode.
          DATA(lv_conv_price) = <ls_total>-price.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_total>-price
              iv_currency_code_source = <ls_total>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date(  )
            IMPORTING
              ev_amount               = lv_conv_price
          ).


        ENDIF.

        <ls_travel>-TotalPrice = <ls_travel>-TotalPrice + lv_conv_price.

      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_kp_m IN LOCAL MODE
    ENTITY zi_travel_kp_m
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ).

  ENDMETHOD.
ENDCLASS.
