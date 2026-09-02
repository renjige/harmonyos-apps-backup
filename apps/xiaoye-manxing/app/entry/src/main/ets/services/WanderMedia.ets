/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class WanderMedia {
  static resource(key: string): Resource {
    if (key === 'hero_summer') {
      return $r('app.media.hero_summer')
    }
    if (key === 'route_valley') {
      return $r('app.media.route_valley')
    }
    if (key === 'route_lake') {
      return $r('app.media.route_lake')
    }
    if (key === 'route_greenway') {
      return $r('app.media.route_greenway')
    }
    if (key === 'route_forest') {
      return $r('app.media.route_forest')
    }
    if (key === 'route_town') {
      return $r('app.media.route_town')
    }
    if (key === 'route_sunset') {
      return $r('app.media.route_sunset')
    }
    if (key === 'route_morning') {
      return $r('app.media.route_morning')
    }
    if (key === 'route_park') {
      return $r('app.media.route_park')
    }
    if (key === 'route_river') {
      return $r('app.media.route_river')
    }
    if (key === 'route_garden') {
      return $r('app.media.route_garden')
    }
    if (key === 'route_alley') {
      return $r('app.media.route_alley')
    }
    if (key === 'route_suburb') {
      return $r('app.media.route_suburb')
    }
    if (key === 'insp_wind') {
      return $r('app.media.insp_wind')
    }
    if (key === 'insp_blank') {
      return $r('app.media.insp_blank')
    }
    if (key === 'insp_slow') {
      return $r('app.media.insp_slow')
    }
    if (key === 'insp_shade') {
      return $r('app.media.insp_shade')
    }
    return $r('app.media.hero_summer')
  }
}
