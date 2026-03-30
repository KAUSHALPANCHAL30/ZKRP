CLASS lhc_ZKP_BOOKING_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zkp_booking_d~validateCustomer.

ENDCLASS.

CLASS lhc_ZKP_BOOKING_D IMPLEMENTATION.
  METHOD validateCustomer.
    READ ENTITIES OF zkp_Travel_D IN LOCAL MODE
         ENTITY zkp_booking_d
         FIELDS ( CustomerID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(bookings).

    READ ENTITIES OF zkp_Travel_D IN LOCAL MODE
         ENTITY zkp_booking_d BY \_Travel
         FROM CORRESPONDING #( bookings )
         LINK DATA(travel_booking_links).

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    " Optimization of DB select: extract distinct non-initial customer IDs
    customers = CORRESPONDING #( bookings DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.
      " Check if customer ID exists
      SELECT FROM /dmo/customer
        FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        WHERE customer_id = @customers-customer_id
        INTO TABLE @DATA(valid_customers).
    ENDIF.

    " Raise message for non existing customer id
    LOOP AT bookings INTO DATA(booking).
      APPEND VALUE #( %tky        = booking-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-zkp_booking_d.

      IF booking-CustomerID IS INITIAL.
        APPEND VALUE #( %tky = booking-%tky ) TO failed-zkp_booking_d.

        APPEND VALUE #(
            %tky                = booking-%tky
            %state_area         = 'VALIDATE_CUSTOMER'
            %msg                = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                               severity = if_abap_behv_message=>severity-error )
            %path               = VALUE #( zkp_Travel_D-%tky = travel_booking_links[ KEY id source-%tky = booking-%tky ]-target-%tky )
            %element-CustomerID = if_abap_behv=>mk-on )
               TO reported-zkp_booking_d.

      ELSEIF booking-CustomerID IS NOT INITIAL AND NOT line_exists( valid_customers[
                                                                        customer_id = booking-CustomerID ] ).
        APPEND VALUE #( %tky = booking-%tky ) TO failed-zkp_booking_d.

        APPEND VALUE #(
            %tky                = booking-%tky
            %state_area         = 'VALIDATE_CUSTOMER'
            %msg                = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>customer_unkown
                                                               customer_id = booking-customerId
                                                               severity    = if_abap_behv_message=>severity-error )
            %path               = VALUE #( zkp_Travel_D-%tky = travel_booking_links[ KEY id source-%tky = booking-%tky ]-target-%tky )
            %element-CustomerID = if_abap_behv=>mk-on )
               TO reported-zkp_booking_d.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
