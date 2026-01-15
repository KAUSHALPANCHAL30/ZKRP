@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement projection view'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPPL_KP_M
  as projection on ZI_BOOKSUPPL_KP_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text: {
          element: [ 'SupplementDesc' ]  }

      SupplementId,
      _SupplementText.Description as SupplementDesc : localized,
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_BOOKING_KP_M,
      _Currency,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZC_TRAVEL_KP_M
}
