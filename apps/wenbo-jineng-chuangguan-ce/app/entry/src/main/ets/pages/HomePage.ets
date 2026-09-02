import { Theme } from '../components/design-system/Theme'
import { AppError } from '../components/design-system/AppError'
import { CoverHero, LevelThumbCard, StatChip } from '../components/skill/SkillCards'
import { SkillLevel, KpiItem } from '../models/SkillModels'
import { SkillBizService } from '../services/SkillBizService'
import { SkillNav } from '../services/SkillNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State recommended: SkillLevel[] = []
  @State kpis: KpiItem[] = []
  @State kpiRow: KpiItem[] = []
  @State loading: boolean = true
  @State failed: boolean = false
  @State errorHint: string = ''
  @State greeting: string = ''
  @State dateLabel: string = ''
  @StorageLink('skillTick') tick: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('growthValue') growthValue: number = 0
  @StorageLink('completedCount') completedCount: number = 0
  @StorageLink('windowIsWide') isWide: boolean = false

  aboutToAppear(): void {
    this.greeting = ProgressStore.greeting()
    this.dateLabel = ProgressStore.dateLabel()
    void this.reload()
  }

  async reload(): Promise<void> {
    this.loading = true
    this.failed = false
    try {
      this.recommended = await SkillBizService.loadRecommended()
      this.kpis = await SkillBizService.loadKpis()
      this.kpiRow = this.firstKpis(this.kpis, 3)
      this.failed = this.recommended.length === 0
      this.errorHint = SkillBizService.lastHint()
    } catch {
      this.failed = true
      this.errorHint = SkillBizService.lastHint()
    }
    this.loading = false
  }

  private firstKpis(list: KpiItem[], count: number): KpiItem[] {
    const out: KpiItem[] = []
    for (const k of list) {
      out.push(k)
      if (out.length >= count) {
        break
      }
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        CoverHero({
          coverKey: 'hero_bg',
          title: '技能闯关册',
          subtitle: `${this.dateLabel} · 连续 ${this.streakDays} 日`,
          heroHeight: this.isWide ? 260 : 220
        })

        Text(this.greeting)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Row({ space: 8 }) {
          StatChip({ label: '成长值', value: `${this.growthValue}` })
          StatChip({ label: '已通关', value: `${this.completedCount}` })
          StatChip({ label: '连续打卡', value: `${this.streakDays}天` })
        }
        .width('100%')

        if (this.kpiRow.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.kpiRow, (k: KpiItem) => {
              StatChip({ label: k.label, value: k.value })
            }, (k: KpiItem) => k.key.length > 0 ? k.key : k.id)
          }
          .width('100%')
        }

        if (this.failed && !this.loading) {
          AppError({
            title: '推荐关卡暂时无法加载',
            message: this.errorHint,
            retryLabel: '重试',
            onRetry: () => { void this.reload() }
          })
        } else {
          Column({ space: 10 }) {
            Row() {
              Text('今日推荐 · 5 关')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Text('查看全部')
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .onClick(() => AppStorage.setOrCreate('mainTab', 1))
            }
            .width('100%')

            Scroll() {
              Row({ space: 12 }) {
                ForEach(this.recommended, (lv: SkillLevel) => {
                  LevelThumbCard({
                    title: lv.title,
                    coverKey: lv.coverKey.length > 0 ? lv.coverKey : 'hero_bg',
                    meta: SkillBizService.difficultyStars(lv),
                    onTap: () => SkillNav.openLevel(lv.id)
                  })
                }, (lv: SkillLevel) => lv.id)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')
          }
          .width('100%')
        }

        Column({ space: 10 }) {
          Text('快捷入口')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: 10 }) {
            this.Shortcut('成长勋章', () => AppStorage.setOrCreate('mainTab', 2))
            this.Shortcut('排行榜', () => AppStorage.setOrCreate('mainTab', 3))
          }
          .width('100%')
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Shortcut(label: string, action: () => void) {
    Text(label)
      .fontSize(14)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick(() => action())
  }
}
