import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { SlipItem } from '../../models/SlipModels'

@Component
export struct SlipListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: SlipItem = new SlipItem()
  onOpen: (id: string) => void = () => {}
  onToggle: (id: string) => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        if (this.item.isCompleted) {
          AppIcon({ name: 'check', iconSize: 16, color: Theme.colors().brandOnPrimary })
        }
      }
      .width(24)
      .height(24)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.item.isCompleted ? Theme.colors().brandPrimary : 'transparent')
      .borderRadius(Theme.radius.pill)
      .border({
        width: this.item.isCompleted ? 0 : 1.5,
        color: Theme.colors().brandPrimary
      })
      .onClick((): void => { this.onToggle(this.item.id) })

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.item.isCompleted ? Theme.colors().textTertiary : Theme.colors().textPrimary)
            .decoration({ type: this.item.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
            .layoutWeight(1)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (this.item.isImportant) {
            Text('重要')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }
        }
        .width('100%')
        Text(this.item.metaLine())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.item.isReminderEnabled) {
        AppIcon({ name: 'alert', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
      }
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { this.onOpen(this.item.id) })
  }
}
