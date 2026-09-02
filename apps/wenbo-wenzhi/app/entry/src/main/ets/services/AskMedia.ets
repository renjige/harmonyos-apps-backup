/** coverKey → 本机影像；一 key 一图，禁止共图 */

export class AskMedia {
  static resource(key: string): Resource {
    if (key === 'hero_ask') {
      return $r('app.media.hero_ask')
    }
    if (key === 'banner_insight') {
      return $r('app.media.banner_insight')
    }
    if (key === 'banner_daily') {
      return $r('app.media.banner_daily')
    }
    if (key === 'cover_work') {
      return $r('app.media.cover_work')
    }
    if (key === 'cover_study') {
      return $r('app.media.cover_study')
    }
    if (key === 'cover_life') {
      return $r('app.media.cover_life')
    }
    if (key === 'cover_tech') {
      return $r('app.media.cover_tech')
    }
    if (key === 'cover_history') {
      return $r('app.media.cover_history')
    }
    if (key === 'daily_hero') {
      return $r('app.media.daily_hero')
    }
    return $r('app.media.cover_study')
  }

  static coverForFolder(folder: string): string {
    if (folder === '生活百科' || folder === '健康常识' || folder === '生活') {
      return 'cover_life'
    }
    if (folder === '科普知识' || folder === '工作') {
      return 'cover_tech'
    }
    if (folder === '历史文化') {
      return 'cover_history'
    }
    if (folder === '趣味知识') {
      return 'cover_work'
    }
    return 'cover_study'
  }
}
