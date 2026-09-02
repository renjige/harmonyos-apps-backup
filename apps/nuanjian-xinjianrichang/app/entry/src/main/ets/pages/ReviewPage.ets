import { Theme } from '../components/design-system/Theme'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem } from '../models/NoteModels'
import { HeartNoteStore } from '../services/HeartNoteStore'
import { NoteDateUtil } from '../services/NoteDateUtil'
import { NoteNav } from '../services/NoteNav'
import { MoodCount, ReviewStats } from '../services/ReviewStats'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State monthCount: number = 0
  @State topMood: string = '还没有留下心情'
  @State topTag: string = '还没有标签'
  @State moodCounts: MoodCount[] = []
  @State picks: NoteItem[] = []
  @State months: string[] = []
  @State selectedMonth: string = NoteDateUtil.currentMonthKey()

  aboutToAppear(): void {
    this.rebuild()
  }

  onRefreshTokenChange(): void {
    this.rebuild()
  }

  private rebuild(): void {
    const all = HeartNoteStore.sorted()
    const monthNotes: NoteItem[] = []
    for (const n of all) {
      if (NoteDateUtil.monthKey(n.noteDate) === this.selectedMonth) {
        monthNotes.push(n)
      }
    }
    this.months = ReviewStats.uniqueMonths(all)
    this.monthCount = monthNotes.length
    this.moodCounts = ReviewStats.moodCounts(monthNotes)
    this.topMood = ReviewStats.topMoodLabel(this.moodCounts)
    this.topTag = ReviewStats.topTag(monthNotes)
    this.picks = ReviewStats.pickThree(monthNotes)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('看见生活留下的痕迹')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Stack() {
          Image($r('app.media.banner_review'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
          Column() {
            Text('这个月的心情')
              .fontSize(Theme.type.body)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding({ left: 18, right: 18, bottom: 16 })
          .linearGradient({
            angle: 180,
            colors: [['rgba(39,35,33,0)', 0], ['rgba(39,35,33,0.58)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)

        AppCard({ title: '本月留下的痕迹' }) {
          Column({ space: 8 }) {
            Text(`本月记录 ${this.monthCount} 次`)
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`最常见心情：${this.topMood}`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`最常出现标签：${this.topTag}`)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
        }

        AppCard({ title: '心情分布' }) {
          Column({ space: 10 }) {
            ForEach(this.moodCounts, (row: MoodCount) => {
              Row({ space: 10 }) {
                Text(row.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width(36)
                Row()
                  .width(ReviewStats.barWidth(row.count))
                  .height(10)
                  .backgroundColor(row.color)
                  .borderRadius(Theme.radius.pill)
                Text(`${row.count}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .width('100%')
            }, (row: MoodCount) => row.id)
          }
          .width('100%')
        }

        Text('这个月，你记录过的瞬间')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.picks.length === 0) {
          AppEmpty({
            title: '这个月还很安静',
            description: '写一封心笺，痕迹就会慢慢出现。'
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.picks, (n: NoteItem) => {
              NoteListCard({ item: n, onTap: (): void => { NoteNav.openDetail(n.id) } })
            }, (n: NoteItem) => n.id)
          }
          .width('100%')
          Text('原来这个月，也有这么多值得记住的时刻。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }

        if (this.months.length > 0) {
          Text('曾经写下的月份')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.months, (m: string) => {
              Text(NoteDateUtil.monthTitle(m))
                .fontSize(Theme.type.caption)
                .fontColor(this.selectedMonth === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.selectedMonth === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.selectedMonth = m
                  this.rebuild()
                })
            }, (m: string) => m)
          }
          .width('100%')
        }
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
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
