CLASS zcl_modify_practise DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_modify_practise IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    MODIFY ENTITY zi_travel_kp_m
*    CREATE FROM VALUE #(
*                  ( %cid               = 'cid1'
*                    %data-begindate    = '20262901'
*                    %control-begindate = if_abap_behv=>mk-on ) )
*
*    CREATE BY \_booking
*    FROM VALUE #( ( %cid_ref           = 'cid1'
*                    %target            = VALUE #( ( %cid                 = 'cid11'
*                                                    %data-bookingdate    = '20260129'
*                                                    %control-bookingdate = if_abap_behv=>mk-on ) )
*
*                  ) )
*        FAILED FINAL(it_failed)
*        MAPPED FINAL(it_mapped)
*        REPORTED FINAL(it_result).
*
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.
*
*
*    MODIFY ENTITY zi_travel_kp_m
*    DELETE FROM VALUE #( ( %key-travelid = '00111222' ) )
*    FAILED FINAL(it_failed1)
*    MAPPED FINAL(it_mapped1)
*    REPORTED FINAL(it_result1).
*
*
*    IF it_failed1 IS NOT INITIAL.
*      out->write( it_failed1 ).
*    ELSE.
*      COMMIT ENTITIES.
*    ENDIF.

*    MODIFY ENTITY zi_travel_kp_m
*    CREATE AUTO FILL CID WITH VALUE #( (
*                                       %data-begindate    = '20260202'
*                                       %control-begindate = if_abap_behv=>mk-on ) )
*    FAILED FINAL(it_failed)
*    MAPPED FINAL(it_mapped)
*    REPORTED FINAL(it_result).
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*        out->write( it_mapped ).
*      COMMIT ENTITIES.
*    ENDIF.


    MODIFY ENTITIES OF zi_travel_kp_m
    ENTITY zi_travel_kp_m
    UPDATE FIELDS ( begindate )
    WITH VALUE #(        ( %key-travelid = '00004330'
                           begindate     = '20260204' ) )

    ENTITY zi_travel_kp_m
    DELETE FROM VALUE #( ( travelid      = '00008882' ) ).

    COMMIT ENTITIES.


    MODIFY ENTITY zi_travel_kp_m
    UPDATE SET FIELDS WITH VALUE #( ( %key-TravelId = '00004330'
                                      BeginDate = '20260205' ) ).
    COMMIT ENTITIES.
*    FAILED FINAL(it_failed)
*    MAPPED FINAL(it_mapped)
*    REPORTED FINAL(it_result).
*    IF it_failed IS NOT INITIAL.
*      out->write( it_failed ).
*    ELSE.
*        out->write( it_mapped ).
*      COMMIT ENTITIES.
*    ENDIF.
  ENDMETHOD.
ENDCLASS.
