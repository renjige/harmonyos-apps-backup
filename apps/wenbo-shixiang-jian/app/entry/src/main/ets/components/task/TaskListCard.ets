import { Theme } from '../design-system/Theme'
import { SketchStyle } from '../design-system/SketchStyle'
import { SketchNote } from '../design-system/SketchNote'
import { AppIcon } from '../design-system/AppIcon'
import { TaskItem } from '../../models/TaskModels'
import { TaskMedia } from '../../services/TaskMedia'

@Component
export struct TaskListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TaskItem = new TaskItem()
  @Prop compact: boolean = false
  @Prop noteIndex: number = 4
  onTap: () => void = () => {}

  private cardInk(): string {
    return this.item.isDone() ? SketchStyle.inkMuted() : SketchStyle.ink()
  }

  @Builder
  TagRow() {
    if (this.item.tags.length > 0) {
      Row({ space: 6 }) {
        ForEach(this.item.tags.slice(0, 3), (tag: string) => {
          Text(tag)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.sketchRadius())
            .border({ width: 1, color: SketchStyle.borderInk() })
        }, (tag: string) => tag)
      }
      .width('100%')
    }
  }

  build() {
    SketchNote({ noteIndex: this.noteIndex, interactive: true }) {
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
              .border({ width: 1, color: SketchStyle.borderInk() })
          }
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center)

        Column({ space: 6 }) {
          Text(this.item.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(SketchStyle.titleWeight())
            .fontStyle(this.item.isDone() ? FontStyle.Normal : SketchStyle.titleStyle())
            .fontColor(this.cardInk())
            .decoration({ type: this.item.isDone() ? TextDecorationType.LineThrough : TextDecorationType.None })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          if (this.item.summary.length > 0) {
            Text(this.item.summary)
              .fontSize(Theme.type.footnote)
              .fontColor(SketchStyle.inkMuted())
              .maxLines(this.compact ? 1 : 2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          Row({ space: 8 }) {
            if (this.item.dueDate.length > 0) {
              Text(`${this.item.laneLabel()} · ${this.item.slotLabel()} · ${this.item.dueDate}`)
                .fontSize(Theme.type.caption)
                .fontColor(SketchStyle.inkMuted())
            }
            if (this.item.category.length > 0) {
              Text(this.item.category)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
            }
          }
          .width('100%')
          this.TagRow()
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: SketchStyle.inkMuted() })
      }
      .width('100%')
      .onClick((): void => { this.onTap() })
    }
  }
}
