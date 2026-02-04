@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Approver'
@Search.searchable: true
@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',

    title: { type: #STANDARD,
             label: 'Travel',
             value: 'TravelId' } }

define root view entity ZC_APP_TRAVEL_KP_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_KP_M
{
      @UI.facet: [{ id : 'Travel', purpose: #STANDARD, position : 10, label : 'Travel Detail', type:#IDENTIFICATION_REFERENCE },
              { id : 'Booking',purpose: #STANDARD, position : 20, label : 'Booking Detail', type:#LINEITEM_REFERENCE, targetElement: '_Booking' }]
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      @UI.identification: [{ position : 10 }]
      @Search.defaultSearchElement: true
      key TravelId,

      @UI : { lineItem: [{ position: 20, importance: #HIGH }],
              selectionField: [{ position: 20 }] }
      @UI.identification: [{ position : 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency', element: 'AgencyID' } }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      AgencyId,
      _Agency.Name       as AgencyName,

      @UI : { lineItem: [{ position: 30 }],
        selectionField: [{ position: 30 }]
      }
      @Search.defaultSearchElement: true
      @UI.identification: [{ position : 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,

      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position : 40 }]
      BeginDate,

      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position : 50 }]
      EndDate,

      @UI.identification: [{ position : 55 }]
      @UI.lineItem: [{ position: 56 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,

      @UI.identification: [{ position : 56, label: 'Total Price' }]
      @UI.lineItem: [{ position: 56 }]
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      CurrencyCode,

      @UI.identification: [{ position : 58 }]
      @UI.lineItem: [{ position: 58 }]
      Description,

      @UI.identification: [{ position : 70 },
                     { type:#FOR_ACTION, dataAction: 'acceptTravel', label : 'Accept Travel' },
                     { type:#FOR_ACTION, dataAction: 'rejectTravel', label : 'Reject Travel' }]
      @UI.textArrangement: #TEXT_ONLY
      @UI.selectionField: [{ position: 70 }]
      @UI.lineItem: [{ position: 15 },
               { type:#FOR_ACTION, dataAction: 'acceptTravel', label : 'Accept Travel' },
               { type:#FOR_ACTION, dataAction: 'rejectTravel', label : 'Reject Travel' }]
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' } }]
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,

      @UI.hidden: true
      _Status._Text.Text as OverallStatusText : localized,

      @UI.hidden: true
      CreatedBy,

      @UI.hidden: true
      CreatedAt,

      @UI.hidden: true
      LastChangedBy,

      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_APP_BOOKING_KP_M,
      _Currency,
      _Customer,
      _Status
}
