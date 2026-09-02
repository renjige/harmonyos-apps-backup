import { Theme } from '../design-system/Theme'

@Component
export struct PlanStageRow {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop label: string = ''
  @Prop done: boolean = false
  onToggle: () => void = () => {}

  build() {
    Row({ space: Theme.space.s2 }) {
      Text(this.done ? '已完成' : '待完成')
        .fontSize(Theme.type.caption)
        .fontColor(this.done ? Theme.of(this.darkModeOn).success : Theme.of(this.darkModeOn).textSecondary)
      Text(this.label)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .layoutWeight(1)
        .decoration({ type: this.done ? TextDecorationType.LineThrough : TextDecorationType.None })
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => { this.onToggle() })
  }
}
