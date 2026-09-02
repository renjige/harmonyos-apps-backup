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
    return $r('app.media.home_hero')
  }
}
