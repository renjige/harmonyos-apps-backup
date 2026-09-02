/** coverKey → 本机影像；一 key 一图 */

export class TreasureMedia {
  static resource(key: string): Resource {
    if (key === 'cover_history') {
      return $r('app.media.cover_history')
    }
    if (key === 'cover_science') {
      return $r('app.media.cover_science')
    }
    if (key === 'cover_literature') {
      return $r('app.media.cover_literature')
    }
    if (key === 'cover_art') {
      return $r('app.media.cover_art')
    }
    if (key === 'cover_philosophy') {
      return $r('app.media.cover_philosophy')
    }
    if (key === 'cover_general') {
      return $r('app.media.cover_general')
    }
    if (key === 'card_history_paper') {
      return $r('app.media.card_history_paper')
    }
    if (key === 'card_science_light') {
      return $r('app.media.card_science_light')
    }
    if (key === 'card_literature_shijing') {
      return $r('app.media.card_literature_shijing')
    }
    if (key === 'card_art_dunhuang') {
      return $r('app.media.card_art_dunhuang')
    }
    if (key === 'card_philosophy_socrates') {
      return $r('app.media.card_philosophy_socrates')
    }
    if (key === 'card_general_compass') {
      return $r('app.media.card_general_compass')
    }
    if (key === 'card_science_dna') {
      return $r('app.media.card_science_dna')
    }
    if (key === 'hero_treasure') {
      return $r('app.media.hero_treasure')
    }
    return TreasureMedia.byCategory(key)
  }

  static byCategory(category: string): Resource {
    if (category === 'history') {
      return $r('app.media.cover_history')
    }
    if (category === 'science') {
      return $r('app.media.cover_science')
    }
    if (category === 'literature') {
      return $r('app.media.cover_literature')
    }
    if (category === 'art') {
      return $r('app.media.cover_art')
    }
    if (category === 'philosophy') {
      return $r('app.media.cover_philosophy')
    }
    return $r('app.media.cover_general')
  }
}
