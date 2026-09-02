import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../idiom/IdiomCards'
import { ThemeItem } from '../../models/IdiomModels'
import { IdiomBizService } from '../../services/IdiomBizService'
import { IdiomNav } from '../../services/IdiomNav'

@Component
export struct ThemeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: ThemeItem = new ThemeItem()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const list = await IdiomBizService.loadThemes()
    const found = IdiomBizService.findTheme(list, IdiomNav.detailId())
    if (found !== undefined) {
      this.item = found
    }
  }

  private start(): void {
    void this.launch()
  }

  private async launch(): Promise<void> {
    const key = this.item.theme.length > 0 ? this.item.theme : this.item.category
    const qs = await IdiomBizService.loadThemeQuestions(key, 8)
    const ids = IdiomBizService.idsOf(qs)
    if (ids.length === 0) {
      return
    }
    IdiomNav.openQuiz(ids, 'theme')
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => IdiomNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey,
            title: this.item.title,
            subtitle: `${this.item.difficulty} · 专项练习`,
            heroHeight: 200
          })
          Column({ space: 8 }) {
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.body)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          AppButton({ label: '开始专项练习', onTap: () => this.start() })
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
