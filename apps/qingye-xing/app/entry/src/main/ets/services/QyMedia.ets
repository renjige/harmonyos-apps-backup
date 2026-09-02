export class QyMedia {
  static homeHero(): Resource {
    return $r('app.media.hero_forest_trail')
  }

  static paperBanner(): Resource {
    return $r('app.media.banner_morning_mist')
  }

  static teaBanner(): Resource {
    return $r('app.media.banner_valley_light')
  }

  static corridorHero(): Resource {
    return $r('app.media.hero_timeline_corridor')
  }

  static readingCover(): Resource {
    return $r('app.media.cover_park_walk')
  }

  static emptyLight(): Resource {
    return $r('app.media.empty_first_trail')
  }

  static coverOf(key: string): Resource {
    if (key === 'tea' || key === 'valley') {
      return QyMedia.teaBanner()
    }
    if (key === 'reading' || key === 'park') {
      return QyMedia.readingCover()
    }
    if (key === 'corridor' || key === 'trail') {
      return QyMedia.corridorHero()
    }
    if (key === 'window' || key === 'forest') {
      return QyMedia.homeHero()
    }
    if (key === 'wild' || key === 'observe') {
      return $r('app.media.cover_wild_observe')
    }
    if (key === 'city') {
      return $r('app.media.cover_city_roam')
    }
    if (key === 'empty') {
      return QyMedia.emptyLight()
    }
    return QyMedia.paperBanner()
  }
}
