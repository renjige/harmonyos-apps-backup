import { Theme } from '../design-system/Theme'

@Component
export struct ChecklistRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop label: string = ''
  @Prop done: boolean = false
  onToggle: (id: string, nextDone: boolean) => void = (_id: string, _next: boolean): void => {}

  build() {
    Row({ space: Theme.space.s3 }) {
      Toggle({ type: ToggleType.Checkbox, isOn: this.done })
        .width(24)
        .height(24)
        .selectedColor(Theme.colors().success)
        .switchPointColor('#FFFFFF')
        .onChange((checked: boolean): void => {
          this.onToggle(this.itemId, checked)
        })

      Text(this.label)
        .fontSize(Theme.type.body)
        .fontWeight(this.done ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.done ? '#FFFFFF' : Theme.colors().textPrimary)
        .decoration({
          type: this.done ? TextDecorationType.LineThrough : TextDecorationType.None,
          color: this.done ? 'rgba(255,255,255,0.85)' : Theme.colors().textPrimary
        })
        .layoutWeight(1)
        .onClick((): void => {
          this.onToggle(this.itemId, !this.done)
        })

      Text(this.done ? '✓ 已完成' : '待完成')
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.done ? '#FFFFFF' : Theme.colors().textSecondary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(this.done ? 'rgba(255,255,255,0.22)' : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => {
          this.onToggle(this.itemId, !this.done)
        })
    }
    .width('100%')
    .height(52)
    .padding({ left: Theme.space.s3, right: Theme.space.s3 })
    .backgroundColor(this.done ? Theme.colors().success : Theme.colors().surfaceCard)
    .border({
      width: this.done ? 2 : 1,
      color: this.done ? Theme.colors().success : Theme.colors().strokeHairline
    })
    .borderRadius(Theme.radius.md)
  }
}
