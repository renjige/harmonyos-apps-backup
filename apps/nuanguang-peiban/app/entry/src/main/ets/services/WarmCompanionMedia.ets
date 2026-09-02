/** 栏目封面 → $r('app.media.*')，一 key 一图 */

export class WarmCompanionMedia {
  static resource(key: string): Resource {
    if (key === 'hero_warm_glow') {
      return $r('app.media.hero_warm_glow')
    }
    if (key === 'banner_warm_01') {
      return $r('app.media.banner_warm_01')
    }
    if (key === 'banner_warm_02') {
      return $r('app.media.banner_warm_02')
    }
    if (key === 'cover_quote_cozy') {
      return $r('app.media.cover_quote_cozy')
    }
    if (key === 'cover_quote_rain') {
      return $r('app.media.cover_quote_rain')
    }
    if (key === 'cover_breath_soft') {
      return $r('app.media.cover_breath_soft')
    }
    if (key === 'cover_breath_glow') {
      return $r('app.media.cover_breath_glow')
    }
    if (key === 'cover_breath_night') {
      return $r('app.media.cover_breath_night')
    }
    if (key === 'cover_noise_rain') {
      return $r('app.media.cover_noise_rain')
    }
    if (key === 'cover_noise_ocean') {
      return $r('app.media.cover_noise_ocean')
    }
    if (key === 'cover_noise_fire') {
      return $r('app.media.cover_noise_fire')
    }
    if (key === 'cover_noise_forest') {
      return $r('app.media.cover_noise_forest')
    }
    if (key === 'cover_noise_wind') {
      return $r('app.media.cover_noise_wind')
    }
    if (key === 'cover_badge_glow') {
      return $r('app.media.cover_badge_glow')
    }
    return $r('app.media.hero_warm_glow')
  }
}
