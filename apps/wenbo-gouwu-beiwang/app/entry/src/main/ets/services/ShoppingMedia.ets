export class ShoppingMedia {
  static cover(key: string): Resource {
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
    return $r('app.media.home_hero')
  }
}
