import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct XuAgendaRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop timeText: string = ''
  @Prop kindLabel: string = ''
  @Prop priorityLabel: string = ''
  @Prop priority: string = 'mid'
  @Prop done: boolean = false
  onOpen: () => void = () => {}
  onToggle: () => void = () => {}

  private prioColor(): string {
    if (this.priority === 'high') {
      return Theme.colors().danger
    }
    if (this.priority === 'low') {
      return Theme.colors().textTertiary
    }
    return Theme.colors().brandAccent
  }

  build() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: this.done ? 'check' : 'empty',
          iconSize: Theme.icon.md,
          color: this.done ? Theme.colors().success : Theme.colors().textTertiary
        })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.onToggle())

      Column({ space: 4 }) {
        Row({ space: 8 }) {
          Text(this.timeText.length > 0 ? this.timeText : '全天')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(this.kindLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          Text(this.priorityLabel)
            .fontSize(Theme.type.caption)
            .fontColor(this.prioColor())
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.xs)
        }
        .width('100%')
        Text(this.title)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .decoration({ type: this.done ? TextDecorationType.LineThrough : TextDecorationType.None })
          .maxLines(2)
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => this.onOpen())

      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({ radius: 8, color: 'rgba(26,42,58,0.05)', offsetY: 1 })
  }
}
