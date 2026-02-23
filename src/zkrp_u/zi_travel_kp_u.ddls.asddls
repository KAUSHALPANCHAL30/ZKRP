@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel root view entity'

define root view entity ZI_TRAVEL_KP_U
  as select from /dmo/travel as travel
  
  composition [0..*] of ZI_BOOKING_KP_U as _Booking 

  association [0..1] to /DMO/I_Agency            as _Agency   on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to I_Currency               as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _Status   on $projection.OverallStatus = _Status.OverallStatus

{
  key travel.travel_id     as TravelID,
      travel.agency_id     as AgencyID,
      travel.customer_id   as CustomerID,
      travel.begin_date    as BeginDate,
      travel.end_date      as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      travel.booking_fee   as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      travel.total_price   as TotalPrice,

      travel.currency_code as CurrencyCode,
      travel.description   as Description,
      travel.status        as OverallStatus,
      travel.lastchangedat as LastChangedAt,
      
      
      //Associations
      _Booking,
      _Agency,
      _Customer,
      _Currency,
      _Status



}
