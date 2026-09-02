import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { DailyRecordItem } from '../models/PoetryModels'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct RecordsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('poetryTick') tick: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('maxCombo') maxCombo: number = 0
  @StorageLink('totalScore') totalScore: number = 0
  @StorageLink('titleRank') titleRank: string = ''
  @StorageLink('feihuaRounds') feihuaRounds: number = 0
  @StorageLink('feihuaWins') feihuaWins: number = 0
  @StorageLink('dailyScore') dailyScore: number = 0
  @StorageLink('dailyDoneFlag') dailyDoneFlag: number = 0
  @State records: DailyRecordItem[] = []

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    this.records = ProgressStore.dailyRecords()
  }

  private feihuaRate(): string {
    if (this.feihuaRounds <= 0) {
      return '—'
    }
    const n = Math.floor((this.feihuaWins * 100) / this.feihuaRounds)
    return `${n}%`
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('挑战记录')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ top: 16 })

        Row({ space: 10 }) {
          this.StatCard('连续打卡', `${this.streakDays} 日`)
          this.StatCard('最高连击', `${this.maxCombo}`)
          this.StatCard('累计得分', `${this.totalScore}`)
        }
        .width('100%')

        Column({ space: 8 }) {
          Text(`称号：${this.titleRank}`)
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`正确率 ${ProgressStore.accuracyText()}  ·  今日 ${this.dailyDoneFlag === 1 ? `${this.dailyScore} 分` : '未完成'}`)
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Text('飞花令统计')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Row({ space: 10 }) {
          this.StatCard('接龙轮次', `${this.feihuaRounds}`)
          this.StatCard('成功轮次', `${this.feihuaWins}`)
          this.StatCard('成功率', this.feihuaRate())
        }
        .width('100%')

        Text('每日成绩')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.records.length === 0) {
          AppEmpty({
            title: '暂无挑战记录',
            description: '完成今日五题或飞花令后，成绩会记在本机',
            actionLabel: '刷新',
            onAction: (): void => { this.refresh() }
          })
        } else {
          Column({ space: 10 }) {
            ForEach(this.records, (r: DailyRecordItem) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(r.date)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`答对 ${r.correct}/${r.total}  ·  连击 ${r.maxCombo}`)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text(`${r.score} 分`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (r: DailyRecordItem) => r.date)
          }
          .width('100%')
        }

        AppButton({
          label: '清除本机进度',
          variant: 'secondary',
          onTap: (): void => { void this.clearProgress() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  private async clearProgress(): Promise<void> {
    await ProgressStore.clearLocalProgress()
    this.refresh()
  }

  @Builder
  StatCard(label: string, value: string) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .alignItems(HorizontalAlign.Start)
  }
}
