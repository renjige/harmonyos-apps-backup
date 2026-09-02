/** coverKey → 本机影像；一 key 一图 */

export class RoamMedia {
  static resource(key: string): Resource {
    if (key === 'hero_home') {
      return $r('app.media.hero_home')
    }
    if (key === 'banner_city') {
      return $r('app.media.banner_city')
    }
    if (key === 'banner_winter') {
      return $r('app.media.banner_winter')
    }
    if (key === 'cover_literature') {
      return $r('app.media.cover_literature')
    }
    if (key === 'cover_philosophy') {
      return $r('app.media.cover_philosophy')
    }
    if (key === 'cover_history') {
      return $r('app.media.cover_history')
    }
    return $r('app.media.cover_literature')
  }
}
