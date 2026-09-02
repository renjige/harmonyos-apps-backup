/** coverKey → app.media 资源；一 key 一图 */
export class GrowthMedia {
  static recordCoverKeys(): string[] {
    const keys: string[] = []
    keys.push('hero_latest_inspiration')
    keys.push('hero_spatial')
    keys.push('hero_typography')
    keys.push('hero_mood_brand')
    keys.push('hero_rain_walk')
    keys.push('hero_morning_coffee')
    keys.push('hero_kitchen')
    keys.push('plan_default')
    return keys
  }

  static coverMedia(key: string): Resource {
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (key === 'hero_morning_coffee') {
      return $r('app.media.hero_morning_coffee')
    }
    if (key === 'hero_kitchen') {
      return $r('app.media.hero_kitchen')
    }
    if (key === 'hero_reading_growth') {
      return $r('app.media.hero_latest_inspiration')
    }
    if (key === 'hero_running_growth') {
      return $r('app.media.hero_rain_walk')
    }
    if (key === 'hero_skill_growth') {
      return $r('app.media.hero_motion_ui')
    }
    if (key === 'hero_mood_growth') {
      return $r('app.media.hero_mood_brand')
    }
    if (key === 'hero_goal_growth') {
      return $r('app.media.plan_default')
    }
    if (key === 'hero_streak_growth') {
      return $r('app.media.hero_typography')
    }
    if (key === 'milestone_goal_done') {
      return $r('app.media.board_default')
    }
    if (key === 'milestone_streak') {
      return $r('app.media.board_editorial')
    }
    if (key === 'milestone_review') {
      return $r('app.media.board_summer_refresh')
    }
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
    if (key === 'hero_rain_walk') {
      return $r('app.media.hero_rain_walk')
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
    return $r('app.media.hero_latest_inspiration')
  }
}
