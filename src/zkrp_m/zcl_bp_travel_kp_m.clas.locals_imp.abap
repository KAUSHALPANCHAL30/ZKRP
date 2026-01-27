CLASS lhc_zi_travel_kp_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_kp_m RESULT result.

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
  ENDMETHOD.

ENDCLASS.
