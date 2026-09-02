import { Theme } from '../../components/design-system/Theme'
import { ResearchBar } from '../../components/research/ResearchBar'
import { StatLineItem } from '../../components/growth/StatLineItem'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'
import { HubStore } from '../../services/HubStore'
import { GrowthStatRow } from '../../models/GrowthStatRow'

@Component
export struct StatsPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @StorageLink('researchHubRefresh') @Watch('onRefresh') researchHubRefresh: number = 0
  @StorageLink('hubRefresh') @Watch('onRefresh') hubRefresh: number = 0
  @State statRows: GrowthStatRow[] = []
  @State statsEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const s = await ResearchStore.stats()
    const d = await HubStore.dashboard()
    this.statRows = [
      GrowthStatRow.of('note', '研究笔记', s.noteCount),
      GrowthStatRow.of('topic', '专题', s.topicCount),
      GrowthStatRow.of('spark', '灵感', s.sparkCount),
      GrowthStatRow.of('card', '观点卡片', s.cardCount),
      GrowthStatRow.of('reading', '阅读记录', s.readingCount),
      GrowthStatRow.of('plan', '研究计划', s.planCount),
      GrowthStatRow.of('week', '近 7 天新笔记', s.weekNotes),
      GrowthStatRow.of('streak', '连续思考天数', s.streak),
      GrowthStatRow.of('polish', '润色历史', d.polishCount),
      GrowthStatRow.of('ms', '稿本库', d.manuscriptCount)
    ]
    this.statsEpoch = Date.now()
  }

  build() {
    Column() {
      ResearchBar({ title: '知识统计' })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Image(LanguageCraftMedia.cover('cover_academic'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Text('学习积累一览')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
            .width('100%')
          Text('数字全部来自你本机写下的内容；保存笔记/灵感/阅读记录后返回本页会自动刷新。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          ForEach(this.statRows, (row: GrowthStatRow) => {
            StatLineItem({ label: row.label, valueText: row.valueText })
          }, (row: GrowthStatRow) => `${row.key}_${row.valueText}_${this.statsEpoch}`)
          Text('刷新统计')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
            .width('100%')
            .textAlign(TextAlign.Center)
            .padding({ top: 8, bottom: 8 })
            .onClick((): void => { void this.reload() })
          Text('去写笔记')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ top: 12, bottom: 12 })
            .width('100%')
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.lg)
            .onClick((): void => { ResearchNav.openNoteEditor('') })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
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
