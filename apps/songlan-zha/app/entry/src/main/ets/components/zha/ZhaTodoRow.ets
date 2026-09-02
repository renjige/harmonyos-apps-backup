import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ZhaTodoItem } from '../../models/ZhaModels'

@Component
export struct ZhaTodoRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todo: ZhaTodoItem = new ZhaTodoItem()
  onToggle: () => void = () => {}
  onDelete: () => void = () => {}
  onEdit: () => void = () => {}

  private priorityColor(): string {
    if (this.todo.priority === 'high') {
      return Theme.colors().danger
    }
    if (this.todo.priority === 'low') {
      return Theme.colors().info
    }
    return Theme.colors().brandAccent
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        if (this.todo.done) {
          AppIcon({
            name: 'check',
            iconSize: Theme.icon.md,
            color: Theme.colors().brandPrimary
          })
        } else {
          Column()
            .width(20)
            .height(20)
            .border({ width: 2, color: Theme.colors().strokeStrong })
            .borderRadius(Theme.radius.xs)
        }
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onToggle())

      Column({ space: 4 }) {
        Text(this.todo.content)
          .fontSize(Theme.type.body)
          .fontColor(this.todo.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.todo.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
        Row({ space: Theme.space.s2 }) {
          Text(this.todo.priorityLabel())
            .fontSize(Theme.type.caption)
            .fontColor(this.priorityColor())
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.xs)
          if (this.todo.dueDate.length > 0) {
            Text(this.todo.dueDate)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
          }
        }
      }
      .layoutWeight(1)
      .onClick(() => this.onEdit())

      Column() {
        AppIcon({
          name: 'close',
          iconSize: Theme.icon.sm,
          color: Theme.colors().textTertiary
        })
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onDelete())
    }
    .width('100%')
    .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s3, bottom: Theme.space.s3 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .opacity(this.todo.done ? 0.72 : 1)
  }
}
