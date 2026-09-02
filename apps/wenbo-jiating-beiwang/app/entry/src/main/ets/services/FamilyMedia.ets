export class FamilyMedia {
  static cover(key: string, salt: string = ''): Resource {
    if (key === 'tpl_clean') {
      return $r('app.media.tpl_clean')
    }
    if (key === 'tpl_festival') {
      return $r('app.media.tpl_festival')
    }
    if (key === 'tpl_move') {
      return $r('app.media.tpl_move')
    }
    if (key === 'tpl_weekend') {
      return $r('app.media.tpl_weekend')
    }
    if (key === 'tpl_family') {
      return $r('app.media.tpl_family')
    }
    if (key === 'tpl_daily') {
      return $r('app.media.tpl_daily')
    }
    if (key === 'tpl_travel') {
      return $r('app.media.tpl_travel')
    }
    if (key === 'tpl_breakfast') {
      return $r('app.media.tpl_breakfast')
    }
    if (key === 'memo_hero') {
      return $r('app.media.memo_hero')
    }
    if (key === 'home_hero' && salt.length === 0) {
      return $r('app.media.home_hero')
    }
    const seed = salt.length > 0 ? salt : key
    return FamilyMedia.rotated(seed)
  }

  static nextCoverKey(index: number): string {
    const n = index % 8
    if (n === 0) {
      return 'tpl_clean'
    }
    if (n === 1) {
      return 'tpl_festival'
    }
    if (n === 2) {
      return 'tpl_move'
    }
    if (n === 3) {
      return 'tpl_weekend'
    }
    if (n === 4) {
      return 'tpl_daily'
    }
    if (n === 5) {
      return 'tpl_breakfast'
    }
    if (n === 6) {
      return 'tpl_travel'
    }
    return 'memo_hero'
  }

  private static rotated(seed: string): Resource {
    let hash = 0
    for (let i = 0; i < seed.length; i++) {
      hash = hash * 31 + seed.charCodeAt(i)
      if (hash > 100000) {
        hash = hash % 100000
      }
    }
    return FamilyMedia.cover(FamilyMedia.nextCoverKey(hash % 8), '')
  }
}
