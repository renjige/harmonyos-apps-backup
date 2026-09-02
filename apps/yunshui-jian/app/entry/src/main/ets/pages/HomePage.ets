import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { YunTimelineGroup, YunMoodDay, YunNoteItem } from '../models/YunModels'
import { YunTimelineGroupView } from '../components/yun/YunTimelineGroup'
import { YunMoodRow } from '../components/yun/YunMoodRow'
import { YunNoteCard } from '../components/yun/YunNoteCard'
import { YunDateHelper, YunLocalStore } from '../services/YunLocalStore'
import { YunDetailNav } from '../services/YunDetailNav'
import { YunOnThisDayCard } from '../components/yun/YunOnThisDayCard'

class QuickChip {
  label: string = ''
  action: () => void = () => {}

  static make(label: string, action: () => void): QuickChip {
    const c = new QuickChip()
    c.label = label
    c.action = action
    return c
  }
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @StorageLink('yunThemeTick') themeTick: number = 0
  @State groups: YunTimelineGroup[] = []
  @State recentNotes: YunNoteItem[] = []
  @State loading: boolean = true
  @State todayMood: string = ''
  @State onThisDay: YunNoteItem[] = []
  @State streakDays: number = 0
  @State monthNoteCount: number = 0
  @State todoDoneCount: number = 0
  private quickChips: QuickChip[] = []

  aboutToAppear(): void {
    this.quickChips = this.buildQuickChips()
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private buildQuickChips(): QuickChip[] {
    const chips: QuickChip[] = []
    chips.push(QuickChip.make('写札记', (): void => { YunDetailNav.openNoteEditor('') }))
    chips.push(QuickChip.make('记灵感', (): void => { YunDetailNav.openCraftEditor('', 'tip') }))
    chips.push(QuickChip.make('新计划', (): void => { YunDetailNav.openTodoEdit('new') }))
    chips.push(QuickChip.make('新清单', (): void => { YunDetailNav.openTodoEdit('new') }))
    chips.push(QuickChip.make('打卡', (): void => {
      AppStorage.setOrCreate('yunActiveTab', 2)
      AppStorage.setOrCreate('tabBarHidden', false)
    }))
    return chips
  }

  private async reload(): Promise<void> {
    this.loading = true
    const allGroups = await YunLocalStore.groupNotesByDate()
    const limited: YunTimelineGroup[] = []
    for (let i = 0; i < allGroups.length && i < 5; i++) {
      limited.push(allGroups[i])
    }
    this.groups = limited
    const notes = await YunLocalStore.loadNotes()
    const recent: YunNoteItem[] = []
    for (let i = 0; i < notes.length && i < 3; i++) {
      recent.push(notes[i])
    }
    this.recentNotes = recent
    const stats = await YunLocalStore.loadStats()
    this.streakDays = stats.streakDays
    this.todoDoneCount = stats.todoDone
    const review = await YunLocalStore.buildMonthlyReview()
    this.monthNoteCount = review.noteCount
    const mood = await YunLocalStore.todayMood()
    this.todayMood = mood !== undefined ? mood.mood : ''
    this.onThisDay = await YunLocalStore.findOnThisDay()
    this.loading = false
  }

  private async pickMood(mood: string): Promise<void> {
    const item = YunMoodDay.create(YunDateHelper.todayKey(), mood, '')
    await YunLocalStore.saveMood(item)
    this.todayMood = mood
  }

  @Builder
  StatCell(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_mist_life'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 6 }) {
              Text('云水间')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('记录生活，也收藏片刻。')
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
                .maxLines(2)
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(44,74,62,0.88)', 1]]
            })
          }
          .width('100%')
          .height(180)
          .clip(true)

          Row() {
            this.StatCell('连续记录', `${this.streakDays} 天`)
            Divider()
              .vertical(true)
              .height(36)
              .color(Theme.colors().strokeHairline)
            this.StatCell('本月札记', `${this.monthNoteCount} 篇`)
            Divider()
              .vertical(true)
              .height(36)
              .color(Theme.colors().strokeHairline)
            this.StatCell('完成', `${this.todoDoneCount} 项`)
          }
          .width('100%')
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.quickChips, (chip: QuickChip) => {
              Text(chip.label)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .margin({ right: Theme.space.s2, bottom: Theme.space.s2 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { chip.action() })
            }, (chip: QuickChip) => chip.label)
          }
          .width('100%')

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_yun_01'))
              .width('100%')
              .height(96)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            Column({ space: 4 }) {
              Text('今天，想留下什么？')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Text('写札记 · 记灵感 · 规划日常')
                .fontSize(Theme.type.caption)
                .fontColor('#F0F5F4')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(44,74,62,0.75)', 1]]
            })
          }
          .width('100%')
          .height(96)
          .clip(true)

          YunMoodRow({
            current: this.todayMood,
            onPick: (mood: string): void => { void this.pickMood(mood) }
          })

          if (this.onThisDay.length > 0) {
            YunOnThisDayCard({ notes: this.onThisDay })
          }

          if (this.recentNotes.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text('最近札记')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text('全部')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                  .onClick((): void => {
                    AppStorage.setOrCreate('yunActiveTab', 1)
                    AppStorage.setOrCreate('tabBarHidden', false)
                  })
              }
              .width('100%')

              ForEach(this.recentNotes, (note: YunNoteItem) => {
                YunNoteCard({
                  note: note,
                  onTap: (): void => { YunDetailNav.openNote(note.id) }
                })
              }, (note: YunNoteItem) => note.id)
            }
            .width('100%')
          }

          Row() {
            Text('时光轴')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Column() {
              AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { YunDetailNav.openSearch() })
          }
          .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
          } else if (this.groups.length === 0) {
            AppEmpty({
              title: '还没有云水间记',
              description: '点击右下角 + 记录第一条生活片段',
              actionLabel: '开始记录',
              onAction: (): void => { YunDetailNav.openNoteEditor('') }
            })
          } else {
            ForEach(this.groups, (g: YunTimelineGroup) => {
              YunTimelineGroupView({ group: g })
            }, (g: YunTimelineGroup) => g.dateKey)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      .shadow({ radius: 12, color: 'rgba(61,90,92,0.35)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
      .onClick((): void => { YunDetailNav.openNoteEditor('') })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
