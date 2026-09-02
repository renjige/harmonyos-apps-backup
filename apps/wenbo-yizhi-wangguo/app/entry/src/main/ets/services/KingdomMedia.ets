export class KingdomMedia {
  static resource(key: string): Resource {
    if (key === 'hero_hall') {
      return $r('app.media.hero_hall')
    }
    if (key === 'hero_path') {
      return $r('app.media.hero_path')
    }
    if (key === 'cover_shape') {
      return $r('app.media.cover_shape')
    }
    if (key === 'cover_color') {
      return $r('app.media.cover_color')
    }
    if (key === 'cover_maze') {
      return $r('app.media.cover_maze')
    }
    if (key === 'cover_reason') {
      return $r('app.media.cover_reason')
    }
    if (key === 'cover_daily') {
      return $r('app.media.cover_daily')
    }
    if (key === 'relic_star') {
      return $r('app.media.relic_star')
    }
    if (key === 'relic_leaf') {
      return $r('app.media.relic_leaf')
    }
    if (key === 'relic_sun') {
      return $r('app.media.relic_sun')
    }
    if (key === 'relic_box') {
      return $r('app.media.relic_box')
    }
    if (key === 'relic_map') {
      return $r('app.media.relic_map')
    }
    if (key === 'relic_crown') {
      return $r('app.media.relic_crown')
    }
    if (key === 'relic_lamp') {
      return $r('app.media.relic_lamp')
    }
    if (key === 'relic_key') {
      return $r('app.media.relic_key')
    }
    return $r('app.media.hero_hall')
  }
}
