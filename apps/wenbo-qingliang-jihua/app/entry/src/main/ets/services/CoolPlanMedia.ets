/** 栏目封面 → $r('app.media.*')，一 key 一图（占位名，DevEco 同步 media 资源） */

export class CoolPlanMedia {
  static resource(key: string): Resource {
    if (key === 'hero_mist_lake') {
      return $r('app.media.hero_mist_lake')
    }
    if (key === 'hero_tea_steam') {
      return $r('app.media.hero_tea_steam')
    }
    if (key === 'hero_morning_leaf') {
      return $r('app.media.hero_morning_leaf')
    }
    if (key === 'hero_breath_calm') {
      return $r('app.media.hero_breath_calm')
    }
    if (key === 'hero_breath_focus') {
      return $r('app.media.hero_breath_focus')
    }
    if (key === 'hero_breath_sleep') {
      return $r('app.media.hero_breath_sleep')
    }
    if (key === 'banner_cool_ring') {
      return $r('app.media.banner_cool_ring')
    }
    return $r('app.media.hero_mist_lake')
  }
}
