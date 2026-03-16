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

ENDCLASS.
