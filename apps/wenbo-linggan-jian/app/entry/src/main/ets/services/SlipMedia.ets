/** coverKey → 本机影像；一 key 一图 */
export class SlipMedia {
  static cover(key: string): Resource {
    if (key === 'hero_paper_window') {
      return $r('app.media.hero_paper_window')
    }
    if (key === 'hero_ink_desk') {
      return $r('app.media.hero_ink_desk')
    }
    if (key === 'cover_tea_slip') {
      return $r('app.media.cover_tea_slip')
    }
    if (key === 'cover_night_lamp') {
      return $r('app.media.cover_night_lamp')
    }
    if (key === 'cover_folded_jian') {
      return $r('app.media.cover_folded_jian')
    }
    if (key === 'banner_morning_paper') {
      return $r('app.media.banner_morning_paper')
    }
    if (key === 'banner_ink_wash') {
      return $r('app.media.banner_ink_wash')
    }
    if (key === 'texture_rice') {
      return $r('app.media.texture_rice')
    }
    if (key === 'card_plain_paper') {
      return $r('app.media.card_plain_paper')
    }
    if (key === 'card_ink_blue') {
      return $r('app.media.card_ink_blue')
    }
    if (key === 'card_dawn_gold') {
      return $r('app.media.card_dawn_gold')
    }
    if (key === 'card_night_navy') {
      return $r('app.media.card_night_navy')
    }
    return $r('app.media.hero_paper_window')
  }

  static forTemplate(key: string): string {
    if (key === 'ink') {
      return 'card_ink_blue'
    }
    if (key === 'dawn') {
      return 'card_dawn_gold'
    }
    if (key === 'night') {
      return 'card_night_navy'
    }
    return 'card_plain_paper'
  }

  static forTag(tag: string): string {
    if (tag === '生活') {
      return 'hero_paper_window'
    }
    if (tag === '工作') {
      return 'hero_ink_desk'
    }
    if (tag === '创意') {
      return 'cover_folded_jian'
    }
    if (tag === '阅读') {
      return 'cover_tea_slip'
    }
    if (tag === '随笔') {
      return 'banner_morning_paper'
    }
    return 'texture_rice'
  }
}
