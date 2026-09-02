export class ZhixingMedia {
  static image(key: string): Resource {
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (key === 'banner_know') {
      return $r('app.media.banner_know')
    }
    if (key === 'banner_act') {
      return $r('app.media.banner_act')
    }
    if (key === 'cover_note') {
      return $r('app.media.cover_note')
    }
    if (key === 'cover_card') {
      return $r('app.media.cover_card')
    }
    if (key === 'cover_read') {
      return $r('app.media.cover_read')
    }
    if (key === 'cover_plan') {
      return $r('app.media.cover_plan')
    }
    if (key === 'cover_habit') {
      return $r('app.media.cover_habit')
    }
    if (key === 'cover_log') {
      return $r('app.media.cover_log')
    }
    if (key === 'cover_graph') {
      return $r('app.media.cover_graph')
    }
    return $r('app.media.cover_card')
  }
}
