export class TuceMedia {
  static cover(key: string): Resource {
    if (key === 'warmup') {
      return $r('app.media.cat_warmup')
    }
    if (key === 'stretch') {
      return $r('app.media.cat_stretch')
    }
    if (key === 'cardio') {
      return $r('app.media.cat_cardio')
    }
    if (key === 'strength') {
      return $r('app.media.cat_strength')
    }
    if (key === 'core') {
      return $r('app.media.cat_core')
    }
    if (key === 'flex') {
      return $r('app.media.cat_flex')
    }
    if (key === 'balance') {
      return $r('app.media.cat_balance')
    }
    if (key === 'relax') {
      return $r('app.media.cat_relax')
    }
    if (key === 'empty') {
      return $r('app.media.empty_album')
    }
    return $r('app.media.hero_home')
  }
}
