import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppStatCard } from '../design-system/AppStatCard'
import { CourtMedia } from '../../config/CourtMedia'
import { FanHubItem, FanKind, FanStats } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'

/** 拾光工作台：成长统计 + 五项主能力影像卡 + 工具入口（非同构色块列表） */
@Component
export struct FanHubGrid {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @State stats: FanStats = new FanStats()
  @State primary: FanHubItem[] = []
  @State tools: FanHubItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.stats = FanMemoryStore.stats()
    this.primary = FanMemoryStore.hubPrimary()
    this.tools = FanMemoryStore.hubTools()
  }

  private open(kind: string): void {
    if (kind === FanKind.EVENT) {
      CourtDetailNav.openFanCalendar()
      return
    }
    CourtDetailNav.openFanList(kind)
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Text('球迷成长')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
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
          trend: `球员 ${this.stats.playerCount}`,
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')
      Row({ space: Theme.space.s3 }) {
        AppStatCard({
          label: '记录次数',
          value: `${this.stats.totalRecords}`,
          trend: `合集 ${this.stats.albumCount}`,
          positive: true
        }).layoutWeight(1)
        AppStatCard({
          label: '连续使用',
          value: `${this.stats.streakDays}天`,
          trend: `挑战 ${this.stats.challengeDone}/${this.stats.challengeTotal}`,
          positive: true
        }).layoutWeight(1)
      }
      .width('100%')

      Text('赛事记忆')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('主动记下观赛、日志与复盘，内容只留在本机')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')

      if (this.primary.length >= 2) {
        Row({ space: Theme.space.s3 }) {
          Column() {
            this.PhotoTile(this.primary[0], 108)
          }
          .layoutWeight(1)
          Column() {
            this.PhotoTile(this.primary[1], 108)
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      if (this.primary.length >= 4) {
        Row({ space: Theme.space.s3 }) {
          Column() {
            this.PhotoTile(this.primary[2], 108)
          }
          .layoutWeight(1)
          Column() {
            this.PhotoTile(this.primary[3], 108)
          }
          .layoutWeight(1)
        }
        .width('100%')
      }
      if (this.primary.length >= 5) {
        Column() {
          this.PhotoTile(this.primary[4], 88)
        }
        .width('100%')
      }

      AppButton({
        label: '记一场观赛',
        onTap: (): void => {
          CourtDetailNav.openFanEditor(FanKind.MATCH, '')
        }
      })
      AppButton({
        label: '记忆时光轴',
        variant: 'secondary',
        onTap: (): void => {
          CourtDetailNav.openFanTimeline()
        }
      })

      Text('更多工具')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tools, (item: FanHubItem) => {
          Text(`${item.title} ${item.count}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnBrandContainer)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              this.open(item.kind)
            })
        }, (item: FanHubItem) => item.kind)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  PhotoTile(item: FanHubItem, h: number) {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(CourtMedia.byKey(item.coverKey))
        .width('100%')
        .height(h)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.lg)
      Column()
        .width('100%')
        .height(h)
        .borderRadius(Theme.radius.lg)
        .linearGradient({
          angle: 180,
          colors: [['rgba(26,42,58,0.05)', 0.0], ['rgba(26,42,58,0.82)', 1.0]]
        })
      Column({ space: 2 }) {
        Text(item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        Text(`${item.count} 条 · ${item.hint}`)
          .fontSize(Theme.type.caption)
          .fontColor('rgba(255,255,255,0.92)')
          .maxLines(2)
      }
      .padding(Theme.space.s3)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .clip(true)
    .borderRadius(Theme.radius.lg)
    .onClick(() => {
      this.open(item.kind)
    })
  }
}
