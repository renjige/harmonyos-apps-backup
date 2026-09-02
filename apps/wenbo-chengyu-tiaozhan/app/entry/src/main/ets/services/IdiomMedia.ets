export class IdiomMedia {
  static cover(key: string): Resource {
    if (key === 'hero_seal') {
      return $r('app.media.hero_seal')
    }
    if (key === 'cat_intro') {
      return $r('app.media.cat_intro')
    }
    if (key === 'cat_daily') {
      return $r('app.media.cat_daily')
    }
    if (key === 'cat_nature') {
      return $r('app.media.cat_nature')
    }
    if (key === 'cat_character') {
      return $r('app.media.cat_character')
    }
    if (key === 'cat_history') {
      return $r('app.media.cat_history')
    }
    if (key === 'cat_aspire') {
      return $r('app.media.cat_aspire')
    }
    if (key === 'cat_confuse') {
      return $r('app.media.cat_confuse')
    }
    if (key === 'cat_poetry') {
      return $r('app.media.cat_poetry')
    }
    if (key === 'cat_strategy') {
      return $r('app.media.cat_strategy')
    }
    if (key === 'cat_rare') {
      return $r('app.media.cat_rare')
    }
    return $r('app.media.hero_ink')
  }
}
