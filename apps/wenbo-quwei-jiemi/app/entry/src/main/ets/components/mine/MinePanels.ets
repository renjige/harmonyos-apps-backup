import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { PuzzleItem, PlayRecord, MedalItem, GuideItem } from '../../models/PuzzleModels'
import { QuizBizService } from '../../services/QuizBizService'
import { QuizMedia } from '../../services/QuizMedia'
import { QuizNav } from '../../services/QuizNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct FavoritesPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: PuzzleItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const all: PuzzleItem[] = await QuizBizService.loadPuzzles()
    const fav: string[] = ProgressStore.snapshot().favorites
    const out: PuzzleItem[] = []
    for (const p of all) {
      const item: PuzzleItem = p
      if (fav.indexOf(item.id) >= 0) {
        out.push(item)
      }
    }
    this.items = out
  }

  private goDiscover(): void {
    this.onBack()
    AppStorage.setOrCreate('mainTab', 1)
    QuizNav.bump()
  }

  build() {
    Column() {
      this.Top('我的收藏')
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有收藏谜题',
          description: '答题后可以把喜欢的题目收藏起来。',
          actionLabel: '去题库',
          onAction: () => this.goDiscover()
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (p: PuzzleItem) => {
              Row() {
                Column({ space: 4 }) {
                  Text(p.categoryLabel)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  Text(p.title)
                    .fontSize(17)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(20)
              .onClick(() => QuizNav.openQuiz([p.id], 0))
            }, (p: PuzzleItem) => p.id)
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

  @Builder
  Top(title: string) {
    Row() {
      Text('返回')
        .fontSize(15)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .onClick(() => this.onBack())
      Blank()
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
    }
    .padding({ left: 20, right: 20, top: 16, bottom: 12 })
    .width('100%')
  }
}

@Component
export struct RecordsPanel {
  @State items: PlayRecord[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    this.items = ProgressStore.snapshot().records
  }

  private goToday(): void {
    this.onBack()
    AppStorage.setOrCreate('mainTab', 0)
    QuizNav.bump()
  }

  build() {
    Column() {
      Row() {
        Text('返回').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).onClick(() => this.onBack())
        Blank()
        Text('挑战记录').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .width('100%')
      if (this.items.length === 0) {
        AppEmpty({
          title: '完成第一个挑战吧',
          description: '答过的题目会记录在这里。',
          actionLabel: '去首页',
          onAction: () => this.goToday()
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.items, (r: PlayRecord) => {
              Row() {
                Column({ space: 4 }) {
                  Text(r.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${r.categoryLabel} · ${r.at}`)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Column({ space: 2 }) {
                  Text(r.correct ? '答对了' : '再想想')
                    .fontSize(13)
                    .fontColor(r.correct ? Theme.colors().success : Theme.colors().textSecondary)
                  if (r.correct && r.wisdomEarned > 0) {
                    Text(`+${r.wisdomEarned} 智慧值`)
                      .fontSize(12)
                      .fontColor(Theme.colors().brandAccent)
                  }
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(20)
            }, (r: PlayRecord) => r.id)
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
export struct MedalsPanel {
  @State items: MedalItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    this.items = await QuizBizService.loadMedals()
  }

  build() {
    Column() {
      Row() {
        Text('返回').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).onClick(() => this.onBack())
        Blank()
        Text('我的勋章').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .width('100%')
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.items, (m: MedalItem) => {
            Row({ space: 14 }) {
              Image(QuizMedia.cover(m.coverKey))
                .width(64)
                .height(64)
                .borderRadius(16)
                .objectFit(ImageFit.Cover)
                .opacity(ProgressStore.isMedalOn(m.id) ? 1 : 0.45)
              Column({ space: 4 }) {
                Text(m.title)
                  .fontSize(17)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Text(ProgressStore.isMedalOn(m.id) ? '已点亮' : m.summary)
                  .fontSize(13)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(22)
            .scale({
              x: ProgressStore.isMedalOn(m.id) ? 1 : 0.98,
              y: ProgressStore.isMedalOn(m.id) ? 1 : 0.98
            })
          }, (m: MedalItem) => m.id)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}

@Component
export struct GuidePanel {
  @State items: GuideItem[] = []
  onBack: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    this.items = await QuizBizService.loadGuides()
  }

  build() {
    Column() {
      Row() {
        Text('返回').fontSize(15).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).onClick(() => this.onBack())
        Blank()
        Text('使用说明').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      .width('100%')
      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.items, (g: GuideItem) => {
            Column({ space: 8 }) {
              Text(g.title)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(g.body)
                .fontSize(15)
                .lineHeight(24)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .padding(18)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(22)
            .width('100%')
          }, (g: GuideItem) => g.id)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
