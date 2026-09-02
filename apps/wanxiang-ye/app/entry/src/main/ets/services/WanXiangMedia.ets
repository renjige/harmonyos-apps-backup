export class WanXiangMedia {
  static coverResource(coverKey: string): Resource {
    if (coverKey === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (coverKey === 'banner_tech') {
      return $r('app.media.banner_tech')
    }
    if (coverKey === 'banner_life') {
      return $r('app.media.banner_life')
    }
    if (coverKey === 'cover_tech_01') {
      return $r('app.media.cover_tech_01')
    }
    if (coverKey === 'cover_tech_02') {
      return $r('app.media.cover_tech_02')
    }
    if (coverKey === 'cover_life_01') {
      return $r('app.media.cover_life_01')
    }
    if (coverKey === 'cover_life_02') {
      return $r('app.media.cover_life_02')
    }
    if (coverKey === 'cover_culture_01') {
      return $r('app.media.cover_culture_01')
    }
    if (coverKey === 'cover_culture_02') {
      return $r('app.media.cover_culture_02')
    }
    if (coverKey === 'cover_recommend_01') {
      return $r('app.media.cover_recommend_01')
    }
    return $r('app.media.hero_bg')
  }
}
