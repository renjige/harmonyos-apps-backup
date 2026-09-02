import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { IdiomListCard } from '../components/idiom/IdiomCards'
import { ThemeItem } from '../models/IdiomModels'
import { IdiomBizService } from '../services/IdiomBizService'
import { IdiomNav } from '../services/IdiomNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct BankPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State themes: ThemeItem[] = []
  @State weakLabel: string = ''
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.themes = await IdiomBizService.loadThemes()
    const key = ProgressStore.weakTheme()
    this.weakLabel = this.labelOf(key)
  }

  private labelOf(key: string): string {
    for (const t of this.themes) {
      if (t.theme === key || t.category === key) {
        return t.title
      }
    }
    return '历史典故'
  }

  private startWeak(): void {
    void this.launchWeak()
  }

  private async launchWeak(): Promise<void> {
    const list = await IdiomBizService.loadThemeQuestions(ProgressStore.weakTheme(), 8)
    const ids = IdiomBizService.idsOf(list)
    if (ids.length === 0) {
      return
    }
    IdiomNav.openQuiz(ids, 'theme')
  }

  build() {
    Column() {
      Text('智慧题库')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      Text('按主题专项练习。智慧推荐只根据本机错题主题排序，不调用大模型。')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      Column({ space: 8 }) {
        Text(`智慧推荐 · ${this.weakLabel}`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('优先练习你最近更容易失分的主题。')
          .fontSize(13)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Row({ space: 8 }) {
          AppButton({ label: '开始专项', onTap: () => this.startWeak() })
          AppButton({
            label: '薄弱诊断',
            variant: 'secondary',
            onTap: () => IdiomNav.openDiagnose()
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Theme.colors().surfaceGlass)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      if (this.themes.length === 0) {
        AppEmpty({ title: '主题尚未载入', description: '请稍后重试', actionLabel: '刷新', onAction: () => { void this.reload() } })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.themes, (t: ThemeItem) => {
              IdiomListCard({
                title: t.title,
                summary: t.summary,
                meta: t.difficulty,
                coverKey: t.coverKey,
                onTap: () => IdiomNav.openTheme(t.id)
              })
            }, (t: ThemeItem) => t.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
