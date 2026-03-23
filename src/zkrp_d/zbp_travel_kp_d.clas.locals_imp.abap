CLASS lhc_ZKP_TRAVEL_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zkp_travel_d RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zkp_travel_d RESULT result.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zkp_travel_d.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zkp_travel_d.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zkp_travel_d~accepttravel RESULT result.

    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION zkp_travel_d~deductdiscount RESULT result.

    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION zkp_travel_d~recalctotalprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zkp_travel_d~rejecttravel RESULT result.
    METHODS calctotprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zkp_travel_d~calctotprice.

    METHODS setstatusopen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zkp_travel_d~setstatusopen.

    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zkp_travel_d~settravelid.

ENDCLASS.

CLASS lhc_ZKP_TRAVEL_D IMPLEMENTATION.

  METHOD get_instance_authorizations.

    DATA : lv_update TYPE if_abap_behv=>t_xflag,
           lv_delete TYPE if_abap_behv=>t_xflag.

    READ ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_d
    FIELDS ( AgencyID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels)
    FAILED failed.

    CHECK lt_travels IS NOT INITIAL.
    SELECT FROM /dmo/a_travel_d AS a
    INNER JOIN /dmo/agency AS b
    ON a~agency_id = b~agency_id
    FIELDS a~travel_uuid, a~agency_id, b~country_code
    FOR ALL ENTRIES IN @lt_travels
    WHERE a~travel_uuid = @lt_travels-TravelUUID
    INTO TABLE @DATA(lt_country).

    LOOP AT lt_travels INTO DATA(ls_travels).

      READ TABLE lt_country INTO DATA(ls_country) WITH KEY travel_uuid = ls_travels-TravelUUID.
      IF sy-subrc = 0.
        IF requested_authorizations-%update = if_abap_behv=>mk-on.

          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
          ID '/DMO/CNTRY' FIELD ls_country-country_code
          ID 'ACTVT' FIELD '02'.

*          APPEND  VALUE #(  TravelUUID = ls_travels-TravelUUID
*                              %update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                                                  ELSE if_abap_behv=>auth-unauthorized ) ) TO result.

          lv_update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                                ELSE if_abap_behv=>auth-unauthorized ).

        ELSEIF requested_authorizations-%delete = if_abap_behv=>mk-on.
          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
          ID '/DMO/CNTRY' FIELD ls_country-country_code
          ID 'ACTVT' FIELD '06'.

          lv_delete = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                                ELSE if_abap_behv=>auth-unauthorized ).

          APPEND VALUE #( %tky = ls_travels-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                                  textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                  agency_id = ls_travels-AgencyID
                                                  severity = if_abap_behv_message=>severity-error )
                                                  %element-agencyid = if_abap_behv=>mk-on ) TO reported-zkp_travel_d.

        ENDIF.

        APPEND  VALUE #( TravelUUID = ls_travels-TravelUUID
                            %update = lv_update
                            %delete = lv_delete ) TO result.

      ELSE.

      ENDIF.

    ENDLOOP.

*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '01'.

  ENDMETHOD.

  METHOD get_global_authorizations.
*    IF requested_authorizations-%create = if_abap_behv=>mk-on.
*
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '01'.
*
*      result-%create = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                                 ELSE if_abap_behv=>auth-unauthorized ).
*
*    ELSEIF requested_authorizations-%update = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '02'.
*
*      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                                 ELSE if_abap_behv=>auth-unauthorized ).
*
*
*    ELSEIF requested_authorizations-%delete = if_abap_behv=>mk-on.
*      AUTHORITY-CHECK OBJECT '/DMO/TRVL'
*      ID '/DMO/CNTRY' DUMMY
*      ID 'ACTVT' FIELD '06'.
*
*      result-%update = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                                 ELSE if_abap_behv=>auth-unauthorized ).
*
*    ENDIF.
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
    DATA : lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    lt_agency = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING agency_id = AgencyID EXCEPT * ).

    CHECK lt_agency IS NOT INITIAL.

    SELECT FROM /dmo/agency
    FIELDS agency_id, country_code
    FOR ALL ENTRIES IN @lt_agency
    WHERE agency_id = @lt_agency-agency_id
    INTO TABLE @DATA(lt_ag_ct).
    IF sy-subrc = 0.

      LOOP AT entities INTO DATA(ls_entity).

        READ TABLE lt_ag_ct INTO DATA(ls_ag_ct) WITH KEY agency_id = ls_entity-AgencyID.
        IF sy-subrc = 0.
          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
          ID '/DMO/CNTRY' FIELD ls_ag_Ct-country_code
          ID 'ACTVT' FIELD '02'.
          IF sy-subrc <> 0.

            failed-zkp_travel_d = VALUE #( (  %tky = ls_entity-%tky ) ).

            APPEND VALUE #( %tky = ls_entity-%tky
                  %msg = NEW /dmo/cm_flight_messages(
                                          textid = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                          agency_id = ls_entity-AgencyID
                                          severity = if_abap_behv_message=>severity-error )
                                          %element-agencyid = if_abap_behv=>mk-on ) TO reported-zkp_travel_d.


          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD acceptTravel.

    "Modify travel instance
    MODIFY ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS (  OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'A' ) ).

    "Read changed data for action result
    READ ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    result = VALUE #( FOR travel IN lt_travels ( %tky   = travel-%tky
                                                 %param = travel ) ).
  ENDMETHOD.

  METHOD deductDiscount.
    DATA lt_travel_new TYPE TABLE FOR UPDATE zkp_travel_D.
    DATA lv_disc TYPE decfloat16.
    DATA(lt_keys) = keys.

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<ls_keys>) WHERE %param-discount IS INITIAL
                                                        AND ( %param-discount GT 100 OR  %param-discount LE 0 ).

      APPEND VALUE #( %tky = <ls_keys>-%tky ) TO failed-zkp_travel_d.

      APPEND VALUE #( %tky = <ls_keys>-%tky
                      %msg = NEW /dmo/cm_flight_messages(
                                         textid   = /dmo/cm_flight_messages=>discount_invalid
                                         severity = if_abap_behv_message=>severity-error )
                      %element-bookingfee = if_abap_behv=>mk-on
                      %action-deductdiscount = if_abap_behv=>mk-on
                    ) TO reported-zkp_travel_d.

      DELETE lt_keys.

    ENDLOOP.

    CHECK lt_keys IS NOT INITIAL.

    READ ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_D
    FIELDS ( BookingFee )
    WITH CORRESPONDING #( lt_keys )
    RESULT DATA(lt_travel).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_discount) = lt_keys[ KEY id %tky = <ls_travel>-%tky ]-%param-discount.
      lv_disc =  lv_discount / 100.
      DATA(lv_dic_book_fee) =  <ls_travel>-BookingFee - ( <ls_travel>-BookingFee * lv_disc ).

      APPEND VALUE #(  %tky = <ls_travel>-%tky
                                 BookingFee = lv_dic_book_fee )
                           TO lt_travel_new.
    ENDLOOP.

    MODIFY ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS ( BookingFee )
    WITH lt_travel_new.

    READ ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_d
    ALL FIELDS WITH CORRESPONDING #( lt_keys )
    RESULT DATA(lt_modified_travel).

    result = VALUE #( FOR ls_mo_travel IN lt_modified_travel ( %tky = ls_mo_travel-%tky
                                                               %param = ls_mo_travel )  ).

  ENDMETHOD.

  METHOD recalctotalprice.
    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: lt_amt_per_ccode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF Zkp_Travel_D IN LOCAL MODE
         ENTITY zkp_travel_d
            FIELDS ( BookingFee CurrencyCode )
            WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travels).

    DELETE lt_travels WHERE CurrencyCode IS INITIAL.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<travel>).
      " Set the start for the calculation by adding the booking fee.
      lt_amt_per_ccode = VALUE #( ( amount        = <travel>-BookingFee
                                           currency_code = <travel>-CurrencyCode ) ).

      " Read all associated bookings and add them to the total price.
      READ ENTITIES OF Zkp_Travel_D IN LOCAL MODE
        ENTITY zkp_travel_d BY \_Booking
          FIELDS ( FlightPrice CurrencyCode )
        WITH VALUE #( ( %tky = <travel>-%tky ) )
        RESULT DATA(lt_bookings).

      LOOP AT lt_bookings INTO DATA(booking) WHERE CurrencyCode IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) INTO lt_amt_per_ccode.
      ENDLOOP.

      " Read all associated booking supplements and add them to the total price.
      READ ENTITIES OF Zkp_Travel_D IN LOCAL MODE
        ENTITY zkp_booking_d BY \_BookingSupplement
          FIELDS ( BookSupplPrice CurrencyCode )
        WITH VALUE #( FOR rba_booking IN lt_bookings ( %tky = rba_booking-%tky ) )
        RESULT DATA(lt_bookingsupplements).

      LOOP AT lt_bookingsupplements INTO DATA(bookingsupplement) WHERE CurrencyCode IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = bookingsupplement-BookSupplPrice
                                                  currency_code = bookingsupplement-CurrencyCode ) INTO lt_amt_per_ccode.

      ENDLOOP.

      CLEAR <travel>-TotalPrice.
      LOOP AT lt_amt_per_ccode INTO DATA(single_amount_per_currencycode).
        " If needed do a Currency Conversion
        IF single_amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += single_amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
             EXPORTING
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <travel>-TotalPrice += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travels ).


  ENDMETHOD.

  METHOD rejectTravel.

    "Modify travel instance
    MODIFY ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS (  OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'X' ) ).

    "Read changed data for action result
    READ ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    result = VALUE #( FOR travel IN lt_travels ( %tky   = travel-%tky
                                                 %param = travel ) ).
  ENDMETHOD.

  METHOD calcTotPrice.

    MODIFY ENTITIES OF zkp_travel_d
    IN LOCAL MODE
    ENTITY zkp_travel_d
    EXECUTE recalctotalprice
    FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD setStatusOpen.
    READ ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_d
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DELETE lt_travel WHERE OverallStatus IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    MODIFY ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS (  OverallStatus )
    WITH VALUE #( FOR ls_travel IN lt_travel ( %tky = ls_travel-%tky
                                               OverallStatus = 'O' ) ).
  ENDMETHOD.

  METHOD setTravelId.
    READ ENTITIES OF zkp_travel_d IN LOCAL MODE
    ENTITY zkp_travel_d
    FIELDS ( TravelID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DELETE lt_travel WHERE travelid IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    SELECT FROM /dmo/a_travel_d
    FIELDS MAX( travel_id )
    INTO @DATA(lv_max_travelid).

    MODIFY ENTITIES OF Zkp_Travel_D IN LOCAL MODE
    ENTITY zkp_travel_d
    UPDATE FIELDS (  TravelID )
    WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO lv_index ( %tky = ls_travel-%tky
                                               TravelID = lv_max_travelid + lv_index ) ).



  ENDMETHOD.

ENDCLASS.
