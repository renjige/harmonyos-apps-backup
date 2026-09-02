export class BoxMedia {
  static resource(key: string): Resource {
    if (key === 'hero_open_box') {
      return $r('app.media.hero_open_box')
    }
    if (key === 'banner_capture') {
      return $r('app.media.banner_capture')
    }
    if (key === 'banner_mindmap') {
      return $r('app.media.banner_mindmap')
    }
    if (key === 'cover_cards') {
      return $r('app.media.cover_cards')
    }
    if (key === 'cover_tags') {
      return $r('app.media.cover_tags')
    }
    if (key === 'empty_linen') {
      return $r('app.media.empty_linen')
    }
    if (key === 'texture_paper') {
      return $r('app.media.texture_paper')
    }
    return $r('app.media.hero_open_box')
  }
}
