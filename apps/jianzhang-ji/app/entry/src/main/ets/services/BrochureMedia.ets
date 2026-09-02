/**
 * coverKey → $r('app.media.*') 校园摄影占位映射
 */
export class BrochureMedia {
  static cover(key: string): Resource {
    if (key === 'cover_tsinghua') {
      return $r('app.media.cover_tsinghua')
    }
    if (key === 'cover_pku') {
      return $r('app.media.cover_pku')
    }
    if (key === 'cover_fudan') {
      return $r('app.media.cover_fudan')
    }
    if (key === 'cover_zju') {
      return $r('app.media.cover_zju')
    }
    if (key === 'cover_sjtu') {
      return $r('app.media.cover_sjtu')
    }
    if (key === 'cover_nju') {
      return $r('app.media.cover_nju')
    }
    if (key === 'cover_whu') {
      return $r('app.media.cover_whu')
    }
    if (key === 'cover_hust') {
      return $r('app.media.cover_hust')
    }
    if (key === 'cover_sysu') {
      return $r('app.media.cover_sysu')
    }
    if (key === 'cover_xmu') {
      return $r('app.media.cover_xmu')
    }
    if (key === 'cover_scu') {
      return $r('app.media.cover_scu')
    }
    if (key === 'cover_jlu') {
      return $r('app.media.cover_jlu')
    }
    if (key === 'cover_sdu') {
      return $r('app.media.cover_sdu')
    }
    if (key === 'cover_csu') {
      return $r('app.media.cover_csu')
    }
    if (key === 'cover_hnu') {
      return $r('app.media.cover_hnu')
    }
    if (key === 'cover_cqu') {
      return $r('app.media.cover_cqu')
    }
    if (key === 'cover_xjtu') {
      return $r('app.media.cover_xjtu')
    }
    if (key === 'cover_hit') {
      return $r('app.media.cover_hit')
    }
    if (key === 'cover_buaa') {
      return $r('app.media.cover_buaa')
    }
    if (key === 'cover_tongji') {
      return $r('app.media.cover_tongji')
    }
    if (key === 'cover_seu') {
      return $r('app.media.cover_seu')
    }
    if (key === 'cover_nankai') {
      return $r('app.media.cover_nankai')
    }
    if (key === 'cover_news_policy') {
      return $r('app.media.cover_news_policy')
    }
    if (key === 'cover_news_tier') {
      return $r('app.media.cover_news_tier')
    }
    if (key === 'cover_news_guide') {
      return $r('app.media.cover_news_guide')
    }
    if (key === 'cover_news_mistake') {
      return $r('app.media.cover_news_mistake')
    }
    if (key === 'cover_news_safety') {
      return $r('app.media.cover_news_safety')
    }
    return $r('app.media.cover_campus_default')
  }

  static hero(): Resource {
    return $r('app.media.hero_enrollment')
  }
}
