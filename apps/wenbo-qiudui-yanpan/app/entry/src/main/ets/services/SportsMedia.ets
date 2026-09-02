/** 内容影像 — coverKey 映射独立摄影资源 */
export class SportsMedia {
  static heroImage(): Resource {
    return $r('app.media.hero_bg')
  }

  static bannerPrimary(): Resource {
    return $r('app.media.banner_01')
  }

  static bannerSecondary(): Resource {
    return $r('app.media.banner_02')
  }

  static coverImage(coverKey: string): Resource {
    const key = coverKey !== undefined && coverKey !== null ? coverKey : ''
    if (key.indexOf('basketball') >= 0) {
      return $r('app.media.cover_basketball')
    }
    if (key.indexOf('tennis') >= 0) {
      return $r('app.media.cover_tennis')
    }
    if (key.indexOf('esports') >= 0) {
      return $r('app.media.cover_esports')
    }
    if (key.indexOf('football') >= 0 || key.indexOf('team') >= 0 || key.indexOf('league') >= 0) {
      return $r('app.media.cover_football')
    }
    return $r('app.media.hero_bg')
  }

  static mediaResource(coverKey: string): string[] {
    return SportsMedia.heroGradient(coverKey)
  }

  static heroGradient(coverKey: string): string[] {
    if (coverKey.indexOf('football') >= 0) {
      return ['#0F766E', '#065F46']
    }
    if (coverKey.indexOf('basketball') >= 0) {
      return ['#EA580C', '#9A3412']
    }
    if (coverKey.indexOf('tennis') >= 0) {
      return ['#059669', '#047857']
    }
    if (coverKey.indexOf('esports') >= 0) {
      return ['#7C3AED', '#4C1D95']
    }
    if (coverKey.indexOf('league') >= 0) {
      return ['#1677FF', '#0F172A']
    }
    if (coverKey.indexOf('team') >= 0) {
      return ['#0369A1', '#0F172A']
    }
    return ['#1677FF', '#0F172A']
  }

  static heroBanner(): string[] {
    return ['#1677FF', '#7C3AED']
  }
}
