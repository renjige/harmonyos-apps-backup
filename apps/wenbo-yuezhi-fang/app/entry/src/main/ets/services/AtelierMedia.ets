/** coverMedia → 本机影像；一 key 一图，禁止共图 */

export class AtelierMedia {
  static resource(key: string): Resource {
    if (key === 'hero_atelier') {
      return $r('app.media.hero_atelier')
    }
    if (key === 'banner_daily') {
      return $r('app.media.banner_daily')
    }
    if (key === 'banner_plaza') {
      return $r('app.media.banner_plaza')
    }
    if (key === 'cover_biz_01') {
      return $r('app.media.cover_biz_01')
    }
    if (key === 'cover_biz_02') {
      return $r('app.media.cover_biz_02')
    }
    if (key === 'cover_hum_01') {
      return $r('app.media.cover_hum_01')
    }
    if (key === 'cover_hum_02') {
      return $r('app.media.cover_hum_02')
    }
    if (key === 'cover_tech_01') {
      return $r('app.media.cover_tech_01')
    }
    if (key === 'cover_tech_02') {
      return $r('app.media.cover_tech_02')
    }
    if (key === 'cover_life_01') {
      return $r('app.media.cover_life_01')
    }
    if (key === 'cover_life_02') {
      return $r('app.media.cover_life_02')
    }
    if (key === 'cover_art_01') {
      return $r('app.media.cover_art_01')
    }
    if (key === 'cover_art_02') {
      return $r('app.media.cover_art_02')
    }
    if (key === 'cover_daily_01') {
      return $r('app.media.cover_daily_01')
    }
    if (key === 'cover_daily_02') {
      return $r('app.media.cover_daily_02')
    }
    if (key === 'cover_daily_03') {
      return $r('app.media.cover_daily_03')
    }
    if (key === 'cover_daily_04') {
      return $r('app.media.cover_daily_04')
    }
    if (key === 'cover_plaza_01') {
      return $r('app.media.cover_plaza_01')
    }
    return $r('app.media.hero_atelier')
  }
}
