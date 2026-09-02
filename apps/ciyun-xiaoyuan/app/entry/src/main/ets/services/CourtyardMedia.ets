/** coverKey → $r('app.media.*')；一 key 一图，禁止合并映射 */
export class CourtyardMedia {
  static cover(key: string): Resource {
    if (key === 'hero_courtyard') {
      return $r('app.media.hero_courtyard')
    }
    if (key === 'banner_ink') {
      return $r('app.media.banner_ink')
    }
    if (key === 'banner_window') {
      return $r('app.media.banner_window')
    }
    if (key === 'cover_jingye') {
      return $r('app.media.cover_jingye')
    }
    if (key === 'cover_chunxiao') {
      return $r('app.media.cover_chunxiao')
    }
    if (key === 'cover_jiangxue') {
      return $r('app.media.cover_jiangxue')
    }
    if (key === 'cover_liangzhou') {
      return $r('app.media.cover_liangzhou')
    }
    if (key === 'cover_shuidiao') {
      return $r('app.media.cover_shuidiao')
    }
    if (key === 'cover_denggao') {
      return $r('app.media.cover_denggao')
    }
    if (key === 'cover_huanghe') {
      return $r('app.media.cover_huanghe')
    }
    if (key === 'cover_fengqiao') {
      return $r('app.media.cover_fengqiao')
    }
    if (key === 'cover_wangyue') {
      return $r('app.media.cover_wangyue')
    }
    if (key === 'cover_chusa') {
      return $r('app.media.cover_chusa')
    }
    if (key === 'cover_xiangsi') {
      return $r('app.media.cover_xiangsi')
    }
    if (key === 'cover_caoyuan') {
      return $r('app.media.cover_caoyuan')
    }
    if (key === 'cover_pusaman') {
      return $r('app.media.cover_pusaman')
    }
    if (key === 'cover_yumeiren') {
      return $r('app.media.cover_yumeiren')
    }
    if (key === 'cover_shengsheng') {
      return $r('app.media.cover_shengsheng')
    }
    if (key === 'cover_yulin') {
      return $r('app.media.cover_yulin')
    }
    if (key === 'cover_cipai') {
      return $r('app.media.cover_cipai')
    }
    if (key === 'cover_cipai2') {
      return $r('app.media.cover_cipai2')
    }
    if (key === 'cover_cipai3') {
      return $r('app.media.cover_cipai3')
    }
    if (key === 'cover_cipai4') {
      return $r('app.media.cover_cipai4')
    }
    if (key === 'cover_cipai5') {
      return $r('app.media.cover_cipai5')
    }
    if (key === 'cover_cipai_sd') {
      return $r('app.media.cover_cipai_sd')
    }
    if (key === 'cover_cipai_ymr') {
      return $r('app.media.cover_cipai_ymr')
    }
    if (key === 'cover_cipai_mjh') {
      return $r('app.media.cover_cipai_mjh')
    }
    if (key === 'cover_rhyme_ps') {
      return $r('app.media.cover_rhyme_ps')
    }
    if (key === 'cover_rhyme_cl') {
      return $r('app.media.cover_rhyme_cl')
    }
    if (key === 'cover_rhyme_xh') {
      return $r('app.media.cover_rhyme_xh')
    }
    if (key === 'cover_article_1') {
      return $r('app.media.cover_article_1')
    }
    if (key === 'cover_article_2') {
      return $r('app.media.cover_article_2')
    }
    if (key === 'cover_article_3') {
      return $r('app.media.cover_article_3')
    }
    if (key === 'cover_article_4') {
      return $r('app.media.cover_article_4')
    }
    if (key === 'cover_article_5') {
      return $r('app.media.cover_article_5')
    }
    return $r('app.media.hero_courtyard')
  }
}
