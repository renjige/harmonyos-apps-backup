/** 赛事封面 — coverKey 映射摄影或竞技风渐变 */
export class SportsMedia {
  static hasPhoto(coverKey: string): boolean {
    return coverKey === 'match_football_1' ||
      coverKey === 'match_basketball_1' ||
      coverKey === 'hero_stadium'
  }

  static photoKey(coverKey: string): string {
    if (coverKey === 'match_football_1') {
      return 'match_football_1'
    }
    if (coverKey === 'match_basketball_1') {
      return 'match_basketball_1'
    }
    return 'hero_stadium'
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
    if (coverKey.indexOf('other') >= 0) {
      return ['#475569', '#1E293B']
    }
    return ['#1677FF', '#0F172A']
  }

  static heroBanner(): string[] {
    return ['#1677FF', '#7C3AED']
  }
}
