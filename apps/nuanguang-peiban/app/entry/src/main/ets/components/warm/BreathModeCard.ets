import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { WarmMediaCover } from './WarmMediaHero'
import { BreathModeItem } from '../../models/WarmCompanionModels'

@Component
export struct BreathModeCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: BreathModeItem = new BreathModeItem()
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      WarmMediaCover({
        coverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_breath_soft',
        tileSize: 72
      })

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`${this.item.rhythmLabel} · ${this.item.rounds} 轮`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onTap() })
  }
}
