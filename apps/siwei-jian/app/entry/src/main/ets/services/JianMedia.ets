export class JianMedia {
  static heroDesk(): Resource {
    return $r('app.media.hero_slip_light')
  }

  static bannerPaper(): Resource {
    return $r('app.media.banner_quiet_think')
  }

  static bannerThink(): Resource {
    return $r('app.media.banner_timeline')
  }

  static coverTheme(): Resource {
    return $r('app.media.cover_theme_shelf')
  }

  static coverViewCard(): Resource {
    return $r('app.media.cover_viewcard')
  }

  static emptyDesk(): Resource {
    return $r('app.media.empty_slip_desk')
  }

  static coverFor(kind: string): Resource {
    if (kind === 'theme') {
      return JianMedia.coverTheme()
    }
    if (kind === 'spark') {
      return JianMedia.bannerThink()
    }
    if (kind === 'card') {
      return JianMedia.coverViewCard()
    }
    return JianMedia.heroDesk()
  }
}
