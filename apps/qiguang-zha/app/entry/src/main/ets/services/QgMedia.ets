export class QgMedia {
  static homeHero(): Resource {
    return $r('app.media.hero_window_light')
  }

  static paperBanner(): Resource {
    return $r('app.media.banner_paper_archive')
  }

  static teaBanner(): Resource {
    return $r('app.media.banner_tea_still')
  }

  static corridorHero(): Resource {
    return $r('app.media.hero_corridor_light')
  }

  static readingCover(): Resource {
    return $r('app.media.cover_reading_nook')
  }

  static emptyLight(): Resource {
    return $r('app.media.empty_first_light')
  }

  static coverOf(key: string): Resource {
    if (key === 'tea') {
      return QgMedia.teaBanner()
    }
    if (key === 'reading') {
      return QgMedia.readingCover()
    }
    if (key === 'corridor') {
      return QgMedia.corridorHero()
    }
    if (key === 'window') {
      return QgMedia.homeHero()
    }
    if (key === 'empty') {
      return QgMedia.emptyLight()
    }
    return QgMedia.paperBanner()
  }
}
