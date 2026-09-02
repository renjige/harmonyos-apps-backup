import { AppIconName } from '../components/design-system/AppIcon'

export class InsightMedia {
  static notebookIcon(id: string): AppIconName {
    if (id === 'nb_work') {
      return 'biz'
    }
    if (id === 'nb_read') {
      return 'book'
    }
    if (id === 'nb_life') {
      return 'heart'
    }
    return 'bookmark'
  }
}
