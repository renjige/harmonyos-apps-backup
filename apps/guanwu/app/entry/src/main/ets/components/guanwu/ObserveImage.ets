import { Theme } from '../design-system/Theme'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct ObserveImage {
  @Prop @Watch('onSourceChange') path: string = ''
  @Prop @Watch('onSourceChange') refreshKey: string = ''
  @Prop imgWidth: number = 96
  @Prop imgHeight: number = 96
  @Prop radius: number = Theme.radius.sm
  @State displayUri: string = ''

  aboutToAppear(): void {
    this.syncUri()
  }

  onSourceChange(): void {
    this.syncUri()
  }

  private syncUri(): void {
    this.displayUri = this.path.length > 0 ? ImagePathUtil.toDisplayUri(this.path) : ''
  }

  build() {
    if (this.path.length === 0) {
      Column()
        .width(this.imgWidth)
        .height(this.imgHeight)
    } else {
      Image(this.displayUri)
        .width(this.imgWidth)
        .height(this.imgHeight)
        .borderRadius(this.radius)
        .objectFit(ImageFit.Cover)
        .alt('观察配图')
    }
  }
}
