@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Booking'

@Metadata.allowExtensions: true

define view entity ZC_BOOKING_KP_U as projection on ZI_BOOKING_KP_U
{
    key TravelID,
    key BookingId,
    BookingDate,
    @ObjectModel.text: { element: [ 'CustomerName' ]  }
    CustomerId,
    _Customer.LastName as CustomerName,
    @ObjectModel.text: { element: [ 'CarrierName' ]  }
    CarrierId,
    _Carrier.Name      as CarrierName,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    /* Associations */
    _Carrier,
    _connection,
    _Customer,
    _Travel : redirected to parent ZC_TRAVEL_KP_U
}
