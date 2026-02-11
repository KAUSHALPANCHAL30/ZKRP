CLASS zcl_data_generator_kp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_generator_kp IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA : ls_wa  TYPE /dmo/oall_stat_t,
           ls_wa1 TYPE /dmo/oall_stat,
           ls_wa2 TYPE zkp_travel_m.


    DELETE FROM zkp_travel_m.
    DELETE FROM zkp_booking_m.
    DELETE FROM zkp_booksuppl_m.
    COMMIT WORK.

    INSERT zkp_travel_m FROM ( SELECT * FROM /dmo/travel_m ).
    INSERT zkp_booking_m FROM ( SELECT * FROM /dmo/booking_m ).
    INSERT zkp_booksuppl_m FROM ( SELECT * FROM /dmo/booksuppl_m ).
    COMMIT WORK.

    ls_wa-overall_status = 'N'.
    ls_wa-language = 'E'.
    ls_wa-text = 'New'.

    INSERT INTO /dmo/oall_stat_t VALUES @ls_wa.
    ls_wa1-client = '100'.
    ls_wa1-overall_status = 'N'.

    INSERT INTO /dmo/oall_stat VALUES @ls_wa1.
    COMMIT WORK.
*    select single *
*    from zkp_travel_m
*    where travel_id = '00004328'
*    into @ls_wa2.
*    if sy-subrc = 0.
*      ls_wa2-begin_date = '20260129'.
*      modify zkp_travel_m from @ls_wa2.
*      commit work.
*    endif.
*    out->write( 'Travel and booking demo data inserted.' ).
  ENDMETHOD.
ENDCLASS.
