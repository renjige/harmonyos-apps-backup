/** coverKey → 本机影像；一 key 一图，禁止共图 */

export class InkMedia {
  static resource(key: string): Resource {
    if (key === 'hero_ink') {
      return $r('app.media.hero_ink')
    }
    if (key === 'banner_study') {
      return $r('app.media.banner_study')
    }
    if (key === 'banner_tea') {
      return $r('app.media.banner_tea')
    }
    if (key === 'cover_ex_lunyu') {
      return $r('app.media.cover_ex_lunyu')
    }
    if (key === 'cover_ex_mengzi') {
      return $r('app.media.cover_ex_mengzi')
    }
    if (key === 'cover_ex_zhuangzi') {
      return $r('app.media.cover_ex_zhuangzi')
    }
    if (key === 'cover_ex_laozi') {
      return $r('app.media.cover_ex_laozi')
    }
    if (key === 'cover_ex_shijing') {
      return $r('app.media.cover_ex_shijing')
    }
    if (key === 'cover_list_xiushen') {
      return $r('app.media.cover_list_xiushen')
    }
    if (key === 'cover_list_chushi') {
      return $r('app.media.cover_list_chushi')
    }
    if (key === 'cover_list_shanshui') {
      return $r('app.media.cover_list_shanshui')
    }
    if (key === 'cover_essay_01') {
      return $r('app.media.cover_essay_01')
    }
    if (key === 'cover_essay_02') {
      return $r('app.media.cover_essay_02')
    }
    if (key === 'cover_essay_03') {
      return $r('app.media.cover_essay_03')
    }
    return $r('app.media.cover_ex_lunyu')
  }
}
