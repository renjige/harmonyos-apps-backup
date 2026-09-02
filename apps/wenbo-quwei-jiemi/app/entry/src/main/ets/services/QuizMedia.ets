export class QuizMedia {
  static cover(key: string): Resource {
    if (key === 'cat_math') {
      return $r('app.media.cat_math')
    }
    if (key === 'cat_visual') {
      return $r('app.media.cat_visual')
    }
    if (key === 'cat_life') {
      return $r('app.media.cat_life')
    }
    if (key === 'cat_logic') {
      return $r('app.media.cat_logic')
    }
    if (key === 'cat_animal') {
      return $r('app.media.cat_animal')
    }
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'hero_space') {
      return $r('app.media.hero_space')
    }
    if (key === 'medal_first') {
      return $r('app.media.medal_first')
    }
    if (key === 'medal_streak') {
      return $r('app.media.medal_streak')
    }
    if (key === 'medal_puzzler') {
      return $r('app.media.medal_puzzler')
    }
    if (key === 'medal_wisdom') {
      return $r('app.media.medal_wisdom')
    }
    if (key === 'medal_observe') {
      return $r('app.media.medal_observe')
    }
    if (key === 'medal_math') {
      return $r('app.media.medal_math')
    }
    return $r('app.media.cat_riddle')
  }
}
