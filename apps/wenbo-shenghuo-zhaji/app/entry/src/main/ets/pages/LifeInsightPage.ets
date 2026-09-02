import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { LifeInsightService, LifeInsightSnapshot, MoodStat } from '../services/LifeInsightService'
import { AuthService } from '../services/AuthService'

/** 生活洞察：融合札记/心情/打卡/清单的月度成长摘要（差异化能力） */
@Component
export struct LifeInsightPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State snap: LifeInsightSnapshot = new LifeInsightSnapshot()
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.snap = new LifeInsightSnapshot()
      this.loading = false
      return
    }
    this.snap = await LifeInsightService.build(this.currentUsername)
    this.loading = false
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('生活洞察')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后查看生活洞察',
                description: '融合札记、心情、打卡与清单，自动生成月度成长摘要'
              })
            } else if (this.loading) {
              Text('正在分析本月生活数据…')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            } else {
              AppCard({ title: this.snap.monthLabel, variant: 'plain' }) {
                Column({ space: Theme.space.s3 }) {
                  Text(`生活成长指数 ${this.snap.growthScore}`)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.snap.narrative)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                    .lineHeight(24)
                }
                .width('100%')
              }

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '札记',
                  value: `${this.snap.diaryCount}`,
                  trend: '本月',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '心情',
                  value: `${this.snap.moodCount}`,
                  trend: '打点',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '打卡',
                  value: `${this.snap.habitDoneDays}`,
                  trend: '本月完成',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '清单',
                  value: `${this.snap.listDone}/${this.snap.listTotal}`,
                  trend: '已完成',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              if (this.snap.moodStats.length > 0) {
                AppCard({ title: '情绪分布', variant: 'plain' }) {
                  Column({ space: Theme.space.s2 }) {
                    ForEach(this.snap.moodStats, (stat: MoodStat) => {
                      Row({ space: Theme.space.s2 }) {
                        Text(stat.label)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .width(56)
                        Column() {
                          Row()
                            .width(`${Math.min(stat.count * 24, 100)}%`)
                            .height(8)
                            .backgroundColor(Theme.colors().brandPrimary)
                            .borderRadius(Theme.radius.pill)
                        }
                        .layoutWeight(1)
                        .height(8)
                        .backgroundColor(Theme.colors().surfaceSubtle)
                        .borderRadius(Theme.radius.pill)
                        Text(`${stat.count}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                          .width(24)
                          .textAlign(TextAlign.End)
                      }
                      .width('100%')
                    }, (stat: MoodStat) => stat.key)
                  }
                  .width('100%')
                }
              }

              AppButton({
                label: '刷新洞察',
                variant: 'secondary',
                onTap: (): void => { void this.reload() }
              })
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
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
