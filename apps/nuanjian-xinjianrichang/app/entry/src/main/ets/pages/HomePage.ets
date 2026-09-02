import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { MoodSelector } from '../components/note/MoodSelector'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem } from '../models/NoteModels'
import { HeartNoteStore } from '../services/HeartNoteStore'
import { HeartNoteBizService } from '../services/HeartNoteBizService'
import { NoteDateUtil } from '../services/NoteDateUtil'
import { NoteNav } from '../services/NoteNav'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '暖笺生活'
  @Prop appName: string = '心笺日常'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenAll: () => void = () => {}
  @State promptTitle: string = '今天，也值得被记录。'
  @State quoteLine: string = '生活不必轰轰烈烈，也值得认真收藏。'
  @State mood: string = ''
  @State recent: NoteItem[] = []
  @State loaded: boolean = false
  @State remindToday: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const today = NoteDateUtil.todayIso()
    const storedDate = AppStorage.get<string>('todayMoodDate') ?? ''
    const storedMood = AppStorage.get<string>('todayMood') ?? ''
    this.mood = storedDate === today ? storedMood : ''
    this.recent = HeartNoteStore.recent(3)
    const remind = AppStorage.get<boolean>('dailyRemindOn') === true
    this.remindToday = remind && !HeartNoteStore.hasOnDate(today)
    const daily = await HeartNoteBizService.loadDaily()
    if (daily.prompt !== null && daily.prompt.title.length > 0) {
      this.promptTitle = daily.prompt.title
    }
    if (daily.quote !== null) {
      const q = daily.quote.body.length > 0 ? daily.quote.body : daily.quote.summary
      if (q.length > 0) {
        this.quoteLine = q
      }
    }
    this.loaded = true
  }

  private nowLabel(): string {
    const d = new Date()
    return `${NoteDateUtil.homeTitle(d)}  ${NoteDateUtil.weekdayLabel(d)}`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Column({ space: 6 }) {
            Text(this.nowLabel())
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.promptTitle)
              .fontSize(Theme.type.title1)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          Column() {
            AppIcon({ name: 'calendar', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
        }
        .width('100%')

        Stack() {
          Image($r('app.media.hero_window_paper'))
            .width('100%')
            .height(168)
            .objectFit(ImageFit.Cover)
          Column() {
            Text('把平凡日子，写成自己的故事。')
              .fontSize(Theme.type.body)
              .fontColor('#FFFFFF')
              .width('100%')
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 16 })
          .linearGradient({
            angle: 180,
            colors: [['rgba(39,35,33,0)', 0], ['rgba(39,35,33,0.62)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)

        Column({ space: 14 }) {
          Text('今天的心情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          MoodSelector({
            selected: this.mood,
            onSelect: (id: string): void => {
              this.mood = id
              void HeartNoteStore.setTodayMood(id, NoteDateUtil.todayIso())
            }
          })
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        AppButton({
          label: '＋ 写下今天',
          onTap: (): void => { NoteNav.openWrite('') }
        })

        if (this.remindToday) {
          Column({ space: 6 }) {
            Text('今日心笺')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text('今天还没有心笺。写一句话，给今天留个位置。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { NoteNav.openWrite('') })
        }

        Row() {
          Text('最近心笺')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('查看全部')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => { this.onOpenAll() })
        }
        .width('100%')

        if (this.recent.length === 0) {
          AppEmpty({
            title: '今天还没有心笺',
            description: '写一句话，给今天留个位置。',
            actionLabel: '写下今天',
            onAction: (): void => { NoteNav.openWrite('') }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.recent, (n: NoteItem) => {
              NoteListCard({
                item: n,
                onTap: (): void => { NoteNav.openDetail(n.id) }
              })
            }, (n: NoteItem) => n.id)
          }
          .width('100%')
        }

        Image($r('app.media.hero_tea_light'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
          .opacity(0.92)

        Text(`“${this.quoteLine}”`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ top: 4, bottom: 12 })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }
}
