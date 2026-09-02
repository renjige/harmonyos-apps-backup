/** coverKey → 本机影像；一 key 一图 */
export class HeartNoteMedia {
  static cover(key: string): Resource {
    if (key === 'hero_window_paper') {
      return $r('app.media.hero_window_paper')
    }
    if (key === 'hero_desk_letter') {
      return $r('app.media.hero_desk_letter')
    }
    if (key === 'hero_tea_light') {
      return $r('app.media.hero_tea_light')
    }
    if (key === 'hero_folded_note') {
      return $r('app.media.hero_folded_note')
    }
    if (key === 'cover_evening_lamp') {
      return $r('app.media.cover_evening_lamp')
    }
    if (key === 'cover_morning_table') {
      return $r('app.media.cover_morning_table')
    }
    if (key === 'cover_park_bench') {
      return $r('app.media.cover_park_bench')
    }
    if (key === 'cover_night_paper') {
      return $r('app.media.cover_night_paper')
    }
    if (key === 'banner_write') {
      return $r('app.media.banner_write')
    }
    if (key === 'banner_review') {
      return $r('app.media.banner_review')
    }
    return $r('app.media.hero_window_paper')
  }

  static coverForMood(mood: string): string {
    if (mood === 'joyful') {
      return 'cover_morning_table'
    }
    if (mood === 'calm') {
      return 'hero_window_paper'
    }
    if (mood === 'relaxed') {
      return 'hero_tea_light'
    }
    if (mood === 'ordinary') {
      return 'hero_desk_letter'
    }
    if (mood === 'low') {
      return 'cover_night_paper'
    }
    return 'hero_folded_note'
  }
}
