import { ObserveRecord } from '../models/ObserveModels'

export class ObserveMedia {
  static kindCover(kind: string): Resource {
    if (kind === 'mood') {
      return $r('app.media.cover_mood')
    }
    if (kind === 'scene') {
      return $r('app.media.cover_scene')
    }
    if (kind === 'thought') {
      return $r('app.media.cover_thought')
    }
    if (kind === 'environment') {
      return $r('app.media.cover_env')
    }
    return $r('app.media.hero_morning')
  }

  static hero(): Resource {
    return $r('app.media.hero_morning')
  }

  static banner(): Resource {
    return $r('app.media.banner_observe')
  }

  static empty(): Resource {
    return $r('app.media.empty_observe')
  }

  static recordThumb(record: ObserveRecord): Resource | string {
    if (record.hasImage()) {
      return record.imagePaths[0]
    }
    return ObserveMedia.kindCover(record.kind)
  }
}
