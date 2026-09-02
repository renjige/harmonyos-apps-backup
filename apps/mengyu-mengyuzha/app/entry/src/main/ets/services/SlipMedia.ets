/** 梦隅札影像映射 */
export class SlipMedia {
  static cover(key: string): Resource {
    if (key === 'hero_moon_window') {
      return $r('app.media.hero_moon_window')
    }
    if (key === 'ambient_dream_night') {
      return $r('app.media.ambient_dream_night')
    }
    if (key === 'empty_dream_desk') {
      return $r('app.media.empty_dream_desk')
    }
    if (key === 'hero_paper_window') {
      return $r('app.media.hero_moon_window')
    }
    return $r('app.media.hero_moon_window')
  }

  static forTag(tag: string): string {
    if (tag === '飞翔' || tag === '旅行') {
      return 'hero_moon_window'
    }
    if (tag === '坠落' || tag === '迷失') {
      return 'ambient_dream_night'
    }
    if (tag === '追逐' || tag === '重逢') {
      return 'empty_dream_desk'
    }
    return 'hero_moon_window'
  }
}
