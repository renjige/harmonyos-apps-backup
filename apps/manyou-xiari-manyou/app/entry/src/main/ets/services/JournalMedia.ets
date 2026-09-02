import { JournalItem } from '../models/WanderModels'
import { WanderMedia } from './WanderMedia'

export class JournalMedia {
  static hasCover(item: JournalItem): boolean {
    if (item.photoUri.length > 0) {
      return true
    }
    return item.coverKey.length > 0
  }

  static coverIsFile(item: JournalItem): boolean {
    return item.photoUri.length > 0
  }

  static coverUri(item: JournalItem): string {
    if (item.photoUri.length > 0) {
      return item.photoUri
    }
    return ''
  }

  static coverResource(item: JournalItem): Resource {
    if (item.coverKey.length > 0) {
      return WanderMedia.resource(item.coverKey)
    }
    return WanderMedia.resource('hero_summer')
  }
}
