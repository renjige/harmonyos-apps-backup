import { Theme } from '../design-system/Theme'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'

/** 详情 Hero / 列表封面：内置图 + 相册 local: 图 */
@Component
export struct JournalHeroImage {
  @Prop coverKey: string = ''
  @Prop fallbackKey: string = 'hero_morning_coffee'
  @Prop heroHeight: number = 200

  private resolvedKey(): string {
    if (this.coverKey.length > 0) {
      return this.coverKey
    }
    return this.fallbackKey
  }

  build() {
    if (JournalImageCatalog.isLocalKey(this.resolvedKey())) {
      Image(JournalImageCatalog.localUriFromKey(this.resolvedKey()))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    } else {
      Image(JournalMedia.coverMedia(this.resolvedKey()))
        .width('100%')
        .height(this.heroHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
    }
  }
}
