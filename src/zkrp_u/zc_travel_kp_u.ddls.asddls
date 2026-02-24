@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel root consumption view'

@Metadata.allowExtensions: true

define root view entity ZC_TRAVEL_KP_U
  provider contract transactional_query
  as projection on ZI_TRAVEL_KP_U
{

  key TravelID,
      @ObjectModel.text: { element: [ 'AgencyName' ]  }

      AgencyID,
      _Agency.Name       as AgencyName,
     
      @ObjectModel.text: { element: [ 'CustomerName' ]  }

      CustomerID,
      _Customer.LastName as CustomerName,
     
      BeginDate,
     
      EndDate,
     
      BookingFee,
     
      TotalPrice,


      CurrencyCode,
     
      Description,
     
      @ObjectModel.text: { element: [ 'OverallStatusText' ]  }
      OverallStatus,
     
      _Status._Text.Text as OverallStatusText : localized,
     
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_KP_U,
      _Currency,
      _Customer,
      _Status
}
