/** coverKey → 本机影像；一 key 一图，禁止共图合并 */

export class CottageMedia {
  static resource(key: string): Resource {
    if (key === 'hero_plaza') {
      return $r('app.media.hero_plaza')
    }
    if (key === 'banner_path') {
      return $r('app.media.banner_path')
    }
    if (key === 'banner_daily') {
      return $r('app.media.banner_daily')
    }
    if (key === 'cover_code') {
      return $r('app.media.cover_code')
    }
    if (key === 'cover_lang') {
      return $r('app.media.cover_lang')
    }
    if (key === 'cover_career') {
      return $r('app.media.cover_career')
    }
    if (key === 'cover_literacy') {
      return $r('app.media.cover_literacy')
    }
    if (key === 'cover_thinking') {
      return $r('app.media.cover_thinking')
    }
    if (key === 'path_frontend') {
      return $r('app.media.path_frontend')
    }
    if (key === 'path_english') {
      return $r('app.media.path_english')
    }
    if (key === 'path_career') {
      return $r('app.media.path_career')
    }
    if (key === 'path_literacy') {
      return $r('app.media.path_literacy')
    }
    if (key === 'path_thinking') {
      return $r('app.media.path_thinking')
    }
    if (key === 'card_variable') {
      return $r('app.media.card_variable')
    }
    if (key === 'card_selector') {
      return $r('app.media.card_selector')
    }
    if (key === 'card_chunk') {
      return $r('app.media.card_chunk')
    }
    if (key === 'card_conclusion') {
      return $r('app.media.card_conclusion')
    }
    if (key === 'card_percent') {
      return $r('app.media.card_percent')
    }
    if (key === 'card_counter') {
      return $r('app.media.card_counter')
    }
    if (key === 'card_button') {
      return $r('app.media.card_button')
    }
    if (key === 'card_pathmind') {
      return $r('app.media.card_pathmind')
    }
    if (key === 'daily_one_change') {
      return $r('app.media.daily_one_change')
    }
    if (key === 'daily_focus') {
      return $r('app.media.daily_focus')
    }
    if (key === 'daily_chunk') {
      return $r('app.media.daily_chunk')
    }
    if (key === 'daily_number') {
      return $r('app.media.daily_number')
    }
    if (key === 'daily_ask') {
      return $r('app.media.daily_ask')
    }
    if (key === 'lesson_html') {
      return $r('app.media.lesson_html')
    }
    if (key === 'lesson_lang') {
      return $r('app.media.lesson_lang')
    }
    if (key === 'lesson_career') {
      return $r('app.media.lesson_career')
    }
    if (key === 'lesson_literacy') {
      return $r('app.media.lesson_literacy')
    }
    if (key === 'lesson_thinking') {
      return $r('app.media.lesson_thinking')
    }
    if (key === 'qa_ambient') {
      return $r('app.media.qa_ambient')
    }
    if (key === 'badge_brick') {
      return $r('app.media.badge_brick')
    }
    if (key === 'badge_week') {
      return $r('app.media.badge_week')
    }
    if (key === 'badge_path') {
      return $r('app.media.badge_path')
    }
    if (key === 'badge_collect') {
      return $r('app.media.badge_collect')
    }
    if (key === 'badge_ask') {
      return $r('app.media.badge_ask')
    }
    if (key === 'badge_domain') {
      return $r('app.media.badge_domain')
    }
    return CottageMedia.byDomain(key)
  }

  static byDomain(domain: string): Resource {
    if (domain === 'code') {
      return $r('app.media.cover_code')
    }
    if (domain === 'lang') {
      return $r('app.media.cover_lang')
    }
    if (domain === 'career') {
      return $r('app.media.cover_career')
    }
    if (domain === 'literacy') {
      return $r('app.media.cover_literacy')
    }
    if (domain === 'thinking') {
      return $r('app.media.cover_thinking')
    }
    return $r('app.media.hero_plaza')
  }
}
