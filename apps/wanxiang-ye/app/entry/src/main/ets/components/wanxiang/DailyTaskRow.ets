import { Theme } from '../design-system/Theme'

@Component
export struct DailyTaskRow {
  @Prop label: string = ''
  @Prop done: boolean = false
  onTap: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      Text(this.done ? '✓' : '○')
        .fontSize(Theme.type.body)
        .fontColor(this.done ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .width(20)
      Text(this.label)
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(this.done ? '已完成' : '去完成')
        .fontSize(Theme.type.caption)
        .fontColor(this.done ? Theme.colors().textSecondary : Theme.colors().brandPrimary)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => {
      if (!this.done) {
        this.onTap()
      }
    })
  }
}
