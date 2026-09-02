import { Theme } from '../design-system/Theme'
import { ObserveImage } from './ObserveImage'
import { GalleryCell } from '../../services/ObserveGalleryUtil'

@Component
export struct ObserveGalleryOverlay {
  @Prop cells: GalleryCell[] = []
  onClose: () => void = () => {}
  onOpenRecord: (id: string) => void = () => {}

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)

      Column() {
        Row() {
          Text('观物图集')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('关闭')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => this.onClose())
        }
        .width('100%')
        .padding(Theme.space.s4)

        if (this.cells.length === 0) {
          Text('还没有带配图的观察，去记录时添加 1–3 张图片吧')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .padding(Theme.space.s4)
        } else {
          Scroll() {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.cells, (cell: GalleryCell) => {
                Column({ space: 6 }) {
                  ObserveImage({ path: cell.path, imgWidth: 108, imgHeight: 108, radius: Theme.radius.sm })
                  Text(cell.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width(108)
                }
                .margin({ right: Theme.space.s2, bottom: Theme.space.s3 })
                .onClick((): void => this.onOpenRecord(cell.recordId))
              }, (cell: GalleryCell) => `${cell.recordId}-${cell.path}`)
            }
            .width('100%')
            .padding(Theme.space.s4)
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
  }
}
