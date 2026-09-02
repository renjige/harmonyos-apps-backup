/** coverKey → 本机影像；一 key 一图 */

export class JianMedia {
  static cover(key: string): Resource {
    if (key === 'journal_food') {
      return $r('app.media.journal_food')
    }
    if (key === 'journal_scenery') {
      return $r('app.media.journal_scenery')
    }
    if (key === 'banner_01') {
      return $r('app.media.banner_01')
    }
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    return $r('app.media.journal_scenery')
  }

  static hero(): Resource {
    return $r('app.media.hero_bg')
  }

  static empty(): Resource {
    return $r('app.media.empty_state')
  }

  static banner(): Resource {
    return $r('app.media.banner_01')
  }
}
