import { Theme } from '../design-system/Theme'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'

@Component
export struct JournalCoverImage {
  @Prop coverKey: string = ''
  @Prop imageSize: number = 80
  @Prop cornerRadius: number = Theme.radius.lg

  build() {
    if (this.coverKey.length === 0) {
      Column()
    } else if (JournalImageCatalog.isLocalKey(this.coverKey)) {
      Image(JournalImageCatalog.localUriFromKey(this.coverKey))
        .width(this.imageSize)
        .height(this.imageSize)
        .borderRadius(this.cornerRadius)
        .objectFit(ImageFit.Cover)
    } else {
      Image(JournalMedia.coverMedia(this.coverKey))
        .width(this.imageSize)
        .height(this.imageSize)
        .borderRadius(this.cornerRadius)
        .objectFit(ImageFit.Cover)
    }
  }
}
