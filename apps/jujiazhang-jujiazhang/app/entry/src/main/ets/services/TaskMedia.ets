export class TaskMedia {
  static cover(key: string): Resource {
    if (key === 'cat_chore') {
      return $r('app.media.cat_chore')
    }
    if (key === 'cat_shop') {
      return $r('app.media.cat_shop')
    }
    if (key === 'cat_family') {
      return $r('app.media.cat_family')
    }
    if (key === 'cat_kids') {
      return $r('app.media.cat_kids')
    }
    if (key === 'cat_other') {
      return $r('app.media.cat_other')
    }
    if (key === 'empty_idle') {
      return $r('app.media.empty_idle')
    }
    if (key === 'item_appliance') {
      return $r('app.media.item_appliance')
    }
    if (key === 'item_medicine') {
      return $r('app.media.item_medicine')
    }
    if (key === 'item_document') {
      return $r('app.media.item_document')
    }
    if (key === 'item_other') {
      return $r('app.media.item_other')
    }
    if (key === 'memo_shop') {
      return $r('app.media.memo_shop')
    }
    if (key === 'memo_travel') {
      return $r('app.media.memo_travel')
    }
    if (key === 'memo_repair') {
      return $r('app.media.memo_repair')
    }
    if (key === 'memo_other') {
      return $r('app.media.memo_other')
    }
    return $r('app.media.home_hero')
  }
}
