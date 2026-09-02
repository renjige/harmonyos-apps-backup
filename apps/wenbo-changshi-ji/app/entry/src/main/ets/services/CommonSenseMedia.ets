/** coverMedia → 本机影像；一 key 一图，禁止共图 */

export class CommonSenseMedia {
  static resource(key: string): Resource {
    if (key === 'hero_today') {
      return $r('app.media.hero_today')
    }
    if (key === 'banner_calendar') {
      return $r('app.media.banner_calendar')
    }
    if (key === 'banner_explore') {
      return $r('app.media.banner_explore')
    }
    if (key === 'cover_life') {
      return $r('app.media.cover_life')
    }
    if (key === 'cover_science') {
      return $r('app.media.cover_science')
    }
    if (key === 'cover_history') {
      return $r('app.media.cover_history')
    }
    if (key === 'cover_health') {
      return $r('app.media.cover_health')
    }
    if (key === 'cover_nature') {
      return $r('app.media.cover_nature')
    }
    if (key === 'cover_career') {
      return $r('app.media.cover_career')
    }
    if (key === 'cover_food') {
      return $r('app.media.cover_food')
    }
    if (key === 'cover_mind') {
      return $r('app.media.cover_mind')
    }
    return $r('app.media.hero_today')
  }
}
