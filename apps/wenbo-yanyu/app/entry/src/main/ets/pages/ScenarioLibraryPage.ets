import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { ScenarioCategory, WritingScenario } from '../models/LanguageCraftModels'
import { LanguageScenarioService } from '../services/LanguageScenarioService'
import { LanguageCraftNav } from '../services/LanguageCraftNav'

@Component
export struct ScenarioLibraryPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State categoryKey: string = 'all'
  @State rows: WritingScenario[] = LanguageScenarioService.all()

  private pickCategory(key: string): void {
    this.categoryKey = key
    this.rows = LanguageScenarioService.byCategory(key)
  }

  private openScenario(row: WritingScenario): void {
    LanguageCraftNav.closeScenarioLibrary()
    if (row.sampleText.length > 0) {
      LanguageCraftNav.applyScenarioDemoRow(row)
      return
    }
    LanguageCraftNav.openDraft(row.draftKey)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { LanguageCraftNav.closeScenarioLibrary() })
        Column({ space: 2 }) {
          Text('场景库')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
          Text('24 类职场 / 学术 / 研究 / 生活写作场景')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

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
          }, (cat: ScenarioCategory) => `lib_${cat.key}`)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          ForEach(this.rows, (row: WritingScenario) => {
            Column({ space: 6 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .width('100%')
              Text(row.hint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              Text('点按：载入样例并润色 · 长按可先进填空成稿')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.of(this.darkModeOn).textTertiary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            .onClick((): void => { this.openScenario(row) })
            .gesture(
              LongPressGesture({ repeat: false })
                .onAction((): void => {
                  LanguageCraftNav.closeScenarioLibrary()
                  LanguageCraftNav.openDraft(row.draftKey)
                })
            )
          }, (row: WritingScenario) => `librow_${row.key}`)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
