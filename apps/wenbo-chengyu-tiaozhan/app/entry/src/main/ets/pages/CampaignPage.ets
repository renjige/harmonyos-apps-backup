import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { IdiomListCard } from '../components/idiom/IdiomCards'
import { ChapterItem } from '../models/IdiomModels'
import { IdiomBizService } from '../services/IdiomBizService'
import { IdiomNav } from '../services/IdiomNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct CampaignPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State chapters: ChapterItem[] = []
  @StorageLink('quizTick') tick: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    this.chapters = await IdiomBizService.loadChapters()
  }

  private meta(ch: ChapterItem): string {
    let n = 0
    for (let i = 1; i <= 10; i++) {
      if (ProgressStore.isGatePassed(ch.chapterIndex, i)) {
        n++
      }
    }
    return `${ch.difficulty} · 已通 ${n}/10 关`
  }

  build() {
    Column() {
      Text('百关精研')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      Text('一关精研一个成语五题。答对四题即可解锁下一关。')
        .fontSize(14)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.chapters.length === 0) {
        AppEmpty({ title: '章节尚未载入', description: '请稍后重试', actionLabel: '刷新', onAction: () => { void this.reload() } })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.chapters, (ch: ChapterItem) => {
              IdiomListCard({
                title: ch.title,
                summary: ch.summary,
                meta: this.meta(ch),
                coverKey: ch.coverKey,
                onTap: () => IdiomNav.openChapter(ch.id)
              })
            }, (ch: ChapterItem) => ch.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
