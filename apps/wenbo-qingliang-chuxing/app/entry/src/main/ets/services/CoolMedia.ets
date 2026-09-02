/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class CoolMedia {
  static resource(key: string): Resource {
    if (key === 'hero_city_shade') {
      return $r('app.media.hero_city_shade')
    }
    if (key === 'banner_indoor') {
      return $r('app.media.banner_indoor')
    }
    if (key === 'route_shade') {
      return $r('app.media.route_shade')
    }
    if (key === 'route_metro') {
      return $r('app.media.route_metro')
    }
    if (key === 'route_bike') {
      return $r('app.media.route_bike')
    }
    if (key === 'route_bus') {
      return $r('app.media.route_bus')
    }
    if (key === 'stop_mall') {
      return $r('app.media.stop_mall')
    }
    if (key === 'stop_cafe') {
      return $r('app.media.stop_cafe')
    }
    if (key === 'stop_park') {
      return $r('app.media.stop_park')
    }
    if (key === 'weather_sky') {
      return $r('app.media.weather_sky')
    }
    if (key === 'advice_dress') {
      return $r('app.media.advice_dress')
    }
    return $r('app.media.hero_city_shade')
  }
}
