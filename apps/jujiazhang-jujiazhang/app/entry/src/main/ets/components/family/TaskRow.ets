import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FamilyTaskItem } from '../../models/FamilyTaskModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct TaskRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: FamilyTaskItem = new FamilyTaskItem()
  @Prop showDate: boolean = false
  onToggle: (item: FamilyTaskItem) => void = (_item: FamilyTaskItem) => {}
  onOpen: (item: FamilyTaskItem) => void = (_item: FamilyTaskItem) => {}

  private metaLine(): string {
    const time = this.item.time.length > 0 ? this.item.time : '全天'
    if (this.showDate) {
      return `${this.item.date}  ${time}`
    }
    return time
  }

  build() {
    Row({ space: 12 }) {
      Column() {
        if (this.item.completed) {
          AppIcon({ name: 'check', iconSize: 18, color: Theme.colors().brandOnPrimary })
        }
      }
      .width(28)
      .height(28)
      .borderRadius(14)
      .backgroundColor(this.item.completed ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .border({
        width: this.item.completed ? 0 : 1.5,
        color: Theme.colors().brandPrimary
      })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onToggle(this.item))

      Image(TaskMedia.cover(this.item.coverKey()))
        .width(48)
        .height(48)
        .borderRadius(14)
        .objectFit(ImageFit.Cover)
        .onClick(() => this.onOpen(this.item))

      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.item.completed ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.item.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .width('100%')
        Row({ space: 8 }) {
          Text(this.metaLine())
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(this.item.category)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.sm)
          if (this.item.assignee.length > 0) {
            Text(this.item.assignee)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => this.onOpen(this.item))

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        .onClick(() => this.onOpen(this.item))
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(VerticalAlign.Center)
    .opacity(this.item.completed ? 0.72 : 1)
    .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
  }
}
