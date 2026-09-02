import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { StatLineItem } from '../components/growth/StatLineItem'
import { AchievementDef, AchievementUnlock, HubDashboard, WeekReview } from '../models/HubModels'
import { GrowthStatRow } from '../models/GrowthStatRow'
import { HubStore } from '../services/HubStore'
import { AppStores } from '../services/AppStores'
import { ResearchStore } from '../services/ResearchStore'
import { ResearchNav } from '../services/ResearchNav'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'

@Component
export struct GrowthPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('hubRefresh') @Watch('onHubRefresh') hubRefresh: number = 0
  @StorageLink('researchHubRefresh') @Watch('onHubRefresh') researchHubRefresh: number = 0
  @StorageLink('researchRefresh') @Watch('onHubRefresh') researchRefresh: number = 0
  @StorageLink('recordRefresh') @Watch('onHubRefresh') recordRefresh: number = 0
  @StorageLink('favRefresh') @Watch('onHubRefresh') favRefresh: number = 0
  @Prop @Watch('onTabActive') tabActive: boolean = false
  @State review: WeekReview = new WeekReview()
  @State defs: AchievementDef[] = []
  @State unlocked: AchievementUnlock[] = []
  @State statRows: GrowthStatRow[] = []
  @State achievementCount: number = 0
  @State achievementTotal: number = 0
  @State statsEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onHubRefresh(): void {
    void this.reload()
  }

  onTabActive(): void {
    if (this.tabActive) {
      void this.reload()
    }
  }

  private buildStatRows(d: HubDashboard): GrowthStatRow[] {
    return [
      GrowthStatRow.of('note', '研究笔记', d.noteCount),
      GrowthStatRow.of('topic', '专题', d.topicCount),
      GrowthStatRow.of('spark', '灵感', d.sparkCount),
      GrowthStatRow.of('card', '观点卡片', d.cardCount),
      GrowthStatRow.of('reading', '阅读记录', d.readingCount),
      GrowthStatRow.of('plan', '研究计划', d.planCount),
      GrowthStatRow.of('week', '近 7 天新笔记', d.weekNotes),
      GrowthStatRow.of('streak', '连续思考天数', d.streakDays),
      GrowthStatRow.of('ms', '稿本库', d.manuscriptCount),
      GrowthStatRow.of('polish', '润色历史', d.polishCount),
      GrowthStatRow.of('summary', '摘要历史', d.summaryCount),
      GrowthStatRow.of('fav', '范例收藏', d.favoriteCount),
      GrowthStatRow.of('star', '笔记星标', d.starredNoteCount),
      GrowthStatRow.of('plan_done', '计划完成', `${d.planDone}/${d.planTotal}`)
    ]
  }

  private async reload(): Promise<void> {
    const readyFlag = AppStorage.get<boolean>('storesReady') ?? false
    if (!readyFlag) {
      await AppStores.warmUp()
    }
    await HubStore.ensureReady()
    await ResearchStore.ensureReady()
    await HubStore.checkAchievements()
    const d = await HubStore.dashboard()
    this.statRows = this.buildStatRows(d)
    this.statsEpoch = Date.now()
    this.achievementCount = d.achievementCount
    this.achievementTotal = d.achievementTotal
    this.review = await HubStore.weekReview()
    this.defs = HubStore.achievementDefs()
    this.unlocked = await HubStore.listAchievements()
  }

  private isUnlocked(key: string): boolean {
    for (const u of this.unlocked) {
      if (u.key === key) {
        return true
      }
    }
    return false
  }

  build() {
    Column() {
      AppHeader({ title: '成长', subtitle: '统计 · 成就 · 本周回顾' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(LanguageCraftMedia.cover('cover_academic'))
            .width('100%')
            .height(120)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)

          Column({ space: Theme.space.s2 }) {
            Text('本周回顾')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
            Text(this.review.highlight)
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Text(`润色 ${this.review.polishCount} · 笔记 ${this.review.noteCount} · 思考 ${this.review.dailyCount} 天 · 连续 ${this.review.streak} 天`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textTertiary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

          Text('知识统计')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          Text('数字来自本机笔记、专题、灵感等真实记录；保存后切回本页或下拉刷新即更新。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).textTertiary)
            .width('100%')

          ForEach(this.statRows, (row: GrowthStatRow) => {
            StatLineItem({ label: row.label, valueText: row.valueText })
          }, (row: GrowthStatRow) => `${row.key}_${row.valueText}_${this.statsEpoch}`)

          Text(`成就 ${this.achievementCount}/${this.achievementTotal}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          if (this.defs.length === 0) {
            AppEmpty({ title: '暂无成就', description: '继续使用即可解锁徽章。' })
          } else {
            ForEach(this.defs, (def: AchievementDef) => {
              Column({ space: 4 }) {
                Text(def.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.isUnlocked(def.key) ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .width('100%')
                Text(def.hint)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.isUnlocked(def.key) ?
                Theme.of(this.darkModeOn).brandPrimaryContainer : Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            }, (def: AchievementDef) => def.key)
          }

          AppButton({
            label: '刷新统计',
            variant: 'secondary',
            onTap: (): void => { void this.reload() }
          })
          AppButton({
            label: '查看时间线',
            variant: 'secondary',
            onTap: (): void => { ResearchNav.open('timeline') }
          })
          AppButton({
            label: '写研究笔记',
            onTap: (): void => { ResearchNav.openNoteEditor('') }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
    .onVisibleAreaChange([0.0, 1.0], (visible: boolean) => {
      if (visible) {
        void this.reload()
      }
    })
  }
}
