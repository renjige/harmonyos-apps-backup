import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MomentTodo } from '../../models/MomentModels'

@Component
export struct TodoRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop todoId: string = ''
  @Prop content: string = ''
  @Prop done: boolean = false
  @Prop priorityColor: string = '#FF6B35'
  @Prop meta: string = ''
  @Prop highlight: boolean = false
  onToggle: () => void = () => {}
  onOpen: () => void = () => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: 'check',
          iconSize: Theme.icon.md,
          color: this.done ? Theme.colors().brandOnPrimary : this.priorityColor
        })
      }
      .width(28)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.done ? this.priorityColor : 'transparent')
      .borderRadius(Theme.radius.pill)
      .border({ width: this.done ? 0 : 2, color: this.priorityColor })
      .onClick((): void => this.onToggle())

      Column({ space: 4 }) {
        Text(this.content)
          .fontSize(Theme.type.body)
          .fontColor(this.done ? Theme.colors().textTertiary : Theme.colors().textPrimary)
          .decoration({ type: this.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if (this.meta.length > 0) {
          Text(this.meta)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
      }
      .layoutWeight(1)
      .onClick((): void => this.onOpen())
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .border({
      width: this.highlight ? 2 : 0,
      color: Theme.colors().brandPrimary
    })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 1 })
    .alignItems(VerticalAlign.Center)
  }
}

export class TodoRowBinder {
  static meta(todo: MomentTodo): string {
    return `${todo.bucketLabel()} · ${todo.priorityLabel()}优先级`
  }
}
