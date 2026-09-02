export class ShiyiMedia {
  static cover(key: string): Resource {
    if (key === 'hero_paper') {
      return $r('app.media.hero_paper')
    }
    if (key === 'banner_review') {
      return $r('app.media.banner_review')
    }
    if (key === 'cover_life') {
      return $r('app.media.cover_life')
    }
    if (key === 'cover_read') {
      return $r('app.media.cover_read')
    }
    if (key === 'cover_travel') {
      return $r('app.media.cover_travel')
    }
    if (key === 'cover_food') {
      return $r('app.media.cover_food')
    }
    if (key === 'cover_work') {
      return $r('app.media.cover_work')
    }
    if (key === 'cover_rain') {
      return $r('app.media.cover_rain')
    }
    if (key === 'texture_paper') {
      return $r('app.media.texture_paper')
    }
    if (key === 'empty_star') {
      return $r('app.media.empty_star')
    }
    return $r('app.media.hero_paper')
  }
}
