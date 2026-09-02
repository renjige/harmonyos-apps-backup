export class MathMedia {
  static resource(key: string): Resource {
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'hero_paper') {
      return $r('app.media.hero_paper')
    }
    if (key === 'cover_add') {
      return $r('app.media.cover_add')
    }
    if (key === 'cover_sub') {
      return $r('app.media.cover_sub')
    }
    if (key === 'cover_mul') {
      return $r('app.media.cover_mul')
    }
    if (key === 'cover_div') {
      return $r('app.media.cover_div')
    }
    if (key === 'cover_mix') {
      return $r('app.media.cover_mix')
    }
    if (key === 'cover_challenge') {
      return $r('app.media.cover_challenge')
    }
    if (key === 'cover_wrong') {
      return $r('app.media.cover_wrong')
    }
    if (key === 'texture_wood') {
      return $r('app.media.texture_wood')
    }
    if (key === 'medal_first' || key === 'medal_star') {
      return $r('app.media.medal_star')
    }
    if (key === 'medal_streak') {
      return $r('app.media.medal_streak')
    }
    if (key === 'medal_hundred') {
      return $r('app.media.medal_hundred')
    }
    if (key === 'medal_ace') {
      return $r('app.media.medal_ace')
    }
    return $r('app.media.hero_desk')
  }
}
