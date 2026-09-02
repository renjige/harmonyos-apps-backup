import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { CoverHero } from '../idiom/IdiomCards'
import { ChapterItem, LevelIndex } from '../../models/IdiomModels'
import { IdiomBizService } from '../../services/IdiomBizService'
import { IdiomNav } from '../../services/IdiomNav'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct ChapterDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: ChapterItem = new ChapterItem()
  @State levels: LevelIndex[] = LevelIndex.ten()
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const list = await IdiomBizService.loadChapters()
    const found = IdiomBizService.findChapter(list, IdiomNav.detailId())
    if (found !== undefined) {
      this.item = found
    }
  }

  private startLevel(level: number): void {
    if (!ProgressStore.isGateOpen(this.item.chapterIndex, level)) {
      return
    }
    void this.launch(level)
  }

  private async launch(level: number): Promise<void> {
    const qs = await IdiomBizService.loadLevelQuestions(this.item.chapterIndex, level)
    const ids = IdiomBizService.idsOf(qs)
    if (ids.length === 0) {
      return
    }
    AppStorage.setOrCreate('quizChapter', this.item.chapterIndex)
    AppStorage.setOrCreate('quizLevel', level)
    IdiomNav.openQuiz(ids, 'campaign')
  }

  private levelLabel(level: number): string {
    if (ProgressStore.isGatePassed(this.item.chapterIndex, level)) {
      return `第${level}关 · 金印`
    }
    if (ProgressStore.isGateOpen(this.item.chapterIndex, level)) {
      return `第${level}关 · 可挑战`
    }
    return `第${level}关 · 未解锁`
  }

  build() {
    Column() {
      DetailShell({ title: this.item.title, onBack: () => IdiomNav.close() })
      Scroll() {
        Column({ space: 14 }) {
          CoverHero({
            coverKey: this.item.coverKey,
            title: this.item.title,
            subtitle: `${this.item.difficulty} · 十关精研`,
            heroHeight: 200
          })
          Column({ space: 8 }) {
            Text('本章说明')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(15)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item.body)
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text('关卡')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          ForEach(this.levels, (slot: LevelIndex) => {
            Row() {
              Text(this.levelLabel(slot.n))
                .fontSize(14)
                .fontColor(ProgressStore.isGateOpen(this.item.chapterIndex, slot.n) ?
                  Theme.colors().textPrimary : Theme.colors().textSecondary)
                .layoutWeight(1)
              if (ProgressStore.isGateOpen(this.item.chapterIndex, slot.n)) {
                Text('进入')
                  .fontSize(13)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
            }
            .width('100%')
            .padding(14)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .opacity(ProgressStore.isGateOpen(this.item.chapterIndex, slot.n) ? 1 : 0.55)
            .onClick(() => this.startLevel(slot.n))
          }, (slot: LevelIndex) => `lv-${slot.n}`)

          AppButton({
            label: '从当前可挑战关开始',
            onTap: () => this.startLevel(this.firstOpen())
          })
        }
        .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private firstOpen(): number {
    for (let i = 1; i <= 10; i++) {
      if (ProgressStore.isGateOpen(this.item.chapterIndex, i) &&
        !ProgressStore.isGatePassed(this.item.chapterIndex, i)) {
        return i
      }
    }
    return 1
  }
}
