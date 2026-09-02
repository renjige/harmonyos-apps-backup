import { Theme } from '../design-system/Theme'
import { ImagePathUtil } from '../../services/ImagePathUtil'

/** 本机沙箱照片：禁止把 Resource 与 file URI 写在同一 Image 三元表达式里 */
@Component
export struct LocalPhotoImage {
  @Prop uri: string = ''
  @Prop tileW: number = 72
  @Prop tileH: number = 72
  @Prop radius: number = 12
  @Prop stretch: boolean = false
  @Prop squareFill: boolean = false

  private displayUri(): string {
    return ImagePathUtil.toDisplayUri(this.uri)
  }

  build() {
    if (this.squareFill) {
      if (this.displayUri().length > 0) {
        Image(this.displayUri())
          .width('100%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius(this.radius)
          .syncLoad(true)
      } else {
        Image($r('app.media.empty_warm'))
          .width('100%')
          .aspectRatio(1)
          .objectFit(ImageFit.Cover)
          .borderRadius(this.radius)
      }
    } else if (this.displayUri().length > 0) {
      Image(this.displayUri())
        .width(this.stretch ? '100%' : this.tileW)
        .height(this.tileH)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
        .syncLoad(true)
    } else {
      Image($r('app.media.empty_warm'))
        .width(this.stretch ? '100%' : this.tileW)
        .height(this.tileH)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
        .backgroundColor(Theme.colors().surfaceSubtle)
    }
  }
}
