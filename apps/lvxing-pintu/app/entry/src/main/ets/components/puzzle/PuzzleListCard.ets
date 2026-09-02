import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TravelPuzzle } from '../../models/PuzzleModels'
import { PuzzleLayoutGrid } from './PuzzleLayoutGrid'

@Component
export struct PuzzleListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TravelPuzzle = new TravelPuzzle()
  onTap: () => void = () => {}

  private dateText(): string {
    if (this.item.createdAt <= 0) {
      return ''
    }
    const d = new Date(this.item.createdAt)
    const m = d.getMonth() + 1
    const day = d.getDate()
    return `${d.getFullYear()}-${m < 10 ? '0' + m : m}-${day < 10 ? '0' + day : day}`
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text(this.item.title.length > 0 ? this.item.title : '未命名拼图')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Row() {
            AppIcon({ name: 'map', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            Text(this.item.location.length > 0 ? this.item.location : '未填写地点')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .margin({ left: Theme.space.s1 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .margin({ top: Theme.space.s1 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        if (this.item.favorited) {
          AppIcon({ name: 'heart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary, active: true })
        }
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      PuzzleLayoutGrid({
        layoutType: this.item.layoutType,
        pieces: this.item.pieces,
        compact: true
      })
        .margin({ top: Theme.space.s3 })

      Text(`${this.item.pieces.length} 张 · ${this.dateText()}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .margin({ top: Theme.space.s2 })
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .shadow({
      radius: 6,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(45,58,74,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.onTap())
  }
}
