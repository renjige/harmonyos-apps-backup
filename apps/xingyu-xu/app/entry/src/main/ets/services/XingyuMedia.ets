export class XingyuMedia {
  static image(key: string): Resource {
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (key === 'banner_01') {
      return $r('app.media.banner_01')
    }
    if (key === 'banner_02') {
      return $r('app.media.banner_02')
    }
    if (key === 'cover_reading') {
      return $r('app.media.cover_reading')
    }
    if (key === 'cover_travel') {
      return $r('app.media.cover_travel')
    }
    if (key === 'cover_growth') {
      return $r('app.media.cover_growth')
    }
    if (key === 'cover_hobby') {
      return $r('app.media.cover_hobby')
    }
    if (key === 'cover_life') {
      return $r('app.media.cover_life')
    }
    return $r('app.media.cover_life')
  }
}
