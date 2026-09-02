/** coverKey → 本机影像；一 key 一图，禁止共图 */
export class DawnMedia {
  static cover(key: string): Resource {
    if (key === 'hero_dawn_window') {
      return $r('app.media.hero_dawn_window')
    }
    if (key === 'banner_letter_desk') {
      return $r('app.media.banner_letter_desk')
    }
    if (key === 'banner_gold_beam') {
      return $r('app.media.banner_gold_beam')
    }
    if (key === 'cover_folded_jian') {
      return $r('app.media.cover_folded_jian')
    }
    if (key === 'cover_tea_dawn') {
      return $r('app.media.cover_tea_dawn')
    }
    if (key === 'texture_rice_paper') {
      return $r('app.media.texture_rice_paper')
    }
    if (key === 'empty_first_jian') {
      return $r('app.media.empty_first_jian')
    }
    return $r('app.media.hero_dawn_window')
  }

  static keyForId(id: string): string {
    const keys: string[] = [
      'hero_dawn_window',
      'banner_letter_desk',
      'banner_gold_beam',
      'cover_folded_jian',
      'cover_tea_dawn'
    ]
    let h = 0
    for (let i = 0; i < id.length; i++) {
      h = h + id.charCodeAt(i)
    }
    const idx = h % keys.length
    if (idx < 0) {
      return keys[0]
    }
    return keys[idx]
  }
}
