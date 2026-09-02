import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { YdTaskItem } from '../../models/YdModels'

@Component
export struct YdTaskRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTaskChanged') task: YdTaskItem = new YdTaskItem()
  @State checked: boolean = false
  onToggle: (taskId: string, done: boolean) => void = () => {}
  onOpen: (taskId: string) => void = () => {}

  aboutToAppear(): void {
    this.checked = this.task.done
  }

  onTaskChanged(): void {
    this.checked = this.task.done
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(3)
        .height(52)
        .backgroundColor(this.task.priorityColor())
        .borderRadius(2)
      Column({ space: Theme.space.s2 }) {
        Text(this.task.title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.checked ? Theme.colors().textSecondary : Theme.colors().textPrimary)
          .decoration({ type: this.checked ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: Theme.space.s2 }) {
          Text(this.task.domainLabel())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textPrimary)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
          Text(`${this.task.timeSlot} · ${this.task.durationMin} 分钟`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick((): void => { this.onOpen(this.task.id) })

      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.checked })
          .selectedColor(Theme.colors().brandPrimary)
          .onChange((next: boolean): void => {
            this.checked = next
            this.onToggle(this.task.id, next)
          })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
        .onClick((): void => { this.onOpen(this.task.id) })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
