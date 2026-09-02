import { Theme } from '../design-system/Theme'
import { ExperienceEntry } from '../../models/LifeModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ExperienceCard {
  @Prop entry: ExperienceEntry = new ExperienceEntry()
  onTap: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(DateHelper.displayDateFromTs(this.entry.createdAt))
          .fontSize(Theme.type.overline)
          .fontColor(Theme.colors().textTertiary)
        Blank()
        Text('删除')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .onClick((): void => { this.onDelete() })
      }
      .width('100%')
      this.QmrnRow('问', this.entry.question)
      if (this.entry.method.length > 0) {
        this.QmrnRow('法', this.entry.method)
      }
      if (this.entry.result.length > 0) {
        this.QmrnRow('果', this.entry.result)
      }
      if (this.entry.note.length > 0) {
        this.QmrnRow('记', this.entry.note)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
    .onClick((): void => { this.onTap() })
  }

  @Builder
  QmrnRow(label: string, body: string) {
    Row({ space: Theme.space.s2 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
        .width(20)
      Text(body)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
        .lineHeight(22)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}
