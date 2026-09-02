import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { StepBizService } from '../services/StepBizService'
import { MicroGoalStats } from '../models/MicroGoalModels'

@Component
export struct TrackPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State stats: MicroGoalStats = new MicroGoalStats()
  @State marks: Record<string, number> = {}
  @State monthLabel: string = ''
  @State selectedDay: string = ''
  @State dayCount: number = 0
  @StorageLink('accessToken') accessToken: string = ''

  aboutToAppear(): void {
    const d = new Date()
    this.monthLabel = `${d.getFullYear()}年${d.getMonth() + 1}月`
    void this.reload()
  }

  async reload(): Promise<void> {
    this.stats = await StepBizService.loadStats()
    const cal = await StepBizService.loadCalendar()
    this.marks = cal.calendarMarks
  }

  private daysInMonth(): number {
    const d = new Date()
    return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()
  }

  private dayKey(day: number): string {
    const d = new Date()
    const m = String(d.getMonth() + 1).padStart(2, '0')
    const dd = String(day).padStart(2, '0')
    return `${d.getFullYear()}-${m}-${dd}`
  }

  private monthDays(): number[] {
    const n = this.daysInMonth()
    const out: number[] = []
    for (let i = 1; i <= n; i++) {
      out.push(i)
    }
    return out
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_progress'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column({ space: 4 }) {
            Text(`${this.stats.streakDays}`)
              .fontSize(Theme.type.displayM)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text('天坚持')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .width('100%')
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.75)', 1]],
          })
        }

        Row({ space: Theme.space.s3 }) {
          AppStatCard({
            label: '本月完成率',
            value: `${this.stats.completionRate}%`,
          }).layoutWeight(1)
          AppStatCard({
            label: '累计完成天',
            value: `${this.stats.totalDoneDays}`,
          }).layoutWeight(1)
        }

        Text(this.monthLabel)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.monthDays(), (day: number) => {
            Column({ space: 4 }) {
              Text(`${day}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Circle({ width: 6, height: 6 })
                .fill(this.marks[this.dayKey(day)] !== undefined && this.marks[this.dayKey(day)] > 0
                  ? Theme.colors().brandPrimary
                  : Theme.colors().strokeHairline)
            }
            .width('14.28%')
            .padding(6)
            .onClick(() => {
              this.selectedDay = this.dayKey(day)
              this.dayCount = this.marks[this.selectedDay] ?? 0
            })
          }, (day: number) => `${day}`)
        }
        .width('100%')

        if (this.selectedDay.length > 0) {
          Text(`${this.selectedDay} 完成 ${this.dayCount} 项微目标`)
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }

        Text(`本月完成 ${this.stats.monthDoneDays} / ${this.stats.monthTotalDays} 天`)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.pageX)
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
