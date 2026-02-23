@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Unmanaged'

define view entity ZI_BOOKING_KP_U
  as select from /dmo/booking as Booking

  association        to parent ZI_TRAVEL_KP_U as _Travel     on $projection.TravelID = _Travel.TravelID

  association [1..1] to /DMO/I_Carrier        as _Carrier    on $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Customer       as _Customer   on $projection.CustomerId = _Customer.CustomerID
  association [1..*] to /DMO/I_Connection     as _connection on $projection.CarrierId = _connection.AirlineID


{
  key Booking.travel_id     as TravelID,
  key Booking.booking_id    as BookingId,
      Booking.booking_date  as BookingDate,
      Booking.customer_id   as CustomerId,
      Booking.carrier_id    as CarrierId,
      Booking.connection_id as ConnectionId,
      Booking.flight_date   as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Booking.flight_price  as FlightPrice,
      Booking.currency_code as CurrencyCode,

      //Associations
      _Travel,
      _Carrier,
      _Customer,
      _connection

}
