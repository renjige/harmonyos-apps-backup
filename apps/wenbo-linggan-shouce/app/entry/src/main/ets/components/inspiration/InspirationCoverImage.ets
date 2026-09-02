import { Theme } from '../design-system/Theme'
import { InspirationMedia } from '../../services/InspirationMedia'

/** 内置 media key 或 local: 相册图统一展示 */
@Component
export struct InspirationCoverImage {
  @Prop coverKey: string = ''
  @Prop imageWidth: string | number = '100%'
  @Prop imageHeight: number = 0
  @Prop useAspectRatio: boolean = true
  @Prop cornerRadius: number = Theme.radius.md
  @Prop imageOpacity: number = 1
  @Prop imageFit: ImageFit = ImageFit.Cover

  build() {
    if (this.coverKey.length === 0) {
      Column()
    } else if (InspirationMedia.isLocalKey(this.coverKey)) {
      Image(InspirationMedia.localUriFromKey(this.coverKey))
        .width(this.imageWidth)
        .height(this.imageHeight > 0 ? this.imageHeight : undefined)
        .aspectRatio(this.imageHeight > 0 ? undefined : (this.useAspectRatio ? 1 : undefined))
        .borderRadius(this.cornerRadius)
        .objectFit(this.imageFit)
        .opacity(this.imageOpacity)
    } else {
      Image(InspirationMedia.coverMedia(this.coverKey))
        .width(this.imageWidth)
        .height(this.imageHeight > 0 ? this.imageHeight : undefined)
        .aspectRatio(this.imageHeight > 0 ? undefined : (this.useAspectRatio ? 1 : undefined))
        .borderRadius(this.cornerRadius)
        .objectFit(this.imageFit)
        .opacity(this.imageOpacity)
    }
  }
}
