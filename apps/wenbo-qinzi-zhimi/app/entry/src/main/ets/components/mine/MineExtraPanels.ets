import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppButton } from '../design-system/AppButton'
import { PuzzleItem } from '../../models/PuzzleModels'
import { QuizBizService } from '../../services/QuizBizService'
import { QuizNav } from '../../services/QuizNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct WrongPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: PuzzleItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const all = await QuizBizService.loadPuzzles()
    const ids = ProgressStore.snapshot().wrongIds
    const out: PuzzleItem[] = []
    for (const id of ids) {
      const found = QuizBizService.find(all, id)
      if (found !== undefined) {
        out.push(found)
      }
    }
    this.items = out
  }

  private startAll(): void {
    const ids: string[] = []
    for (const p of this.items) {
      ids.push(p.id)
    }
    if (ids.length === 0) {
      return
    }
    QuizNav.openQuiz(ids, 0)
  }

  build() {
    Column() {
      Row() {
        Text('返回').fontSize(15).fontColor(Theme.colors().brandPrimary).onClick(() => this.onBack())
        Blank()
        Text('错题本').fontSize(16).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
        Blank()
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .width('100%')
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有错题',
          description: '答错的题目会记在这里，方便再练一次。',
          actionLabel: '去答题',
          onAction: () => {
            this.onBack()
            AppStorage.setOrCreate('mainTab', 1)
            QuizNav.bump()
          }
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            Text('点进去可看解析，答对后会从本页移出。')
              .fontSize(13)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            ForEach(this.items, (p: PuzzleItem) => {
              Column({ space: 6 }) {
                Text(p.ageLabel.length > 0 ? `${p.categoryLabel} · ${p.ageLabel}` : p.categoryLabel)
                  .fontSize(12)
                  .fontColor(Theme.colors().brandPrimary)
                  .width('100%')
                Text(p.title)
                  .fontSize(17)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(p.explanation.length > 0 ? p.explanation : p.hint)
                  .fontSize(13)
                  .lineHeight(20)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                  .maxLines(3)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(20)
              .onClick(() => QuizNav.openQuiz([p.id], 0))
            }, (p: PuzzleItem) => p.id)
            AppButton({
              label: '按顺序再练一遍',
              onTap: () => this.startAll()
            })
          }
          .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

@Component
export struct GrowthPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('doneCount') doneCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('todayCount') todayCount: number = 0
  @State weekly: number[] = []
  @State familyRounds: number = 0
  @State medalCount: number = 0
  @State wrongCount: number = 0
  onBack: () => void = () => {}

  aboutToAppear(): void {
    this.weekly = ProgressStore.weeklyDots()
    this.familyRounds = ProgressStore.snapshot().familyRounds
    this.medalCount = ProgressStore.snapshot().medalIds.length
    this.wrongCount = ProgressStore.snapshot().wrongIds.length
  }

  build() {
    Column() {
      Row() {
        Text('返回').fontSize(15).fontColor(Theme.colors().brandPrimary).onClick(() => this.onBack())
        Blank()
        Text('成长足迹').fontSize(16).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
        Blank()
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .width('100%')
      Scroll() {
        Column({ space: 12 }) {
          this.Stat('累计答对', `${this.doneCount} 题`)
          this.Stat('连续挑战', `${this.streakDays} 天`)
          this.Stat('今日进度', `${this.todayCount}/${ProgressStore.dailyGoal()}`)
          this.Stat('亲子对答', `${this.familyRounds} 轮`)
          this.Stat('已点亮勋章', `${this.medalCount} 枚`)
          this.Stat('待复习错题', `${this.wrongCount} 题`)
          Text('近 7 日足迹')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: 8 })
          Row() {
            ForEach(this.weekly, (n: number, idx: number) => {
              Column({ space: 4 }) {
                Column()
                  .width(22)
                  .height(22)
                  .borderRadius(11)
                  .backgroundColor(n >= 3 ? Theme.colors().brandPrimary :
                    (n > 0 ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle))
                Text(idx === this.weekly.length - 1 ? '今' : `${idx + 1}`)
                  .fontSize(10)
                  .fontColor(Theme.colors().textTertiary)
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }, (n: number, idx: number) => `g-${idx}`)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          Text('只统计当前登录账号的记录。换账号后不会看到别人的进度。')
            .fontSize(13)
            .lineHeight(20)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Stat(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(Theme.colors().textSecondary)
        .layoutWeight(1)
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(18)
  }
}
