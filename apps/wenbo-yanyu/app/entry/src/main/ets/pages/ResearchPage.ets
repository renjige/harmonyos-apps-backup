import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ResearchDeskGrid } from '../components/research/ResearchDeskGrid'
import { DailyThink, ResearchNote, SparkItem } from '../models/ResearchModels'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'
import { ResearchNav } from '../services/ResearchNav'
import { ResearchStore } from '../services/ResearchStore'
import { HubStore } from '../services/HubStore'

@Component
export struct ResearchPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('researchHubRefresh') @Watch('onHubRefresh') hubRefresh: number = 0
  @StorageLink('researchRefresh') @Watch('onHubRefresh') researchRefresh: number = 0
  @State noteCount: number = 0
  @State topicCount: number = 0
  @State streakDays: number = 0
  @State recent: ResearchNote[] = []
  @State sparkText: string = ''
  @State dailyText: string = ''
  @State todayDone: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onHubRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    const s = await ResearchStore.stats()
    this.noteCount = s.noteCount
    this.topicCount = s.topicCount
    this.streakDays = s.streak
    const notes = await ResearchStore.listNotes()
    const cut: ResearchNote[] = []
    let i = 0
    for (const n of notes) {
      if (i < 5) {
        cut.push(n)
        i += 1
      }
    }
    this.recent = cut
    await this.loadDailyState()
  }

  private async loadDailyState(): Promise<void> {
    const key = ResearchStore.todayKey()
    const days = await ResearchStore.listDaily()
    for (const d of days) {
      if (d.dateKey === key) {
        this.todayDone = true
        this.dailyText = d.viewpoint
        return
      }
    }
    this.todayDone = false
  }

  private async saveDaily(): Promise<void> {
    const text = this.dailyText.trim()
    if (text.length === 0) {
      this.showToast('先写下今天的一个观点')
      return
    }
    const row = DailyThink.create(ResearchStore.todayKey())
    row.viewpoint = text
    await ResearchStore.saveDaily(row)
    await HubStore.recordDaily()
    this.todayDone = true
    this.showToast('今日思考已记下')
    await this.reload()
  }

  private async saveSpark(): Promise<void> {
    const text = this.sparkText.trim()
    if (text.length === 0) {
      this.showToast('先写一句灵感')
      return
    }
    const item = SparkItem.create()
    item.text = text
    await ResearchStore.saveSpark(item)
    await HubStore.recordSpark(text, item.id)
    this.sparkText = ''
    this.showToast('已收入灵感库')
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '研究', subtitle: '学习记录 · 知识沉淀 · 观点管理' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack() {
              Image(LanguageCraftMedia.cover('cover_library'))
                .width('100%')
                .height(148)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column() {
                Text('把阅读、学习和突然想到的内容，整理成可回顾的研究资料。')
                  .fontSize(Theme.type.footnote)
                  .fontColor('#FFFFFF')
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(10,37,64,0)', 0], ['rgba(10,37,64,0.78)', 1]]
              })
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.End)
              .height(148)
              .borderRadius(Theme.radius.lg)
            }
            .width('100%')
            .height(148)

            Row({ space: Theme.space.s2 }) {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textSecondary })
              Text('搜索笔记、观点与标签')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.md)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            .onClick((): void => { ResearchNav.open('search') })

            Row({ space: Theme.space.s3 }) {
              Column({ space: 2 }) {
                Text(`${this.noteCount}`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('笔记')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => { ResearchNav.open('stats') })
              Column({ space: 2 }) {
                Text(`${this.topicCount}`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('专题')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => { ResearchNav.open('stats') })
              Column({ space: 2 }) {
                Text(`${this.streakDays}`)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('连续思考')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              .onClick((): void => { ResearchNav.open('stats') })
            }
            .width('100%')

            Text('保存笔记/灵感后，点上方数字或「成长」Tab 查看完整知识统计。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textTertiary)
              .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text(this.todayDone ? `今日已记 · ${ResearchStore.todayKey()}` : '每日思考')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              TextArea({ text: this.dailyText, placeholder: '今天只记一个观点或疑问' })
                .height(72)
                .width('100%')
                .enabled(!this.todayDone)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onChange((v: string) => { this.dailyText = v })
              if (!this.todayDone) {
                AppButton({ label: '记下今日思考', onTap: (): void => { void this.saveDaily() } })
              }
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

            Column({ space: Theme.space.s2 }) {
              Text('灵感快记')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              TextArea({ text: this.sparkText, placeholder: '突然想到的句子、线索或问题' })
                .height(64)
                .onChange((v: string) => { this.sparkText = v })
              AppButton({
                label: '收入灵感库',
                variant: 'secondary',
                onTap: (): void => { void this.saveSpark() }
              })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

            AppButton({
              label: '写一条研究笔记',
              onTap: (): void => { ResearchNav.openNoteEditor('') }
            })

            Text('研究工具')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            ResearchDeskGrid()

            Text('最近笔记')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.recent.length === 0) {
              AppEmpty({
                title: '还没有研究笔记',
                description: '新用户资料为空。从学习心得、阅读感悟或项目记录开始写第一条。',
                actionLabel: '写笔记',
                onAction: (): void => { ResearchNav.openNoteEditor('') }
              })
            } else {
              ForEach(this.recent, (n: ResearchNote) => {
                Column({ space: 4 }) {
                  Text(n.title.length > 0 ? n.title : '未命名笔记')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(n.viewpoint.length > 0 ? n.viewpoint : n.body)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
                .onClick((): void => { ResearchNav.openNoteDetail(n.id) })
              }, (n: ResearchNote) => n.id)
            }
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
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0.0, 1.0], (visible: boolean) => {
      if (visible) {
        void this.reload()
      }
    })
  }
}
