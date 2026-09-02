export class FolioMedia {
  static cover(key: string): Resource {
    if (key === 'cover_folio_work') {
      return $r('app.media.cover_folio_work')
    }
    if (key === 'cover_folio_life') {
      return $r('app.media.cover_folio_life')
    }
    if (key === 'hero_desk') {
      return $r('app.media.hero_desk')
    }
    if (key === 'banner_progress') {
      return $r('app.media.banner_progress')
    }
    if (key === 'banner_review') {
      return $r('app.media.banner_review')
    }
    if (key === 'empty_shelf') {
      return $r('app.media.empty_shelf')
    }
    if (key === 'paper_texture') {
      return $r('app.media.paper_texture')
    }
    return $r('app.media.cover_folio_study')
  }

  static coverKeys(): string[] {
    const keys: string[] = []
    keys.push('cover_folio_work')
    keys.push('cover_folio_study')
    keys.push('cover_folio_life')
    return keys
  }

  static coverLabel(key: string): string {
    if (key === 'cover_folio_work') {
      return '职场'
    }
    if (key === 'cover_folio_life') {
      return '生活'
    }
    return '学习'
  }
}
