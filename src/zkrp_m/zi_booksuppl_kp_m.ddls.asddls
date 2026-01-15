@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BOOKSUPPL_KP_M
  as select from zkp_booksuppl_m
  association        to parent ZI_BOOKING_KP_M as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                  and $projection.BookingId = _Booking.BookingId
  association [1..1] to ZI_TRAVEL_KP_M         as _Travel         on  $projection.TravelId = _Travel.TravelId 
  association [1..1] to I_Currency             as _Currency       on  $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Supplement      as _Supplement     on  $projection.BookingSupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText  as _SupplementText on  $projection.BookingSupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      last_changed_at       as LastChangedAt,
      // Associations
      _Travel,
      _Booking,
      _Supplement,
      _SupplementText,
      _Currency

}
