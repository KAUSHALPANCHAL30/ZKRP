CLASS zcl_read_practise DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_practise IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.


*   Shoft form READ entity
*    READ ENTITY zi_travel_kp_m
*    FROM VALUE #( ( %key-travelid = '0000004150'
*                    %control      = VALUE #( agencyid   = if_abap_behv=>mk-on
*                                             customerid = if_abap_behv=>mk-on
*                                             begindate  = if_abap_behv=>mk-on ) ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*
*    IF lt_failed_short IS NOT INITIAL.
*      out->write( 'Read Failed' ).
*    ELSE.
*      out->write( lt_result_short ).
*    ENDIF.

*     Read entity with selected fields
*    READ ENTITY zi_travel_kp_m
*    FIELDS ( agencyid createdat customerid bookingfee )
*    WITH VALUE #( ( %key-travelid = '0000004150' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*   Read entity with all fields
*    READ ENTITY zi_travel_kp_m
*    ALL FIELDS
*    WITH VALUE #( ( %key-travelid = '0000004150' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*Read entity with Association
*    READ ENTITY zi_travel_kp_m
*    BY \_booking
*    ALL FIELDS
*    WITH VALUE #( ( %key-travelid = '0000000002' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*Read entity Long Form
    READ ENTITIES OF zi_travel_kp_m
    ENTITY zi_travel_kp_m
    ALL FIELDS WITH VALUE #( ( %key-travelid  = '0000000002' ) )
    RESULT DATA(lt_result_short)

    ENTITY zi_booking_kp_m
    ALL FIELDS WITH VALUE #( ( %key-travelid  = '0000000002'
                               %key-bookingid = '0002' ) )
    RESULT DATA(lt_booking)
    FAILED DATA(lt_failed_short).
    IF lt_failed_short IS NOT INITIAL.
      out->write( 'Read Failed' ).
    ELSE.
      out->write( lt_result_short ).
      out->write( lt_booking ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
