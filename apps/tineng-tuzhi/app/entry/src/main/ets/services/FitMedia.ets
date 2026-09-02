export class FitMedia {
  static cover(key: string): Resource {
    if (key === 'atlas_warm') {
      return $r('app.media.atlas_warm')
    }
    if (key === 'atlas_stretch') {
      return $r('app.media.atlas_stretch')
    }
    if (key === 'atlas_strength') {
      return $r('app.media.atlas_strength')
    }
    if (key === 'atlas_balance') {
      return $r('app.media.atlas_balance')
    }
    if (key === 'atlas_relax') {
      return $r('app.media.atlas_relax')
    }
    if (key === 'ambient_chart') {
      return $r('app.media.ambient_chart')
    }
    return $r('app.media.hero_workout')
  }
}
