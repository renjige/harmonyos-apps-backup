export class InsectMedia {
  static cover(key: string): Resource {
    if (key === 'wiki_ladybug') {
      return $r('app.media.wiki_ladybug')
    }
    if (key === 'wiki_honeybee') {
      return $r('app.media.wiki_honeybee')
    }
    if (key === 'wiki_cabbage_white') {
      return $r('app.media.wiki_cabbage_white')
    }
    if (key === 'wiki_dragonfly') {
      return $r('app.media.wiki_dragonfly')
    }
    if (key === 'wiki_mantis') {
      return $r('app.media.wiki_mantis')
    }
    if (key === 'wiki_cricket') {
      return $r('app.media.wiki_cricket')
    }
    if (key === 'wiki_cicada') {
      return $r('app.media.wiki_cicada')
    }
    if (key === 'wiki_ant') {
      return $r('app.media.wiki_ant')
    }
    if (key === 'wiki_firefly') {
      return $r('app.media.wiki_firefly')
    }
    if (key === 'wiki_longhorn') {
      return $r('app.media.wiki_longhorn')
    }
    if (key === 'wiki_locust') {
      return $r('app.media.wiki_locust')
    }
    if (key === 'wiki_scarab') {
      return $r('app.media.wiki_scarab')
    }
    if (key === 'empty_notebook') {
      return $r('app.media.empty_notebook')
    }
    if (key === 'banner_season') {
      return $r('app.media.banner_season')
    }
    return $r('app.media.hero_leaf_dew')
  }
}
