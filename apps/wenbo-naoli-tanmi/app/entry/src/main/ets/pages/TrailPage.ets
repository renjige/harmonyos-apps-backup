import { Theme } from '../components/design-system/Theme'
import { BrainMedia } from '../services/BrainMedia'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { BrainProgress } from '../services/BrainProgress'
import { AchieveItem } from '../models/BrainModels'

@Component
export struct TrailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wisdomIndex') wisdom: number = 0
  @StorageLink('streakDays') streak: number = 0
  @StorageLink('sessionCount') sessions: number = 0
  @StorageLink('progressTick') tick: number = 0
  @State badges: AchieveItem[] = []
  @State range: string = 'week'

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.badges = await BrainBizService.loadAchievements()
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(BrainMedia.cover('trail_nebula'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(160)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0.12)', 0], ['rgba(0,0,0,0.82)', 1]]
              })
            Column({ space: 4 }) {
              Text('成长轨迹')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Text(`训练 ${this.sessions} 次 · 连续 ${this.streak} 天 · 指数 ${this.wisdom}`)
                .fontSize(14)
                .fontColor('#E2E8F0')
            }
            .padding(16)
          }
          .width('100%')
          .height(160)

          Text('脑力图谱')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          this.DimBar('记忆力', BrainProgress.snapshot().memoryScore)
          this.DimBar('专注力', BrainProgress.snapshot().focusScore)
          this.DimBar('反应力', BrainProgress.snapshot().speedScore)
          this.DimBar('逻辑力', BrainProgress.snapshot().logicScore)

          Row({ space: 10 }) {
            Text('近7次')
              .fontSize(13)
              .fontColor(this.range === 'week' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.range === 'week' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(8)
              .onClick(() => {
                this.range = 'week'
              })
            Text('累计')
              .fontSize(13)
              .fontColor(this.range === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor(this.range === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(8)
              .onClick(() => {
                this.range = 'all'
              })
          }
          .width('100%')

          Text(this.trendText())
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Text('成就墙')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Scroll() {
            Row({ space: 10 }) {
              ForEach(this.badges, (b: AchieveItem) => {
                Column({ space: 6 }) {
                  Image(BrainMedia.cover(b.coverKey))
                    .width(96)
                    .height(96)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(12)
                    .opacity(BrainProgress.hasBadge(b.id) ? 1 : 0.45)
                  Text(b.title)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                }
                .width(100)
                .onClick(() => BrainNav.open(BrainNav.ACHIEVE, b.id))
              }, (b: AchieveItem) => b.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .width('100%')
          .height(140)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 24 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private trendText(): string {
    const pts = BrainProgress.weekPoints()
    if (pts.length === 0) {
      return '完成训练后，这里会留下得分轨迹。'
    }
    if (this.range === 'all') {
      return `累计 ${this.sessions} 次，最近一局 ${BrainProgress.snapshot().lastScore} 分。`
    }
    return `近 ${pts.length} 局：${pts.join(' / ')}`
  }

  @Builder
  DimBar(label: string, value: number) {
    Column({ space: 4 }) {
      Row() {
        Text(label).fontSize(14).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
        Text(`${value}`).fontSize(14).fontColor(Theme.colors().brandAccent)
      }
      .width('100%')
      Row() {
        Column()
          .height(8)
          .width(`${Math.max(4, value)}%`)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(4)
      }
      .width('100%')
      .height(8)
      .backgroundColor(Theme.colors().surfaceSubtle)
      .borderRadius(4)
    }
    .width('100%')
  }
}
