export class XuMedia {
  static hero(): Resource {
    return $r('app.media.hero_study')
  }

  static banner(): Resource {
    return $r('app.media.banner_ink')
  }

  static habit(): Resource {
    return $r('app.media.cover_habit')
  }

  static note(): Resource {
    return $r('app.media.cover_note')
  }

  static calendar(): Resource {
    return $r('app.media.cover_calendar')
  }

  static emptyPaper(): Resource {
    return $r('app.media.empty_paper')
  }

  static forCover(key: string): Resource {
    if (key === 'cover_habit' || key === 'habit') {
      return XuMedia.habit()
    }
    if (key === 'cover_note' || key === 'note') {
      return XuMedia.note()
    }
    if (key === 'cover_calendar' || key === 'calendar') {
      return XuMedia.calendar()
    }
    if (key === 'banner_ink' || key === 'banner') {
      return XuMedia.banner()
    }
    if (key === 'empty_paper') {
      return XuMedia.emptyPaper()
    }
    if (key === 'hero_study' || key === 'hero') {
      return XuMedia.hero()
    }
    return XuMedia.hero()
  }
}
