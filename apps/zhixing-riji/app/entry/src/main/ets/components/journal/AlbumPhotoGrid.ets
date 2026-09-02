import { Theme } from '../design-system/Theme'
import { JournalMedia } from '../../services/JournalMedia'

/** 相册详情 / 创建表单 — 单张图片格 */
@Component
export struct AlbumPhotoTile {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop photoKey: string = ''
  @Prop tileSize: number = 108
  @Prop selected: boolean = true
  onTap: () => void = () => {}

  build() {
    Image(JournalMedia.coverMedia(this.photoKey))
      .width(this.tileSize)
      .height(this.tileSize)
      .borderRadius(Theme.radius.md)
      .objectFit(ImageFit.Cover)
      .opacity(this.selected ? 1 : 0.5)
      .border({
        width: this.selected ? 2 : 0,
        color: Theme.colors().brandPrimary
      })
      .onClick((): void => { this.onTap() })
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}

/** 相册图片网格（可点击查看大图） */
@Component
export struct AlbumPhotoGrid {
  @Prop photoKeys: string[] = []
  @Prop columns: number = 3
  onPhotoTap: (key: string) => void = () => {}

  build() {
    if (this.photoKeys.length === 0) {
      Column()
    } else {
      Grid() {
        ForEach(this.photoKeys, (key: string) => {
          GridItem() {
            AlbumPhotoTile({
              photoKey: key,
              tileSize: 108,
              selected: true,
              onTap: (): void => { this.onPhotoTap(key) }
            })
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
