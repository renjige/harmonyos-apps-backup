import { Theme } from '../design-system/Theme'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct ResearchSandboxImage {
  @Prop srcPath: string = ''
  @Prop imgWidth: number | string = '100%'
  @Prop imgHeight: number = 140
  @Prop radius: number = Theme.radius.md

  build() {
    if (this.srcPath.length > 0) {
      Image(ImagePathUtil.toDisplayUri(this.srcPath))
        .width(this.imgWidth)
        .height(this.imgHeight)
        .borderRadius(this.radius)
        .objectFit(ImageFit.Cover)
    }
  }
}
