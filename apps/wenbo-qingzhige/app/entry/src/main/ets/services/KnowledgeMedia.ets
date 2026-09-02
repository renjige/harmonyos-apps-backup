/** coverKey → 本机影像；一 key 一图 */

export class KnowledgeMedia {
  static resource(key: string): Resource {
    if (key === 'hero_today_page') {
      return $r('app.media.hero_today_page')
    }
    if (key === 'hero_review') {
      return $r('app.media.hero_review')
    }
    if (key === 'cover_life') {
      return $r('app.media.cover_life')
    }
    if (key === 'cover_science') {
      return $r('app.media.cover_science')
    }
    if (key === 'cover_reading') {
      return $r('app.media.cover_reading')
    }
    if (key === 'cover_work') {
      return $r('app.media.cover_work')
    }
    if (key === 'cover_interest') {
      return $r('app.media.cover_interest')
    }
    if (key === 'cover_other') {
      return $r('app.media.cover_other')
    }
    return $r('app.media.cover_other')
  }

  static coverForCategory(category: string): string {
    if (category === '生活') {
      return 'cover_life'
    }
    if (category === '科普') {
      return 'cover_science'
    }
    if (category === '阅读') {
      return 'cover_reading'
    }
    if (category === '工作') {
      return 'cover_work'
    }
    if (category === '兴趣') {
      return 'cover_interest'
    }
    return 'cover_other'
  }
}
