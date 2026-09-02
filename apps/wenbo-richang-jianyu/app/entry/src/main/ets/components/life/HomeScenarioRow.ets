import { Theme } from '../design-system/Theme'
import { JournalScenario, JournalCatalog } from '../../services/JournalCatalog'

@Component
export struct HomeScenarioRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onPick: (scenario: JournalScenario) => void = (_s: JournalScenario) => {}
  private items: JournalScenario[] = JournalCatalog.scenarios()

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('生活场景')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('不只是空白日记：选场景会带入标题、心情与写作提示')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.items, (s: JournalScenario) => {
            Column({ space: 6 }) {
              Text(s.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .maxLines(1)
              Text(s.hint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(2)
                .width(120)
            }
            .width(132)
            .height(88)
            .padding(Theme.space.s3)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { this.onPick(s) })
          }, (s: JournalScenario) => s.id)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
