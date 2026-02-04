@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Approver projection'
@Search.searchable: true
@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: { type: #STANDARD, label: 'Booking', value: 'BookingId' } }

define view entity ZC_APP_BOOKING_KP_M
  as projection on ZI_BOOKING_KP_M
{
      @UI.facet: [{ id : 'Booking', purpose: #STANDARD, position : 10, label : 'Booking Detail', type:#IDENTIFICATION_REFERENCE }]
      @Search.defaultSearchElement: true
      @UI.identification: [{ position : 10 }]
  key TravelId,
      @UI:{ lineItem: [{ position: 20, importance: #HIGH }],
            identification : [{ position: 20 }] }
      @Search.defaultSearchElement: true

  key BookingId,
      @UI:{ lineItem: [{ position: 30, importance: #HIGH }],
            identification : [{ position: 30 }] }
      BookingDate,
      @UI : { lineItem: [{ position: 40 }],
      selectionField: [{ position: 40 }]
      }
      @Search.defaultSearchElement: true
      @UI.identification: [{ position : 40 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,

      @UI:{ lineItem: [{ position: 50, importance: #HIGH }],
            identification : [{ position: 50 }] }
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name      as CarrierName,

      @UI:{ lineItem: [{ position: 60, importance: #HIGH }],
      identification : [{ position: 60 }] }
      ConnectionId,

      @UI:{ lineItem: [{ position: 70, importance: #HIGH }],
      identification : [{ position: 70 }] }
      FlightDate,

      @UI:{ lineItem: [{ position: 80, importance: #HIGH }],
      identification : [{ position: 80 }] }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,

      @UI.identification: [{ position : 90 }]
      @UI.lineItem: [{ position: 90 }]
      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' } }]
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _Status._Text.Text as BookingStatusText : localized,

      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _BookSuppl,
      _Carrier,
      _connection,
      _Currency,
      _Customer,
      _Status,
      _Travel : redirected to parent ZC_APP_TRAVEL_KP_M
}
