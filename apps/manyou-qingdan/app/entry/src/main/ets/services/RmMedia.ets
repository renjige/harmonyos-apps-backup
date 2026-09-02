export class RmMedia {
  static homeHero(): Resource {
    return $r('app.media.hero_sky_path')
  }

  static paperBanner(): Resource {
    return $r('app.media.ambient_morning')
  }

  static teaBanner(): Resource {
    return $r('app.media.theme_food')
  }

  static corridorHero(): Resource {
    return $r('app.media.hero_sky_path')
  }

  static readingCover(): Resource {
    return $r('app.media.theme_read')
  }

  static cityCover(): Resource {
    return $r('app.media.theme_city')
  }

  static emptyLight(): Resource {
    return $r('app.media.ambient_morning')
  }

  static coverOf(key: string): Resource {
    if (key === 'food' || key === 'valley' || key === 'tea') {
      return RmMedia.teaBanner()
    }
    if (key === 'read' || key === 'reading') {
      return RmMedia.readingCover()
    }
    if (key === 'city' || key === 'window') {
      return RmMedia.cityCover()
    }
    if (key === 'corridor') {
      return RmMedia.corridorHero()
    }
    if (key === 'grow' || key === 'growth') {
      return RmMedia.readingCover()
    }
    if (key === 'interest' || key === 'hobby') {
      return RmMedia.teaBanner()
    }
    if (key === 'experience') {
      return RmMedia.paperBanner()
    }
    if (key === 'goal') {
      return RmMedia.corridorHero()
    }
    if (key === 'empty') {
      return RmMedia.emptyLight()
    }
    return RmMedia.paperBanner()
  }
}
