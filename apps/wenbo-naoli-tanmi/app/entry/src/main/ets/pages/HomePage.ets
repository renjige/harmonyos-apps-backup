import { Theme } from '../components/design-system/Theme'
import { BrainMedia } from '../services/BrainMedia'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { BrainProgress } from '../services/BrainProgress'
import { DrillItem } from '../models/BrainModels'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('wisdomIndex') wisdom: number = 0
  @StorageLink('streakDays') streak: number = 0
  @StorageLink('assessDoneFlag') assessFlag: number = 0
  @StorageLink('progressTick') tick: number = 0
  @State drills: DrillItem[] = []
  @State err: string = ''
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.err = ''
    const list = await BrainBizService.loadDrills()
    this.drills = list
    this.loading = false
    if (list.length === 0) {
      this.err = BrainBizService.lastHint()
    }
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(BrainMedia.cover('hero_aurora'))
              .width('100%')
              .height(210)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(210)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0.10)', 0], ['rgba(10,22,40,0.90)', 1]]
              })
            Column({ space: 6 }) {
              Text('脑力探秘')
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
              Text('Mind Explorer · 今日探索')
                .fontSize(13)
                .fontColor('#E2E8F0')
              Text(`智慧指数 ${this.wisdom} · 连续 ${this.streak} 天 · 今日 ${BrainProgress.dailyDoneCount()}/5`)
                .fontSize(14)
                .fontColor('#FFFFFF')
            }
            .padding({ left: 16, right: 16, bottom: 16 })
          }
          .width('100%')
          .height(210)

          if (this.assessFlag === 0) {
            Row() {
              Column({ space: 4 }) {
                Text('尚未生成脑力图谱')
                  .fontSize(15)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text('十二题规则问卷，约三分钟')
                  .fontSize(13)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Text('开始测评')
                .fontSize(14)
                .fontColor(Theme.colors().brandOnPrimary)
                .backgroundColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .borderRadius(10)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
            .onClick(() => BrainNav.open(BrainNav.ASSESS, ''))
          }

          Text('今日五项')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          if (this.loading) {
            Text('正在拉取训练目录').fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.drills.length === 0) {
            if (this.err.length > 0) {
              AppError({ retryLabel: '重试', onRetry: () => { void this.reload() } })
            } else {
              AppEmpty({ title: '暂无训练', description: '请稍后刷新', actionLabel: '重试', onAction: () => { void this.reload() } })
            }
          } else {
            ForEach(this.drills, (d: DrillItem) => {
              this.DrillCard(d)
            }, (d: DrillItem) => d.id)
          }
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

  @Builder
  DrillCard(d: DrillItem) {
    Column({ space: 8 }) {
      Image(BrainMedia.cover(d.coverKey))
        .width('100%')
        .height(120)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 16, topRight: 16 })
      Text(d.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 12, right: 12 })
      Text(`${d.durationMin} 分钟 · ${d.categoryLabel} · ${d.difficulty}`)
        .fontSize(13)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: 12, right: 12 })
      Text(d.summary)
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(2)
        .width('100%')
        .padding({ left: 12, right: 12 })
      Text('开始训练')
        .width('90%')
        .height(40)
        .textAlign(TextAlign.Center)
        .fontSize(15)
        .fontColor(Theme.colors().brandOnPrimary)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(10)
        .margin({ bottom: 12 })
        .onClick(() => BrainNav.open(BrainNav.DRILL, d.id))
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(16)
    .onClick(() => BrainNav.open(BrainNav.DRILL, d.id))
  }
}
