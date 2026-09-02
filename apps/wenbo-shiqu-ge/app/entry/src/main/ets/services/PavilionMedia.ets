/** coverMedia → 本机影像；一 key 一图，禁止共图 */

export class PavilionMedia {
  static resource(key: string): Resource {
    if (key === 'hero_bg') {
      return $r('app.media.hero_bg')
    }
    if (key === 'banner_01') {
      return $r('app.media.banner_01')
    }
    if (key === 'banner_02') {
      return $r('app.media.banner_02')
    }
    if (key === 'cover_hist_01') {
      return $r('app.media.cover_hist_01')
    }
    if (key === 'cover_hist_02') {
      return $r('app.media.cover_hist_02')
    }
    if (key === 'cover_sci_01') {
      return $r('app.media.cover_sci_01')
    }
    if (key === 'cover_sci_02') {
      return $r('app.media.cover_sci_02')
    }
    if (key === 'cover_life_01') {
      return $r('app.media.cover_life_01')
    }
    if (key === 'cover_life_02') {
      return $r('app.media.cover_life_02')
    }
    if (key === 'cover_career_01') {
      return $r('app.media.cover_career_01')
    }
    if (key === 'cover_career_02') {
      return $r('app.media.cover_career_02')
    }
    if (key === 'cover_daily_01') {
      return $r('app.media.cover_daily_01')
    }
    if (key === 'cover_daily_02') {
      return $r('app.media.cover_daily_02')
    }
    if (key === 'cover_daily_03') {
      return $r('app.media.cover_daily_03')
    }
    if (key === 'cover_daily_04') {
      return $r('app.media.cover_daily_04')
    }
    if (key === 'cover_fun_01') {
      return $r('app.media.cover_fun_01')
    }
    if (key === 'cover_fun_02') {
      return $r('app.media.cover_fun_02')
    }
    if (key === 'cover_nature_01') {
      return $r('app.media.cover_nature_01')
    }
    if (key === 'cover_nature_02') {
      return $r('app.media.cover_nature_02')
    }
    if (key === 'cover_art_01') {
      return $r('app.media.cover_art_01')
    }
    if (key === 'cover_art_02') {
      return $r('app.media.cover_art_02')
    }
    if (key === 'cover_col_01') {
      return $r('app.media.cover_col_01')
    }
    if (key === 'cover_col_02') {
      return $r('app.media.cover_col_02')
    }
    if (key === 'cover_col_03') {
      return $r('app.media.cover_col_03')
    }
    if (key === 'cover_col_04') {
      return $r('app.media.cover_col_04')
    }
    if (key === 'cover_col_05') {
      return $r('app.media.cover_col_05')
    }
    return $r('app.media.hero_bg')
  }

  static pickKeys(): string[] {
    const keys: string[] = [
      'hero_bg', 'banner_01', 'cover_hist_01', 'cover_sci_01', 'cover_life_01',
      'cover_fun_01', 'cover_nature_01', 'cover_art_01'
    ]
    return keys
  }
}
