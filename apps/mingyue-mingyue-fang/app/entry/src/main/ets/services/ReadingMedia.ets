/** coverKey → app.media 资源；一 key 一图，禁止共用 */
export class ReadingMedia {
  static coverMedia(key: string): Resource {
    if (key === 'hero_reading_desk') {
      return $r('app.media.hero_reading_desk')
    }
    if (key === 'hero_reading_classics') {
      return $r('app.media.hero_reading_classics')
    }
    if (key === 'hero_borrow_books') {
      return $r('app.media.hero_borrow_books')
    }
    if (key === 'hero_honest_reading') {
      return $r('app.media.hero_honest_reading')
    }
    if (key === 'hero_poetry_grace') {
      return $r('app.media.hero_poetry_grace')
    }
    if (key === 'hero_dialogue_books') {
      return $r('app.media.hero_dialogue_books')
    }
    if (key === 'hero_ladder_books') {
      return $r('app.media.hero_ladder_books')
    }
    if (key === 'book_classics_1') {
      return $r('app.media.book_classics_1')
    }
    if (key === 'book_classics_2') {
      return $r('app.media.book_classics_2')
    }
    if (key === 'book_classics_3') {
      return $r('app.media.book_classics_3')
    }
    if (key === 'book_classics_4') {
      return $r('app.media.book_classics_4')
    }
    if (key === 'book_classics_5') {
      return $r('app.media.book_classics_5')
    }
    if (key === 'book_classics_6') {
      return $r('app.media.book_classics_6')
    }
    if (key === 'book_default') {
      return $r('app.media.book_default')
    }
    return $r('app.media.book_default')
  }
}
