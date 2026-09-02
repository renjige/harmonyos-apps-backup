export class ZhiweiMedia {
  static heroDesk(): Resource {
    return $r('app.media.hero_desk')
  }

  static bannerInsight(): Resource {
    return $r('app.media.banner_insight')
  }

  static bannerQuotes(): Resource {
    return $r('app.media.banner_quotes')
  }

  static coverWork(): Resource {
    return $r('app.media.cover_work')
  }

  static coverLife(): Resource {
    return $r('app.media.cover_life')
  }

  static coverStudy(): Resource {
    return $r('app.media.cover_study')
  }

  static coverSpark(): Resource {
    return $r('app.media.cover_spark')
  }

  static emptyInk(): Resource {
    return $r('app.media.empty_ink')
  }

  static coverOf(key: string): Resource {
    if (key === 'cover_work') {
      return ZhiweiMedia.coverWork()
    }
    if (key === 'cover_life') {
      return ZhiweiMedia.coverLife()
    }
    if (key === 'cover_study') {
      return ZhiweiMedia.coverStudy()
    }
    if (key === 'cover_spark') {
      return ZhiweiMedia.coverSpark()
    }
    if (key === 'empty_ink') {
      return ZhiweiMedia.emptyInk()
    }
    if (key === 'hero_desk') {
      return ZhiweiMedia.heroDesk()
    }
    if (key === 'banner_insight') {
      return ZhiweiMedia.bannerInsight()
    }
    return ZhiweiMedia.bannerQuotes()
  }

  static coverKeyOfCategory(category: string): string {
    if (category === 'work' || category === 'work_tip') {
      return 'cover_work'
    }
    if (category === 'life' || category === 'life_wiki') {
      return 'cover_life'
    }
    if (category === 'study' || category === 'growth') {
      return 'banner_insight'
    }
    if (category === 'science') {
      return 'cover_study'
    }
    if (category === 'culture') {
      return 'empty_ink'
    }
    return 'cover_spark'
  }
}
