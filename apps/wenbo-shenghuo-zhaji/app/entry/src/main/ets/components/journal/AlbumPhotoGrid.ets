import { Theme } from '../design-system/Theme'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'

/** 相册详情 / 创建表单 — 单张图片格 */
@Component
export struct AlbumPhotoTile {
  @Prop photoKey: string = ''
  @Prop tileSize: number = 108

  build() {
    if (JournalImageCatalog.isLocalKey(this.photoKey)) {
      Image(JournalImageCatalog.localUriFromKey(this.photoKey))
        .width(this.tileSize)
        .height(this.tileSize)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
    } else {
      Image(JournalMedia.coverMedia(this.photoKey))
        .width(this.tileSize)
        .height(this.tileSize)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
    }
  }
}

/** 相册图片网格 */
@Component
export struct AlbumPhotoGrid {
  @Prop photoKeys: string[] = []
  @Prop columns: number = 3

  build() {
    if (this.photoKeys.length === 0) {
      Column()
    } else {
      Grid() {
        ForEach(this.photoKeys, (key: string) => {
          GridItem() {
            AlbumPhotoTile({ photoKey: key })
          }
        }, (key: string) => key)
      }
      .columnsTemplate(this.columns === 3 ? '1fr 1fr 1fr' : '1fr 1fr')
      .columnsGap(Theme.space.s2)
      .rowsGap(Theme.space.s2)
      .width('100%')
    }
  }
}
