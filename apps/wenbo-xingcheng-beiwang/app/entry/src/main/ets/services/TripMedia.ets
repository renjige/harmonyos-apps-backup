/** coverKey → 本机影像；一 key 一图 */

export class TripMedia {
  static cover(key: string): Resource {
    if (key === 'tpl_weekend') {
      return $r('app.media.tpl_weekend')
    }
    if (key === 'tpl_appointment') {
      return $r('app.media.tpl_appointment')
    }
    return $r('app.media.tpl_business')
  }

  static empty(): Resource {
    return $r('app.media.empty_timeline')
  }

  static paper(): Resource {
    return $r('app.media.paper_desk')
  }
}
