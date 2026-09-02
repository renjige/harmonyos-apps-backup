export class XdMedia {
  static homeHero(): Resource {
    return $r('app.media.hero_island_mist')
  }

  static paperBanner(): Resource {
    return $r('app.media.banner_slow_evening')
  }

  static momentBanner(): Resource {
    return $r('app.media.banner_moment_glow')
  }

  static corridorHero(): Resource {
    return $r('app.media.hero_corridor_sea')
  }

  static readingCover(): Resource {
    return $r('app.media.cover_theme_read')
  }

  static travelCover(): Resource {
    return $r('app.media.cover_theme_travel')
  }

  static emptyLight(): Resource {
    return $r('app.media.empty_shore')
  }

  static coverOf(key: string): Resource {
    if (key === 'travel') {
      return XdMedia.travelCover()
    }
    if (key === 'reading') {
      return XdMedia.readingCover()
    }
    if (key === 'corridor') {
      return XdMedia.corridorHero()
    }
    if (key === 'island' || key === 'window') {
      return XdMedia.homeHero()
    }
    if (key === 'empty') {
      return XdMedia.emptyLight()
    }
    if (key === 'moment' || key === 'tea') {
      return XdMedia.momentBanner()
    }
    return XdMedia.paperBanner()
  }
}
