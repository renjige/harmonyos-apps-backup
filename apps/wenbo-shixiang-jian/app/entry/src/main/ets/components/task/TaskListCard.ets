import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { TaskItem } from '../../models/TaskModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct TaskListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TaskItem = new TaskItem()
  @Prop compact: boolean = false
  onTap: () => void = () => {}

  @Builder
  TagRow() {
    if (this.item.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.item.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        if (this.item.isDone()) {
          AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().success })
        } else {
          Column()
            .width(12)
            .height(12)
            .borderRadius(6)
            .backgroundColor(TaskMedia.taskPriorityColor(this.item.priority))
        }
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)

      Column({ space: 6 }) {
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.item.isDone() ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.item.isDone() ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (this.item.summary.length > 0) {
          Text(this.item.summary)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .maxLines(this.compact ? 1 : 2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        Row({ space: 8 }) {
          if (this.item.dueDate.length > 0) {
            Text(`${this.item.laneLabel()} · ${this.item.slotLabel()} · ${this.item.dueDate}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
          if (this.item.category.length > 0) {
            Text(this.item.category)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
        }
        .width('100%')
        this.TagRow()
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => this.onTap())
  }
}
