import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { FanMilestone } from '../models/FanModels'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { pasteboard } from '@kit.BasicServicesKit'

/** 球迷成长报告：KPI + 分布图 + 里程碑 + 活跃日历 + 导出 */
@Component
export struct FanDashboardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fanEpoch') @Watch('onEpoch') fanEpoch: number = 0
  @State chartItems: BarChartItem[] = []
  @State milestones: FanMilestone[] = []
  @State recapLines: string[] = []
  @State activeDays: number[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onEpoch(): void {
    this.reload()
  }

  private reload(): void {
    const counts = FanMemoryStore.typeCounts()
    const items: BarChartItem[] = []
    for (let i = 0; i < counts.length; i++) {
      const row = new BarChartItem()
      row.label = counts[i].label
      row.value = counts[i].value
      items.push(row)
    }
    this.chartItems = items
    this.milestones = FanMemoryStore.milestones()
    this.recapLines = FanMemoryStore.monthlyRecapLines()
    const now = new Date()
    this.activeDays = FanMemoryStore.activeDaysInMonth(now.getFullYear(), now.getMonth() + 1)
  }

  private challengePercent(): number {
    const s = FanMemoryStore.stats()
    if (s.challengeTotal <= 0) {
      return 0
    }
    return s.challengeDone / s.challengeTotal
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2400)
  }

  private async exportAll(): Promise<void> {
    const text = FanMemoryStore.exportAllText()
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
    const sysBoard = pasteboard.getSystemPasteboard()
    await sysBoard.setData(data)
    this.showToast('全部记忆已复制到剪贴板')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick((): void => {
            CourtDetailNav.closeFanDashboard()
          })
          Text('球迷成长报告')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('基于本机记忆动态生成，不拉赛程、不申请额外权限')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            Row({ space: Theme.space.s3 }) {
              AppStatCard({
                label: '累计记忆',
                value: `${FanMemoryStore.stats().totalRecords}`,
                trend: `连续 ${FanMemoryStore.stats().streakDays} 天`,
                positive: true
              }).layoutWeight(1)
              AppStatCard({
                label: '观赛场次',
                value: `${FanMemoryStore.stats().matchCount}`,
                trend: `复盘 ${FanMemoryStore.stats().reviewCount}`,
                positive: true
              }).layoutWeight(1)
            }
            .width('100%')

            if (this.chartItems.length > 0) {
              AppBarChart({
                title: '记忆类型分布',
                items: this.chartItems
              })
            }

            AppRingChart({
              title: '球迷挑战完成率',
              percent: this.challengePercent()
            })

            Column({ space: Theme.space.s2 }) {
              Text('成长里程碑')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.milestones, (m: FanMilestone) => {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 2 }) {
                    Text(m.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(m.unlocked ? Theme.colors().success : Theme.colors().textPrimary)
                    Text(m.hint)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(m.progress)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(m.unlocked ? Theme.colors().successContainer : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
              }, (m: FanMilestone) => m.id)
            }
            .width('100%')

            Column({ space: Theme.space.s2 }) {
              Text('本月活跃日历')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.activeDays.length > 0 ?
                `已记录日期：${this.activeDays.join('、')} 日` :
                '本月还没有记忆，试试场景创作向导')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.recapLines, (line: string, idx: number) => {
                Text(`· ${line}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }, (line: string, idx: number) => `dash_recap_${idx}`)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })

            AppButton({
              label: '赛后全套复盘向导',
              onTap: (): void => {
                CourtDetailNav.openFanWizard()
              }
            })
            AppButton({
              label: '复制全部记忆到剪贴板',
              variant: 'secondary',
              onTap: (): void => {
                void this.exportAll()
              }
            })
            AppButton({
              label: '打开记忆时光轴',
              variant: 'secondary',
              onTap: (): void => {
                CourtDetailNav.closeFanDashboard()
                CourtDetailNav.openFanTimeline()
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
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
