import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { ExploreStore } from '../../services/ExploreStore'
import { GrowthRow, JournalStore } from '../../services/JournalStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionStore } from '../../services/PavilionStore'
import { PavilionStats } from '../../models/PavilionModels'

class FocusChip {
  id: string = ''
  label: string = ''
}

@Component
export struct ProfilePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State stats: PavilionStats = new PavilionStats()
  @State quiz: string = ''
  @State quizHist: string[] = []
  @State tagInput: string = ''
  @State tags: string[] = []
  @State growth: GrowthRow[] = []
  private chips: FocusChip[] = ProfilePane.buildFocus()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private static buildFocus(): FocusChip[] {
    const ids: string[] = ['fun', 'life', 'history', 'nature', 'art', 'science']
    const labels: string[] = ['趣味知识', '生活技巧', '历史文化', '自然探索', '艺术欣赏', '科普百科']
    const list: FocusChip[] = []
    for (let i = 0; i < ids.length; i++) {
      const c = new FocusChip()
      c.id = ids[i]
      c.label = labels[i]
      list.push(c)
    }
    return list
  }

  private reload(): void {
    this.stats = PavilionStore.stats()
    this.quiz = ExploreStore.quizSummary()
    this.quizHist = JournalStore.quizLines()
    this.tags = ExploreStore.customTags()
    this.growth = JournalStore.growthMap()
  }

  private isFocus(id: string): boolean {
    const cats = ExploreStore.focusCats()
    for (const c of cats) {
      if (c === id) {
        return true
      }
    }
    return false
  }

  private async toggleFocus(id: string): Promise<void> {
    const cats = ExploreStore.focusCats()
    let next = ''
    let found = false
    for (const c of cats) {
      if (c === id) {
        found = true
      } else {
        next = next.length > 0 ? `${next},${c}` : c
      }
    }
    if (!found) {
      next = next.length > 0 ? `${next},${id}` : id
    }
    await ExploreStore.setFocus(next)
    this.reload()
  }

  private async addTag(): Promise<void> {
    await ExploreStore.addTag(this.tagInput)
    this.tagInput = ''
    this.reload()
  }

  build() {
    DetailShell({
      title: '兴趣档案',
      onClose: (): void => { PavilionDetailNav.close() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            this.StatCell(`${this.stats.favorites}`, '收藏')
            this.StatCell(`${this.stats.logs}`, '探索')
            this.StatCell(`${this.stats.tasks}`, '完成任务')
            this.StatCell(`${this.stats.finds}`, '每日发现')
          }
          .width('100%')
          Row() {
            this.StatCell(`${this.stats.notes}`, '笔记')
            this.StatCell(`${this.stats.wishes}`, '清单完成')
            this.StatCell(`${this.stats.cards}`, '卡片')
            this.StatCell(`${this.stats.days}`, '探索天数')
          }
          .width('100%')
          Text('兴趣成长地图')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .width('100%')
          ForEach(this.growth, (g: GrowthRow) => {
            Row() {
              Text(g.label)
                .fontSize(14)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .layoutWeight(1)
              Text(g.stars)
                .fontSize(14)
                .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
              Text(`${g.count}`)
                .fontSize(12)
                .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .margin({ left: 8 })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
            .borderRadius(10)
          }, (g: GrowthRow) => g.id)
          Text(this.quiz.length > 0 ? `最近问答：${this.quiz}` : '还没有趣味问答记录')
            .fontSize(13)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .width('100%')
          if (this.quizHist.length > 0) {
            Text('历史成绩（本机）')
              .fontSize(13)
              .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
              .width('100%')
            ForEach(this.quizHist, (line: string) => {
              Text(line)
                .fontSize(12)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .width('100%')
            }, (line: string) => line)
          }

          Text('关注领域')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.chips, (c: FocusChip) => {
              Text(c.label)
                .fontSize(13)
                .fontColor(this.isFocus(c.id) ? Theme.colors().brandOnPrimary : Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.isFocus(c.id) ? Theme.brandInk(this.themeEpoch, this.darkModeOn) : Theme.brandBox(this.themeEpoch, this.darkModeOn))
                .borderRadius(8)
                .onClick((): void => { void this.toggleFocus(c.id) })
            }, (c: FocusChip) => c.id)
          }
          .width('100%')

          Text('兴趣标签')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.tags, (t: string) => {
              Text(t)
                .fontSize(13)
                .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(Theme.brandBox(this.themeEpoch, this.darkModeOn))
                .borderRadius(8)
            }, (t: string) => t)
          }
          .width('100%')
          TextInput({ text: this.tagInput, placeholder: '自定义标签，如天文' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
            .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
            .padding({ left: 14, right: 14 })
            .borderRadius(12)
            .border({ width: 1, color: Theme.hairline(this.themeEpoch, this.darkModeOn) })
            .onChange((v: string): void => { this.tagInput = v })
          AppButton({ label: '添加标签', onTap: (): void => { void this.addTag() } })
          Text('标签用于搜索筛选。点选关注领域后，首页仍可浏览全部栏目。')
            .fontSize(12)
            .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
            .width('100%')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }

  @Builder
  StatCell(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
      Text(label)
        .fontSize(12)
        .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
    }
    .layoutWeight(1)
  }
}
