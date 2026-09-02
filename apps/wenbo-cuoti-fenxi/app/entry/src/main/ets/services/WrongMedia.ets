export class WrongMedia {
  static resource(key: string): Resource {
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'hero_lamp') {
      return $r('app.media.hero_lamp')
    }
    if (key === 'banner_review') {
      return $r('app.media.banner_review')
    }
    if (key === 'banner_progress') {
      return $r('app.media.banner_progress')
    }
    if (key === 'texture_paper') {
      return $r('app.media.texture_paper')
    }
    if (key === 'cover_math') {
      return $r('app.media.cover_math')
    }
    if (key === 'cover_chinese') {
      return $r('app.media.cover_chinese')
    }
    if (key === 'cover_english') {
      return $r('app.media.cover_english')
    }
    if (key === 'cover_physics') {
      return $r('app.media.cover_physics')
    }
    if (key === 'cover_chemistry') {
      return $r('app.media.cover_chemistry')
    }
    if (key === 'cover_biology') {
      return $r('app.media.cover_biology')
    }
    if (key === 'cover_history') {
      return $r('app.media.cover_history')
    }
    if (key === 'cover_geo') {
      return $r('app.media.cover_geo')
    }
    if (key === 'cover_politics') {
      return $r('app.media.cover_politics')
    }
    if (key === 'cover_other') {
      return $r('app.media.cover_other')
    }
    if (key === 'method_concept') {
      return $r('app.media.method_concept')
    }
    if (key === 'method_careless') {
      return $r('app.media.method_careless')
    }
    if (key === 'method_misread') {
      return $r('app.media.method_misread')
    }
    if (key === 'method_way') {
      return $r('app.media.method_way')
    }
    if (key === 'method_other') {
      return $r('app.media.method_other')
    }
    if (key === 'article_loop') {
      return $r('app.media.article_loop')
    }
    if (key === 'article_tag') {
      return $r('app.media.article_tag')
    }
    if (key === 'article_parent') {
      return $r('app.media.article_parent')
    }
    if (key === 'article_exam') {
      return $r('app.media.article_exam')
    }
    if (key === 'tip_week') {
      return $r('app.media.tip_week')
    }
    if (key === 'tip_cause') {
      return $r('app.media.tip_cause')
    }
    if (key === 'tip_master') {
      return $r('app.media.tip_master')
    }
    if (key === 'tip_photo') {
      return $r('app.media.tip_photo')
    }
    if (key === 'tip_export') {
      return $r('app.media.tip_export')
    }
    if (key === 'tip_balance') {
      return $r('app.media.tip_balance')
    }
    return $r('app.media.hero_desk')
  }

  static subjectCover(code: string): string {
    if (code === 'math') {
      return 'cover_math'
    }
    if (code === 'chinese') {
      return 'cover_chinese'
    }
    if (code === 'english') {
      return 'cover_english'
    }
    if (code === 'physics') {
      return 'cover_physics'
    }
    if (code === 'chemistry') {
      return 'cover_chemistry'
    }
    if (code === 'biology') {
      return 'cover_biology'
    }
    if (code === 'history') {
      return 'cover_history'
    }
    if (code === 'geography') {
      return 'cover_geo'
    }
    if (code === 'politics') {
      return 'cover_politics'
    }
    return 'cover_other'
  }
}
