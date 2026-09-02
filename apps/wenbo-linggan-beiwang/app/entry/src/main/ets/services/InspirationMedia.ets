/** coverKey → app.media 资源；一 key 一图（占位，后续替换真实素材） */
export class InspirationMedia {
  static coverMedia(key: string): Resource {
    if (key === 'hero_color_packaging') {
      return $r('app.media.hero_color_packaging')
    }
    if (key === 'hero_typography') {
      return $r('app.media.hero_typography')
    }
    if (key === 'hero_mood_brand') {
      return $r('app.media.hero_mood_brand')
    }
    if (key === 'hero_illustration') {
      return $r('app.media.hero_illustration')
    }
    if (key === 'hero_spatial') {
      return $r('app.media.hero_spatial')
    }
    if (key === 'hero_motion_ui') {
      return $r('app.media.hero_motion_ui')
    }
    if (key === 'hero_latest_inspiration') {
      return $r('app.media.hero_latest_inspiration')
    }
    if (key === 'board_summer_refresh') {
      return $r('app.media.board_summer_refresh')
    }
    if (key === 'board_editorial') {
      return $r('app.media.board_editorial')
    }
    if (key === 'board_product_ui') {
      return $r('app.media.board_product_ui')
    }
    if (key === 'board_default') {
      return $r('app.media.board_default')
    }
    if (key === 'plan_default') {
      return $r('app.media.plan_default')
    }
    return $r('app.media.hero_color_packaging')
  }
}
