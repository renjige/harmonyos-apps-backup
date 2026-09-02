import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ScenarioCategory, WritingScenario } from '../../models/LanguageCraftModels'
import { LanguageScenarioService } from '../../services/LanguageScenarioService'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'

@Component
export struct ExpressScenarioStrip {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State categoryKey: string = 'all'
  @State rows: WritingScenario[] = LanguageScenarioService.all()

  private pickCategory(key: string): void {
    this.categoryKey = key
    this.rows = LanguageScenarioService.byCategory(key)
  }

  private openScenario(row: WritingScenario): void {
    if (row.sampleText.length > 0) {
      LanguageCraftNav.applyScenarioDemoRow(row)
      return
    }
    LanguageCraftNav.openDraft(row.draftKey)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('创作场景 · 24 类')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
          .layoutWeight(1)
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).brandPrimary)
          .onClick((): void => { LanguageCraftNav.openScenarioLibrary() })
      }
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(LanguageScenarioService.categories(), (cat: ScenarioCategory) => {
            Text(cat.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.categoryKey === cat.key ?
                Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.categoryKey === cat.key ?
                Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.pickCategory(cat.key) })
          }, (cat: ScenarioCategory) => cat.key)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.rows, (row: WritingScenario) => {
            Column({ space: 4 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(row.hint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(132)
            .height(72)
            .padding(10)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            .onClick((): void => { this.openScenario(row) })
          }, (row: WritingScenario) => row.key)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX })
  }
}
