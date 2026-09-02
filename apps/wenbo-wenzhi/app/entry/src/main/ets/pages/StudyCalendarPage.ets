import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppButton } from '../components/design-system/AppButton'
import { DayCountItem } from '../models/GrowthModels'
import { AskNav } from '../services/AskNav'
import { GrowthStore } from '../services/GrowthStore'
import { LearnStore } from '../services/LearnStore'
import { VaultStore } from '../services/VaultStore'

@Component
export struct StudyCalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State days: DayCountItem[] = []
  @State totalLearn: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.days = GrowthStore.recentDayCounts(14)
    let sum = 0
    for (const d of this.days) {
      sum += d.count
    }
    this.totalLearn = sum
  }

  private cellBg(count: number): string {
    if (count >= 3) {
      return Theme.colors().brandPrimary
    }
    if (count >= 1) {
      return Theme.colors().brandPrimaryContainer
    }
    return Theme.colorOf(this.themeEpoch).surfaceSubtle
  }

  build() {
    Column() {
      AppNavBar({ title: '学习日历', onBack: (): void => { AskNav.closeLearn() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s2 }) {
            Text('近 14 日学习热力')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(`累计学习动作 ${this.totalLearn} 次 · 连续 ${VaultStore.streakDays()} 天`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)

          Grid() {
            ForEach(this.days, (d: DayCountItem) => {
              GridItem() {
                Column({ space: 4 }) {
                  Column()
                    .width('100%')
                    .height(36)
                    .backgroundColor(this.cellBg(d.count))
                    .borderRadius(Theme.radius.xs)
                  Text(d.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
                  Text(`${d.count}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                }
                .padding(4)
              }
            }, (d: DayCountItem) => d.dayKey)
          }
          .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
          .columnsGap(6)
          .rowsGap(6)
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('今日概览')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(`今日进度 ${LearnStore.todayCount()} / ${LearnStore.goal()}`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .width('100%')
            Text(`答题 ${LearnStore.quizTimes()} 次 · 阅读 ${LearnStore.reads()} 条 · 收藏 ${VaultStore.count()} 条`)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.card)

          Row({ space: Theme.space.s2 }) {
            AppButton({
              label: '打开学习计划',
              onTap: (): void => { AskNav.openLearn('plan') }
            })
              .layoutWeight(1)
            AppButton({
              label: '查看成长统计',
              variant: 'secondary',
              onTap: (): void => { AskNav.openLearn('stats') }
            })
              .layoutWeight(1)
          }
          .width('100%')
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)
  }
}
