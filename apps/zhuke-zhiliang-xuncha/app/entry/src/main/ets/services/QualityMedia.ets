export class QualityMedia {
  static cover(key: string): Resource {
    if (key === 'cover_binjiang') {
      return $r('app.media.cover_binjiang')
    }
    if (key === 'cover_yunqi') {
      return $r('app.media.cover_yunqi')
    }
    if (key === 'cover_plaza') {
      return $r('app.media.cover_plaza')
    }
    if (key === 'cover_wall') {
      return $r('app.media.cover_wall')
    }
    if (key === 'cover_floor') {
      return $r('app.media.cover_floor')
    }
    if (key === 'cover_window') {
      return $r('app.media.cover_window')
    }
    if (key === 'cover_waterproof') {
      return $r('app.media.cover_waterproof')
    }
    return $r('app.media.hero_home')
  }

  static isFileUri(key: string): boolean {
    return key.indexOf('file://') === 0 || key.indexOf('/') === 0
  }
}
