import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppIcon } from '../components/design-system/AppIcon'
import { ActivityEvent, WritingGoal } from '../models/HubModels'
import { InspirationItem } from '../models/LanguageCraftModels'
import { HubStore } from '../services/HubStore'
import { LanguageCraftBizService } from '../services/LanguageCraftBizService'
import { LanguageCraftMedia } from '../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../services/LanguageCraftNav'
import { ResearchNav } from '../services/ResearchNav'
import { ResearchStore } from '../services/ResearchStore'
import { DailyThink } from '../models/ResearchModels'

@Component
export struct HubPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('hubRefresh') @Watch('onHubRefresh') hubRefresh: number = 0
  @StorageLink('researchHubRefresh') @Watch('onHubRefresh') researchHubRefresh: number = 0
  @StorageLink('favRefresh') @Watch('onHubRefresh') favRefresh: number = 0
  @StorageLink('recordRefresh') @Watch('onHubRefresh') recordRefresh: number = 0
  @Prop appName: string = '研语'
  @State goal: WritingGoal = new WritingGoal()
  @State noteCount: number = 0
  @State manuscriptCount: number = 0
  @State favoriteCount: number = 0
  @State starredNoteCount: number = 0
  @State streakDays: number = 0
  @State activities: ActivityEvent[] = []
  @State dailyText: string = ''
  @State todayDone: boolean = false
  @State samples: InspirationItem[] = []
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

  private greeting(): string {
    const h = new Date().getHours()
    if (h < 12) {
      return '上午好'
    }
    if (h < 18) {
      return '下午好'
    }
    return '晚上好'
  }

  private async reload(): Promise<void> {
    await HubStore.checkAchievements()
    this.goal = await HubStore.currentGoal()
    const d = await HubStore.dashboard()
    this.noteCount = d.noteCount
    this.manuscriptCount = d.manuscriptCount
    this.favoriteCount = d.favoriteCount
    this.starredNoteCount = d.starredNoteCount
    this.streakDays = d.streakDays
    const acts = await HubStore.listActivities()
    const cut: ActivityEvent[] = []
    let i = 0
    for (const a of acts) {
      if (i < 6) {
        cut.push(a)
        i += 1
      }
    }
    this.activities = cut
    await this.loadDailyState()
    this.samples = await LanguageCraftBizService.loadInspirations('')
    const sm: InspirationItem[] = []
    let j = 0
    for (const item of this.samples) {
      if (j < 2) {
        sm.push(item)
        j += 1
      }
    }
    this.samples = sm
  }

  /** 仅从存储同步「已记下」状态；未保存时保留用户正在输入的草稿 */
  private async loadDailyState(): Promise<void> {
    const key = ResearchStore.todayKey()
    const days = await ResearchStore.listDaily()
    for (const row of days) {
      if (row.dateKey === key) {
        this.todayDone = true
        this.dailyText = row.viewpoint
        return
      }
    }
    this.todayDone = false
  }

  private goExpress(): void {
    AppStorage.setOrCreate('mainTabIndex', 1)
    AppStorage.setOrCreate('expressSegment', 0)
  }

  private async saveDaily(): Promise<void> {
    const text = this.dailyText.trim()
    if (text.length === 0) {
      this.showToast('先写下今天的一个观点')
      return
    }
    const key = ResearchStore.todayKey()
    const row = DailyThink.create(key)
    row.viewpoint = text
    await ResearchStore.saveDaily(row)
    await HubStore.recordDaily()
    this.todayDone = true
    this.goal = await HubStore.currentGoal()
    const acts = await HubStore.listActivities()
    const cut: ActivityEvent[] = []
    let i = 0
    for (const a of acts) {
      if (i < 6) {
        cut.push(a)
        i += 1
      }
    }
    this.activities = cut
    const d = await HubStore.dashboard()
    this.streakDays = d.streakDays
    this.showToast('今日思考已记下')
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: this.appName, subtitle: `${this.greeting()} · 表达与思考工作台` })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text('本周表达目标')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              Row() {
                Column()
                  .layoutWeight(Math.max(1, this.goal.overallPercent()))
                  .height(8)
                  .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
                  .borderRadius(Theme.radius.pill)
                Column()
                  .layoutWeight(Math.max(1, 100 - this.goal.overallPercent()))
                  .height(8)
                  .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
              }
              .width('100%')
              Text(`润色 ${this.goal.polishDone}/${this.goal.polishTarget} · 笔记 ${this.goal.noteDone}/${this.goal.noteTarget} · 思考 ${this.goal.dailyDone}/${this.goal.dailyTarget}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

            Column({ space: Theme.space.s2 }) {
              Text(this.todayDone ? `今日已记 · ${ResearchStore.todayKey()}` : '今日思考')
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

            Row({ space: Theme.space.s2 }) {
              Column({ space: 2 }) {
                Text(`${this.noteCount}`)
                  .fontSize(Theme.type.title3)
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

              Column({ space: 2 }) {
                Text(`${this.manuscriptCount}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('稿本')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

              Column({ space: 2 }) {
                Text(`${this.favoriteCount + this.starredNoteCount}`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('收藏')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })

              Column({ space: 2 }) {
                Text(`${this.streakDays}天`)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                Text('连续')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            }
            .width('100%')

            Column({ space: Theme.space.s3 }) {
              Text('创作能力')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .width('100%')
              Text('24 类场景 · 24 类成稿 · 15 条使用指南 · 12 条工作流')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.of(this.darkModeOn).textPrimary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '使用指南',
                    onTap: (): void => { LanguageCraftNav.openUseCaseGuide() }
                  })
                }
                .layoutWeight(1)
                Column() {
                  AppButton({
                    label: '场景库',
                    variant: 'secondary',
                    onTap: (): void => { LanguageCraftNav.openScenarioLibrary() }
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: '场景成稿',
                    variant: 'secondary',
                    onTap: (): void => { LanguageCraftNav.openDraft('') }
                  })
                }
                .layoutWeight(1)
                Column() {
                  AppButton({
                    label: '一键演示润色',
                    variant: 'secondary',
                    onTap: (): void => { LanguageCraftNav.runQuickDemo() }
                  })
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)

            Text('快捷操作')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              Column({ space: 4 }) {
                AppIcon({ name: 'edit', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).brandPrimary })
                Text('润色')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 10, bottom: 10 })
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.goExpress() })

              Column({ space: 4 }) {
                AppIcon({ name: 'bookmark', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).brandPrimary })
                Text('笔记')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 10, bottom: 10 })
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { ResearchNav.openNoteEditor('') })

              Column({ space: 4 }) {
                AppIcon({ name: 'sparkle', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).brandPrimary })
                Text('灵感')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 10, bottom: 10 })
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { AppStorage.setOrCreate('mainTabIndex', 2) })

              Column({ space: 4 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).brandPrimary })
                Text('成长')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
              }
              .layoutWeight(1)
              .padding({ top: 10, bottom: 10 })
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { AppStorage.setOrCreate('mainTabIndex', 3) })
            }
            .width('100%')

            Text('最近活动')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.activities.length === 0) {
              AppEmpty({
                title: '还没有个人记录',
                description: '可先点上方「使用指南」或「一键演示润色」体验完整创作能力。',
                actionLabel: '使用指南',
                onAction: (): void => { LanguageCraftNav.openUseCaseGuide() }
              })
            } else {
              ForEach(this.activities, (a: ActivityEvent) => {
                Row({ space: Theme.space.s2 }) {
                  Text(HubStore.activityLabel(a.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                    .width(40)
                  Column({ space: 2 }) {
                    Text(a.title)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.of(this.darkModeOn).textPrimary)
                      .width('100%')
                    Text(`${HubStore.timeShort(a.at)} · ${a.summary}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.of(this.darkModeOn).textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              }, (a: ActivityEvent) => a.id)
            }

            Text('推荐表达')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            ForEach(this.samples, (item: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(LanguageCraftMedia.cover(item.coverKey))
                  .width(56)
                  .height(56)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { LanguageCraftNav.openDetail(item.id) })
            }, (item: InspirationItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
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
      .onVisibleAreaChange([0.0, 1.0], (visible: boolean) => {
        if (visible) {
          void this.reload()
        }
      })

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
  }
}
