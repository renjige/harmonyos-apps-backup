import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import {
  XuAgendaItem, XuDateHelper, XuHabitItem, XuMoodItem, XuTipItem, XuWisdomItem
} from '../models/XuModels'
import { XuLocalStore } from '../services/XuLocalStore'
import { XuBizService } from '../services/XuBizService'
import { XuWisdom } from '../services/XuWisdom'
import { XuMedia } from '../services/XuMedia'
import { XuDetailNav } from '../services/XuDetailNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '明序阁'
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State dateText: string = ''
  // 双环数字直接绑定 AppStorage，保存日程后立刻更新（不依赖 Hidden Tab 的 @Prop 刷新）
  @StorageLink('xuHomeAgendaDone') agendaDone: number = 0
  @StorageLink('xuHomeAgendaTotal') agendaTotal: number = 0
  @StorageLink('xuHomeAgendaHint') agendaHint: string = '去日程页添加'
  @StorageLink('xuHomeHabitDone') habitDone: number = 0
  @StorageLink('xuHomeHabitTotal') habitTotal: number = 0
  @StorageLink('xuHomeHabitHint') habitHint: string = '点我添加习惯'
  @StorageLink('xuDataEpoch') @Watch('onDataEpochChange') dataEpoch: number = 0
  @State mood: string = ''
  @State energy: number = 3
  @State wisdom: XuWisdomItem[] = []
  @State tips: XuTipItem[] = []
  @State remindOn: boolean = true
  onOpenSchedule: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onOpenNotes: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.dateText = XuDateHelper.displayDate(new Date())
    void this.loadSide()
  }

  onRefreshChange(): void {
    void this.loadSide()
  }

  onDataEpochChange(): void {
    void this.loadSide()
  }

  private async loadSide(): Promise<void> {
    await XuLocalStore.ensureReady()
    XuLocalStore.publishHomeStats()
    this.dateText = XuDateHelper.displayDate(new Date())
    const today = XuDateHelper.todayKey()
    const todayAgenda = await XuLocalStore.agendaOnDate(today)
    const habits = await XuLocalStore.loadHabits()
    this.remindOn = await XuLocalStore.remindEnabled()
    const mood = await XuLocalStore.todayMood(today)
    if (mood !== undefined) {
      this.mood = mood.mood
      this.energy = mood.energy
    } else {
      this.mood = ''
    }
    this.wisdom = XuWisdom.build(todayAgenda, habits, this.remindOn)
    void this.loadTipsAsync()
  }

  private async loadTipsAsync(): Promise<void> {
    this.tips = await XuBizService.loadTips()
  }

  private rateOf(done: number, total: number): number {
    if (total <= 0) {
      return 0
    }
    return Math.round(done * 100 / total)
  }

  private scheduleCenter(): string {
    if (this.agendaTotal > 0) {
      return `${this.agendaDone}/${this.agendaTotal}`
    }
    return '0'
  }

  private habitCenter(): string {
    if (this.habitTotal > 0) {
      return `${this.habitDone}/${this.habitTotal}`
    }
    return '0'
  }

  private async setMood(label: string): Promise<void> {
    this.mood = label
    const item = XuMoodItem.create(XuDateHelper.todayKey(), label, this.energy)
    await XuLocalStore.saveMood(item)
    this.onDataChanged()
  }

  private wisdomTap(action: string): void {
    if (action === 'habit') {
      this.onOpenHabits()
    } else if (action === 'note') {
      this.onOpenNotes()
    } else {
      this.onOpenSchedule()
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(XuMedia.hero())
            .width('100%')
            .height(188)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column({ space: 6 }) {
            Row() {
              Text(this.appName)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .layoutWeight(1)
              Column() {
                AppIcon({ name: 'bell', iconSize: Theme.icon.md, color: '#FFFFFF' })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick(() => XuDetailNav.openMessages())
            }
            .width('100%')
            Text(this.dateText)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('明以洞察，序以行远')
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,42,58,0.08)', 0], ['rgba(26,42,58,0.86)', 1]]
          })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.xl)

        Row({ space: Theme.space.s3 }) {
          this.RateCard('日程', this.agendaDone, this.agendaTotal, this.scheduleCenter(), this.agendaHint)
          this.RateCard('习惯', this.habitDone, this.habitTotal, this.habitCenter(), this.habitHint)
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('今日心情 / 能量')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.MoodChip('明朗')
            this.MoodChip('安宁')
            this.MoodChip('疲惫')
            this.MoodChip('沉郁')
          }
          .width('100%')
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('智慧提醒')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.wisdom, (w: XuWisdomItem) => {
            Column({ space: 4 }) {
              Text(w.title)
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(w.body)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick(() => this.wisdomTap(w.action))
          }, (w: XuWisdomItem) => w.title)
        }
        .width('100%')

        Row({ space: Theme.space.s3 }) {
          this.Quick('日程', 'calendar', () => this.onOpenSchedule())
          this.Quick('习惯', 'heart', () => this.onOpenHabits())
          this.Quick('知识', 'book', () => this.onOpenNotes())
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Row() {
            Text('阁中笺注')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('节律自检')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .onClick(() => XuDetailNav.openDiagnose())
          }
          .width('100%')
          if (this.tips.length === 0) {
            AppEmpty({ title: '暂无笺注', description: '连接网络后可阅读平台整理的秩序贴士' })
          } else {
            ForEach(this.tips, (t: XuTipItem) => {
              Row({ space: Theme.space.s3 }) {
                Image(XuMedia.forCover(t.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 4 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(t.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => XuDetailNav.openTip(t.id))
            }, (t: XuTipItem) => t.id)
          }
        }
        .width('100%')
        Column().height(Theme.space.s6)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s4 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
  }

  @Builder
  RateCard(label: string, done: number, total: number, centerText: string, hintText: string) {
    Column({ space: 6 }) {
      Stack({ alignContent: Alignment.Center }) {
        Progress({
          value: this.rateOf(done, total),
          total: 100,
          type: ProgressType.Ring
        })
          .width(76)
          .height(76)
          .color(Theme.colors().chart2)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .style({ strokeWidth: 8 })
        Text(centerText)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width(76)
      .height(76)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(hintText)
        .fontSize(Theme.type.overline)
        .fontColor(Theme.colors().textSecondary)
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (label === '习惯') {
        this.onOpenHabits()
      } else {
        this.onOpenSchedule()
      }
    })
  }

  @Builder
  MoodChip(label: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.mood === label ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.mood === label ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick(() => { void this.setMood(label) })
  }

  @Builder
  Quick(label: string, icon: string, tap: () => void) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({
          name: icon === 'calendar' ? 'calendar' : (icon === 'heart' ? 'heart' : 'book'),
          iconSize: Theme.icon.lg,
          color: Theme.colors().brandOnPrimary
        })
      }
      .width(52)
      .height(52)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(Theme.radius.pill)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => tap())
  }
}
