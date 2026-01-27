@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking projection view'
@Metadata.allowExtensions: true

define view entity ZC_BOOKING_KP_M
  as projection on ZI_BOOKING_KP_M
{
  key TravelId,
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
      @ObjectModel.text: { element: [ 'BookingStatusText' ]  }
      BookingStatus,
      _Status._Text.Text as BookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _BookSuppl : redirected to composition child ZC_BOOKSUPPL_KP_M,
      _Carrier,
      _connection,
      _Currency,
      _Customer,
      _Status,
      _Travel    : redirected to parent ZC_TRAVEL_KP_M
}
