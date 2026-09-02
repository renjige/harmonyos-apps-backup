/** coverKey → 本机影像；一 key 一图 */

export class SlipMedia {
  static cover(key: string): Resource {
    if (key === 'scene_life') {
      return $r('app.media.scene_life')
    }
    if (key === 'scene_work') {
      return $r('app.media.scene_work')
    }
    if (key === 'scene_family') {
      return $r('app.media.scene_family')
    }
    if (key === 'scene_shop') {
      return $r('app.media.scene_shop')
    }
    if (key === 'scene_trip') {
      return $r('app.media.scene_trip')
    }
    if (key === 'scene_study') {
      return $r('app.media.scene_study')
    }
    if (key === 'scene_other') {
      return $r('app.media.scene_other')
    }
    return $r('app.media.hero_today_paper')
  }

  static coverForCategory(category: string): string {
    if (category === '工作') {
      return 'scene_work'
    }
    if (category === '家庭') {
      return 'scene_family'
    }
    if (category === '购物') {
      return 'scene_shop'
    }
    if (category === '出行') {
      return 'scene_trip'
    }
    if (category === '学习') {
      return 'scene_study'
    }
    if (category === '其他') {
      return 'scene_other'
    }
    return 'scene_life'
  }
}
