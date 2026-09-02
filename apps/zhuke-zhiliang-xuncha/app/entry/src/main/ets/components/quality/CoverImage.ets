import { QualityMedia } from '../../services/QualityMedia'

@Component
export struct CoverImage {
  @Prop coverKey: string = 'hero_home'
  @Prop imgWidth: number = 72
  @Prop imgHeight: number = 72
  @Prop radius: number = 12

  build() {
    if (QualityMedia.isFileUri(this.coverKey)) {
      Image(this.coverKey)
        .width(this.imgWidth)
        .height(this.imgHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
        .alt('现场图片')
    } else {
      Image(QualityMedia.cover(this.coverKey))
        .width(this.imgWidth)
        .height(this.imgHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.radius)
        .alt('现场图片')
    }
  }
}
