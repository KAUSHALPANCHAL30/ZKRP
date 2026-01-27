@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking View'

define view entity ZI_BOOKING_KP_M
  as select from zkp_booking_m

  association        to parent ZI_TRAVEL_KP_M    as _Travel     on $projection.TravelId = _Travel.TravelId
  composition [0..*] of ZI_BOOKSUPPL_KP_M        as _BookSuppl
  association [1..1] to /DMO/I_Carrier           as _Carrier    on $projection.CarrierId = _Carrier.AirlineID
  association [1..1] to /DMO/I_Customer          as _Customer   on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to I_Currency               as _Currency   on $projection.CurrencyCode = _Currency.Currency
  association [1..*] to /DMO/I_Connection        as _connection on $projection.CarrierId = _connection.AirlineID
  association [0..1] to /DMO/I_Overall_Status_VH as _Status     on $projection.BookingStatus = _Status.OverallStatus

{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at as LastChangedAt,

      //Associations
      _Travel,
      _BookSuppl,
      _Carrier,
      _Customer,
      _Currency,
      _connection,
      _Status
}
