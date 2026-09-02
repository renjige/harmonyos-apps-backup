/** 内容影像 key → $r('app.media.*')；每个 seed coverMedia 独立映射 */
export class CourtMedia {
  static heroCourt(): Resource {
    return $r('app.media.hero_court')
  }

  static bannerToday(): Resource {
    return $r('app.media.banner_today')
  }

  static bannerHot(): Resource {
    return $r('app.media.banner_hot')
  }

  static byKey(key: string): Resource {
    if (key === 'hero_court') {
      return CourtMedia.heroCourt()
    }
    if (key === 'banner_today') {
      return CourtMedia.bannerToday()
    }
    if (key === 'banner_hot') {
      return CourtMedia.bannerHot()
    }
    if (key === 'cat_badminton') {
      return $r('app.media.cat_badminton')
    }
    if (key === 'cat_basketball') {
      return $r('app.media.cat_basketball')
    }
    if (key === 'cat_tennis') {
      return $r('app.media.cat_tennis')
    }
    if (key === 'cat_football') {
      return $r('app.media.cat_football')
    }
    if (key === 'cat_tabletennis') {
      return $r('app.media.cat_tabletennis')
    }
    if (key === 'venue_badminton_01') {
      return $r('app.media.venue_badminton_01')
    }
    if (key === 'venue_badminton_02') {
      return $r('app.media.venue_badminton_02')
    }
    if (key === 'venue_basketball_01') {
      return $r('app.media.venue_basketball_01')
    }
    if (key === 'venue_basketball_02') {
      return $r('app.media.venue_basketball_02')
    }
    if (key === 'venue_tennis_01') {
      return $r('app.media.venue_tennis_01')
    }
    if (key === 'venue_football_01') {
      return $r('app.media.venue_football_01')
    }
    if (key === 'venue_tabletennis_01') {
      return $r('app.media.venue_tabletennis_01')
    }
    if (key === 'venue_mixed_01') {
      return $r('app.media.venue_mixed_01')
    }
    if (key === 'promo_newuser') {
      return $r('app.media.promo_newuser')
    }
    if (key === 'promo_weekend') {
      return $r('app.media.promo_weekend')
    }
    if (key === 'case_weekend') {
      return $r('app.media.case_weekend')
    }
    if (key === 'case_nightball') {
      return $r('app.media.case_nightball')
    }
    if (key === 'service_ac_install') {
      return $r('app.media.venue_badminton_01')
    }
    if (key === 'service_repair') {
      return $r('app.media.venue_basketball_01')
    }
    if (key === 'service_cleaning') {
      return $r('app.media.venue_tennis_01')
    }
    if (key === 'service_smart') {
      return $r('app.media.venue_mixed_01')
    }
    if (key === 'service_furniture') {
      return $r('app.media.venue_football_01')
    }
    if (key === 'service_housekeeping') {
      return $r('app.media.venue_tabletennis_01')
    }
    if (key === 'service_water_heater') {
      return $r('app.media.venue_basketball_02')
    }
    if (key === 'service_aftersale') {
      return $r('app.media.venue_badminton_02')
    }
    if (key === 'cat_install') {
      return $r('app.media.cat_badminton')
    }
    if (key === 'cat_repair') {
      return $r('app.media.cat_basketball')
    }
    if (key === 'cat_clean') {
      return $r('app.media.cat_tennis')
    }
    if (key === 'cat_smart') {
      return $r('app.media.cat_football')
    }
    if (key === 'cat_furniture') {
      return $r('app.media.cat_tabletennis')
    }
    if (key === 'cat_housekeeping') {
      return $r('app.media.venue_mixed_01')
    }
    return CourtMedia.heroCourt()
  }
}
