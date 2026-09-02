import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct LifeSandboxImage {
  @Prop srcPath: string = ''
  @Prop imgWidth: number = 64
  @Prop imgHeight: number = 64
  @Prop squareFill: boolean = false
  @Prop radius: number = 8

  build() {
    if (this.squareFill) {
      Image(ImagePathUtil.toDisplayUri(this.srcPath))
        .width('100%')
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
    } else {
      Image(ImagePathUtil.toDisplayUri(this.srcPath))
        .width(this.imgWidth)
        .height(this.imgHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
    }
  }
}
