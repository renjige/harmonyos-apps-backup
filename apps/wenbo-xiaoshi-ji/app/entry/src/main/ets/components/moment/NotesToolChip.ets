import { Theme } from '../design-system/Theme'

@Component
export struct NotesToolChip {
  @Prop title: string = ''
  @Prop hint: string = ''
  onTap: () => void = () => {}

  build() {
    Column({ space: 4 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.hint)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(16)
    .onClick((): void => this.onTap())
  }
}
