export class BowenMedia {
  static heroDesk(): Resource {
    return $r('app.media.hero_pavilion')
  }

  static bannerPaper(): Resource {
    return $r('app.media.banner_study')
  }

  static bannerThink(): Resource {
    return $r('app.media.banner_review')
  }

  static coverTheme(): Resource {
    return $r('app.media.cover_theme_shelf')
  }

  static coverReading(): Resource {
    return $r('app.media.cover_reading_note')
  }

  static emptyDesk(): Resource {
    return $r('app.media.empty_desk')
  }

  static coverFor(kind: string): Resource {
    if (kind === 'reading') {
      return BowenMedia.coverReading()
    }
    if (kind === 'theme') {
      return BowenMedia.coverTheme()
    }
    if (kind === 'card') {
      return $r('app.media.cover_card_archive')
    }
    if (kind === 'study') {
      return BowenMedia.bannerPaper()
    }
    return BowenMedia.heroDesk()
  }
}
