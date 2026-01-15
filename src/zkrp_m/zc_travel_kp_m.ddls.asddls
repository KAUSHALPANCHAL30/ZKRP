@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Projection view'
@Metadata.allowExtensions: true
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_TRAVEL_KP_M
  provider contract transactional_query
  as projection on ZI_TRAVEL_KP_M
{
  key TravelId,
      @ObjectModel.text: { element: [ 'AgencyName' ]  }
      AgencyId,
      _Agency.Name        as AgencyName,
      @ObjectModel.text: { element: [ 'CustomerName' ]  }
      CustomerId,
      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      Description,
      @ObjectModel.text: { element: [ 'OverallStatusText' ]  }
      OverallStatus,
      _Status._Text.Text  as OverallStatusText : localized,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_KP_M,
      _Currency,
      _Customer,
      _Status
}
