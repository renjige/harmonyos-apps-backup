import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TableRowItem } from '../../models/MathModels'
import { MathCatalog } from '../../services/MathCatalog'

@Component
export struct TimesTableOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: TableRowItem[] = []
  onClose: () => void = () => {}
  onDrill: (n: number) => void = (_n: number) => {}

  aboutToAppear(): void {
    this.rows = MathCatalog.tableRows()
  }

  build() {
    Column() {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onClose())
        Text('九九口诀表')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.s2, right: Theme.space.s2, top: Theme.space.s2 })

      Text('先看口诀，再点一行专练。乘法和除法会对着出。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.s6, right: Theme.space.s6, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.rows, (row: TableRowItem) => {
            Column({ space: Theme.space.s1 }) {
              Text(row.title)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(row.preview)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Text('点这里专练这一行')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
            .onClick(() => this.onDrill(row.n))
          }, (row: TableRowItem) => row.id)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
