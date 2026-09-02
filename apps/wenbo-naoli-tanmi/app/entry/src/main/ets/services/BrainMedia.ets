export class BrainMedia {
  static cover(key: string): Resource {
    if (key === 'hero_aurora') {
      return $r('app.media.hero_aurora')
    }
    if (key === 'cover_memory') {
      return $r('app.media.cover_memory')
    }
    if (key === 'cover_sudoku') {
      return $r('app.media.cover_sudoku')
    }
    if (key === 'cover_stroop') {
      return $r('app.media.cover_stroop')
    }
    if (key === 'cover_math') {
      return $r('app.media.cover_math')
    }
    if (key === 'cover_pattern') {
      return $r('app.media.cover_pattern')
    }
    if (key === 'cover_know_palace') {
      return $r('app.media.cover_know_palace')
    }
    if (key === 'cover_know_stroop') {
      return $r('app.media.cover_know_stroop')
    }
    if (key === 'cover_know_sleep') {
      return $r('app.media.cover_know_sleep')
    }
    if (key === 'cover_know_sudoku') {
      return $r('app.media.cover_know_sudoku')
    }
    if (key === 'cover_know_focus') {
      return $r('app.media.cover_know_focus')
    }
    if (key === 'cover_know_pattern') {
      return $r('app.media.cover_know_pattern')
    }
    if (key === 'cover_know_streak') {
      return $r('app.media.cover_know_streak')
    }
    if (key === 'cover_know_myth') {
      return $r('app.media.cover_know_myth')
    }
    if (key === 'cover_ach_first') {
      return $r('app.media.cover_ach_first')
    }
    if (key === 'cover_ach_star') {
      return $r('app.media.cover_ach_star')
    }
    if (key === 'cover_ach_streak') {
      return $r('app.media.cover_ach_streak')
    }
    if (key === 'cover_ach_memory') {
      return $r('app.media.cover_ach_memory')
    }
    if (key === 'cover_ach_map') {
      return $r('app.media.cover_ach_map')
    }
    if (key === 'cover_ach_read') {
      return $r('app.media.cover_ach_read')
    }
    if (key === 'cover_ach_sudoku') {
      return $r('app.media.cover_ach_sudoku')
    }
    if (key === 'cover_ach_focus') {
      return $r('app.media.cover_ach_focus')
    }
    if (key === 'trail_nebula') {
      return $r('app.media.trail_nebula')
    }
    return $r('app.media.hero_aurora')
  }
}
