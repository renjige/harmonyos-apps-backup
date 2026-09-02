import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoTask } from '../../models/RenoModels'

@Component
export struct TaskRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoTask = new RenoTask()
  onToggle: (item: RenoTask) => void = (_i: RenoTask) => {}
  onOpen: (item: RenoTask) => void = (_i: RenoTask) => {}

  build() {
    Row({ space: 12 }) {
      Column() {
        if (this.item.status === 'done') {
          AppIcon({ name: 'check', iconSize: 16, color: Theme.colors().brandOnPrimary })
        }
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor(this.item.status === 'done' ? Theme.colors().success : Theme.colors().surfaceSubtle)
      .border({
        width: this.item.status === 'done' ? 0 : 1.5,
        color: this.item.status === 'doing' ? Theme.colors().brandPrimary : Theme.colors().strokeStrong
      })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onToggle(this.item))

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.item.status === 'done' ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({
            type: this.item.status === 'done' ? TextDecorationType.LineThrough : TextDecorationType.None
          })
          .maxLines(1)
          .width('100%')
        Text(`${this.item.stage} · ${RenoDates.taskLabel(this.item.status)}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => this.onOpen(this.item))

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.onOpen(this.item))
  }
}
