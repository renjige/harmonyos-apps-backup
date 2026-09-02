/** coverKey → app.media 资源或 local:file:// 相册图 */
export class InspirationMedia {
  static toLocalKey(uri: string): string {
    return `local:${uri}`
  }

  static isLocalKey(key: string): boolean {
    return key.startsWith('local:')
  }

  static localUriFromKey(key: string): string {
    if (InspirationMedia.isLocalKey(key)) {
      return key.substring(6)
    }
    return ''
  }

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

  static catalogKeys(): string[] {
    return [
      'hero_latest_inspiration',
      'hero_color_packaging',
      'hero_typography',
      'hero_mood_brand',
      'hero_illustration',
      'hero_spatial',
      'hero_motion_ui',
      'board_summer_refresh',
      'board_editorial',
      'board_product_ui',
      'board_default',
      'plan_default'
    ]
  }
}
