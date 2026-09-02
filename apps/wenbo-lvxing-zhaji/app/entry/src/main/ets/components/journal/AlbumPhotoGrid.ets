import { Theme } from '../design-system/Theme'
import { JournalMedia } from '../../services/JournalMedia'

/** 相册详情 / 创建表单 — 单张图片格 */
@Component
export struct AlbumPhotoTile {
  @Prop photoKey: string = ''
  @Prop tileSize: number = 108
  @Prop fillCell: boolean = false
  @Prop selected: boolean = false
  @Prop highlighted: boolean = false
  onTap: () => void = () => {}

  build() {
    if (this.fillCell) {
      Image(JournalMedia.resolveImage(this.photoKey))
        .width('100%')
        .aspectRatio(1)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
        .opacity(this.selected ? 1 : 0.55)
        .border({
          width: this.highlighted ? 3 : (this.selected ? 2 : 0),
          color: this.highlighted ? Theme.colors().brandAccent : Theme.colors().brandPrimary
        })
        .onClick((): void => { this.onTap() })
    } else {
      Image(JournalMedia.resolveImage(this.photoKey))
        .width(this.tileSize)
        .height(this.tileSize)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
        .opacity(this.selected ? 1 : 0.55)
        .border({
          width: this.highlighted ? 3 : (this.selected ? 2 : 0),
          color: this.highlighted ? Theme.colors().brandAccent : Theme.colors().brandPrimary
        })
        .onClick((): void => { this.onTap() })
    }
  }
}

/** 相册图片网格 — Grid 三列左对齐，避免 Flex SpaceBetween 两图中间空位 */
@Component
export struct AlbumPhotoGrid {
  @Prop photoKeys: string[] = []
  @Prop columns: number = 3
  @Prop activeKey: string = ''
  @Prop gridRevision: number = 0
  onPhotoTap: (key: string) => void = () => {}

  private columnsTemplate(): string {
    if (this.columns === 2) {
      return '1fr 1fr'
    }
    return '1fr 1fr 1fr'
  }

  build() {
    if (this.photoKeys.length === 0) {
      Column()
    } else {
      Grid() {
        ForEach(this.photoKeys, (key: string, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              AlbumPhotoTile({
                photoKey: key,
                fillCell: true,
                selected: true,
                highlighted: this.activeKey === key,
                onTap: (): void => { this.onPhotoTap(key) }
              })
              if (this.activeKey === key) {
                Text('选中')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textOnInverse)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .margin({ top: 6, right: 6 })
              }
            }
            .width('100%')
          }
        }, (key: string, index: number) => `${this.gridRevision}_${index}_${key}`)
      }
      .columnsTemplate(this.columnsTemplate())
      .columnsGap(Theme.space.s2)
      .rowsGap(Theme.space.s2)
      .width('100%')
    }
  }
}

/** 旅行图库 / 预设配图多选（创建相册、追加内置图） */
@Component
export struct PresetPhotoPicker {
  @Prop options: string[] = []
  @Prop optionLabels: string[] = []
  @Prop selectedKeys: string[] = []
  onToggle: (key: string) => void = () => {}

  private labelOf(key: string, index: number): string {
    if (index < this.optionLabels.length && this.optionLabels[index].length > 0) {
      return this.optionLabels[index]
    }
    return ''
  }

  private isSelected(key: string): boolean {
    for (const k of this.selectedKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  build() {
    Grid() {
      ForEach(this.options, (key: string, index: number) => {
        GridItem() {
          Column({ space: 4 }) {
            Stack({ alignContent: Alignment.TopEnd }) {
              AlbumPhotoTile({
                photoKey: key,
                fillCell: true,
                selected: this.isSelected(key),
                onTap: (): void => { this.onToggle(key) }
              })
              if (this.isSelected(key)) {
                Text('选')
                  .fontSize(Theme.type.overline)
                  .fontColor(Theme.colors().textOnInverse)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
                  .margin({ top: 6, right: 6 })
              }
            }
            .width('100%')
            if (this.labelOf(key, index).length > 0) {
              Text(this.labelOf(key, index))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')
                .textAlign(TextAlign.Center)
            }
          }
          .width('100%')
          .onClick((): void => { this.onToggle(key) })
        }
      }, (key: string) => key)
    }
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(Theme.space.s2)
    .rowsGap(Theme.space.s3)
    .width('100%')
  }
}
