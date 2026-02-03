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

*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR zi_travel_kp_m RESULT result.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_kp_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_kp_m.

ENDCLASS.

CLASS lhc_zi_travel_kp_m IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD get_global_authorizations.
*
*    result-%create = if_abap_behv=>auth-allowed.
*  ENDMETHOD.

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

  METHOD accepttravel.
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

  METHOD recalctotprice.
  ENDMETHOD.

  METHOD rejecttravel.
  ENDMETHOD.

ENDCLASS.
