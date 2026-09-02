import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppStatCard } from '../design-system/AppStatCard'
import { FanKind, FanStats } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'

/** 首页球迷记忆条：成长 KPI + 五项快捷入口（3.5 实质功能首屏可见） */
@Component
export struct FanHomeStrip {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @State stats: FanStats = new FanStats()
  onGoWorkbench: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await FanMemoryStore.ensureChallenges()
    await FanMemoryStore.touchStreak()
    this.stats = FanMemoryStore.stats()
  }

  private open(kind: string): void {
    CourtDetailNav.openFanList(kind)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('我的球迷记忆')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('观赛、日志、复盘由你主动写下 · 不拉赛程 · 无额外权限')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      Row({ space: Theme.space.s3 }) {
        AppStatCard({
          label: '观看比赛',
          value: `${this.stats.matchCount}`,
          trend: `日志 ${this.stats.journalCount}`,
          positive: true
        }).layoutWeight(1)
        AppStatCard({
          label: '收藏球队',
          value: `${this.stats.teamCount}`,
          trend: `记录 ${this.stats.totalRecords}`,
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        this.Chip(FanKind.MATCH, '观赛记录')
        this.Chip(FanKind.JOURNAL, '球迷日志')
        this.Chip(FanKind.TEAM, '球队收藏')
        this.Chip(FanKind.REVIEW, '复盘笔记')
        this.Chip(FanKind.HIGHLIGHT, '精彩瞬间')
      }
      .width('100%')

      AppButton({
        label: '进入拾光工作台',
        variant: 'secondary',
        onTap: (): void => {
          this.onGoWorkbench()
        }
      })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  Chip(kind: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(Theme.colors().textOnBrandContainer)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .margin({ right: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.open(kind)
      })
  }
}
