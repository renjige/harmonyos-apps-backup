/** coverKey → 本机影像；一 key 一图 */

export class StudyMedia {
  static resource(key: string): Resource {
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'banner_focus') {
      return $r('app.media.banner_focus')
    }
    if (key === 'banner_insight') {
      return $r('app.media.banner_insight')
    }
    if (key === 'cover_math') {
      return $r('app.media.cover_math')
    }
    if (key === 'cover_english') {
      return $r('app.media.cover_english')
    }
    if (key === 'cover_code') {
      return $r('app.media.cover_code')
    }
    if (key === 'cover_career') {
      return $r('app.media.cover_career')
    }
    if (key === 'texture_paper') {
      return $r('app.media.texture_paper')
    }
    return $r('app.media.texture_paper')
  }

  static coverForCategory(category: string): string {
    if (category === '数学') {
      return 'cover_math'
    }
    if (category === '英语') {
      return 'cover_english'
    }
    if (category === '编程') {
      return 'cover_code'
    }
    if (category === '职场') {
      return 'cover_career'
    }
    return 'texture_paper'
  }
}
