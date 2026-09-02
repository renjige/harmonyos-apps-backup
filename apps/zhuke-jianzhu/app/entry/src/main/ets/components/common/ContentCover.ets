import { Theme } from '../design-system/Theme'
import { MediaCatalog } from '../../config/MediaCatalog'

/** 统一内容封面 — Banner / 工程 / 资讯 / 证书，禁止色块占位 */
@Component
export struct ContentCover {
  @Prop imageKey: string = ''
  @Prop label: string = ''
  @Prop coverHeight: number = 120
  @Prop coverRadius: number = Theme.radius.md
  @Prop showGradient: boolean = true

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(MediaCatalog.byKey(this.imageKey))
        .width('100%')
        .height(this.coverHeight)
        .objectFit(ImageFit.Cover)
        .borderRadius(this.coverRadius)

      if (this.showGradient) {
        Column()
          .width('100%')
          .height(Math.min(56, this.coverHeight * 0.45))
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.72)', 1]]
          })
          .borderRadius({
            bottomLeft: this.coverRadius,
            bottomRight: this.coverRadius
          })
      }

      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding(Theme.space.s3)
      }
    }
    .width('100%')
    .clip(true)
    .borderRadius(this.coverRadius)
  }
}
