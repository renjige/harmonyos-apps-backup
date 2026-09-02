export class TravelMedia {
  static cover(key: string): Resource {
    if (key === 'travel_family_holiday' || key === 'travel_checklist') {
      return $r('app.media.travel_checklist')
    }
    if (key === 'travel_business_trip' || key === 'travel_route') {
      return $r('app.media.travel_route')
    }
    return $r('app.media.travel_hero')
  }
}
