export class HazardMedia {
  static cover(key: string): Resource {
    if (key === 'banner_edge') {
      return $r('app.media.banner_edge')
    }
    if (key === 'cover_electric') {
      return $r('app.media.cover_electric')
    }
    if (key === 'cover_fire') {
      return $r('app.media.cover_fire')
    }
    if (key === 'cover_height') {
      return $r('app.media.cover_height')
    }
    if (key === 'cover_civil') {
      return $r('app.media.cover_civil')
    }
    if (key === 'empty_site') {
      return $r('app.media.empty_site')
    }
    return $r('app.media.hero_site')
  }
}
