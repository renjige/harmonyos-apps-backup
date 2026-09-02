export class PoetryMedia {
  static cover(key: string): Resource {
    if (key === 'hero_ink') {
      return $r('app.media.hero_ink')
    }
    if (key === 'hero_daily') {
      return $r('app.media.hero_daily')
    }
    if (key === 'banner_hunt') {
      return $r('app.media.banner_hunt')
    }
    if (key === 'cover_moon') {
      return $r('app.media.cover_moon')
    }
    if (key === 'cover_river') {
      return $r('app.media.cover_river')
    }
    if (key === 'cover_mountain') {
      return $r('app.media.cover_mountain')
    }
    if (key === 'cover_plum') {
      return $r('app.media.cover_plum')
    }
    if (key === 'cover_bamboo') {
      return $r('app.media.cover_bamboo')
    }
    if (key === 'cover_pavilion') {
      return $r('app.media.cover_pavilion')
    }
    if (key === 'cover_boat') {
      return $r('app.media.cover_boat')
    }
    if (key === 'cover_temple') {
      return $r('app.media.cover_temple')
    }
    if (key === 'cover_desert') {
      return $r('app.media.cover_desert')
    }
    if (key === 'cover_lake') {
      return $r('app.media.cover_lake')
    }
    if (key === 'cover_bridge') {
      return $r('app.media.cover_bridge')
    }
    if (key === 'cover_scroll') {
      return $r('app.media.cover_scroll')
    }
    if (key === 'cover_city') {
      return $r('app.media.cover_city')
    }
    if (key === 'cover_waterfall') {
      return $r('app.media.cover_waterfall')
    }
    if (key === 'cover_chrysanthemum') {
      return $r('app.media.cover_chrysanthemum')
    }
    return $r('app.media.cover_ink')
  }
}
