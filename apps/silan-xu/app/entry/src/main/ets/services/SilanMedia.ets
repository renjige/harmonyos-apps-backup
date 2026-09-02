export class SilanMedia {
  static heroDesk(): Resource {
    return $r('app.media.hero_desk_ink')
  }

  static bannerPaper(): Resource {
    return $r('app.media.banner_paper_fold')
  }

  static bannerThink(): Resource {
    return $r('app.media.banner_think_light')
  }

  static coverTheme(): Resource {
    return $r('app.media.cover_theme_room')
  }

  static coverReading(): Resource {
    return $r('app.media.cover_reading_margin')
  }

  static emptyDesk(): Resource {
    return $r('app.media.empty_quiet_desk')
  }

  static coverFor(kind: string): Resource {
    if (kind === 'reading') {
      return SilanMedia.coverReading()
    }
    if (kind === 'theme') {
      return SilanMedia.coverTheme()
    }
    if (kind === 'spark') {
      return SilanMedia.bannerThink()
    }
    if (kind === 'card') {
      return SilanMedia.bannerPaper()
    }
    return SilanMedia.heroDesk()
  }
}
