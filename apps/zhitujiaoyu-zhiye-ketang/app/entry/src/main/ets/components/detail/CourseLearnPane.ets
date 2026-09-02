import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppIcon } from '../design-system/AppIcon'
import { CourseItem, CourseChapterItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { CourseChapterService } from '../../services/CourseChapterService'
import { LearnProgressService } from '../../services/LearnProgressService'
import { StudyStatsService } from '../../services/StudyStatsService'
import { DetailShell } from './DetailShell'

/** 章节学习页 — 视频演示区 + 图文正文 + 标记完成 */
@Component
export struct CourseLearnPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CourseItem = new CourseItem()
  @State chapterIndex: number = 0
  @State chapters: CourseChapterItem[] = []
  @State toastText: string = ''
  @StorageLink('progressTick') progressTick: number = 0

  aboutToAppear(): void {
    this.chapters = CourseChapterService.buildChapters(this.item)
    const stored = AppStorage.get<number>('learnChapterIndex')
    if (stored !== undefined && stored !== null && stored >= 0) {
      this.chapterIndex = stored
    } else {
      this.chapterIndex = this.firstOpenIndex()
    }
  }

  private firstOpenIndex(): number {
    let i = 0
    while (i < this.chapters.length) {
      if (!StudyStatsService.isChapterDone(this.item.id, this.chapters[i].index)) {
        return i
      }
      i = i + 1
    }
    return this.chapters.length > 0 ? this.chapters.length - 1 : 0
  }

  private current(): CourseChapterItem {
    if (this.chapters.length === 0) {
      return new CourseChapterItem()
    }
    if (this.chapterIndex < 0 || this.chapterIndex >= this.chapters.length) {
      return this.chapters[0]
    }
    return this.chapters[this.chapterIndex]
  }

  private progressPercent(): number {
    return LearnProgressService.getPercent(this.item.id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async markDone(): Promise<void> {
    const ch = this.current()
    if (ch.index <= 0) {
      return
    }
    const pct = await StudyStatsService.markChapterDone(this.item.id, ch.index, this.chapters.length)
    await LearnProgressService.setPercent(this.item.id, pct)
    CareerDetailNav.bump()
    this.showToast('本章已标记完成')
  }

  private goPrev(): void {
    if (this.chapterIndex > 0) {
      this.chapterIndex = this.chapterIndex - 1
    }
  }

  private goNext(): void {
    if (this.chapterIndex + 1 < this.chapters.length) {
      this.chapterIndex = this.chapterIndex + 1
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: '章节学习',
        onBack: () => CareerDetailNav.close()
      }) {
        Column() {
          Row({ space: Theme.space.s2 }) {
            Text(`进度 ${this.progressPercent()}%`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
            Text(`${this.chapterIndex + 1}/${this.chapters.length}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s2
          })

          Progress({ value: this.progressPercent(), total: 100, type: ProgressType.Linear })
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().brandPrimaryContainer)

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.chapters, (ch: CourseChapterItem) => {
                Text(`${ch.index}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.chapterIndex === ch.index - 1 ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .width(32)
                  .height(32)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(this.chapterIndex === ch.index - 1 ?
                    Theme.colors().brandPrimary :
                    (StudyStatsService.isChapterDone(this.item.id, ch.index) ?
                      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard))
                  .borderRadius(Theme.radius.pill)
                  .onClick(() => { this.chapterIndex = ch.index - 1 })
              }, (ch: CourseChapterItem) => `${ch.index}`)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s3,
              bottom: Theme.space.s2
            })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Scroll() {
            Column({ space: Theme.space.s4 }) {
              if (this.current().kind === 'video') {
                Stack({ alignContent: Alignment.Center }) {
                  Image(CareerMedia.cover(this.item.coverKey, this.item.category))
                    .width('100%')
                    .height(200)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.lg)
                  Column()
                    .width('100%')
                    .height(200)
                    .backgroundColor('rgba(15,22,56,0.45)')
                    .borderRadius(Theme.radius.lg)
                  Column({ space: Theme.space.s2 }) {
                    AppIcon({ name: 'chart', iconSize: 40, color: '#FFFFFF' })
                    Text('视频精讲（演示）')
                      .fontSize(Theme.type.subhead)
                      .fontColor('#FFFFFF')
                    Text(`约 ${this.current().durationMin} 分钟`)
                      .fontSize(Theme.type.caption)
                      .fontColor('#FFFFFF')
                  }
                }
                .width('100%')
              }

              Text(this.current().title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              AppCard({ title: '本章内容', variant: 'plain' }) {
                Text(this.current().body)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(24)
                  .width('100%')
              }

              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: '上一章',
                  variant: 'secondary',
                  onTap: (): void => this.goPrev()
                }).layoutWeight(1)
                AppButton({
                  label: StudyStatsService.isChapterDone(this.item.id, this.current().index) ?
                    '已完成' : '标记完成',
                  onTap: (): void => { void this.markDone() }
                }).layoutWeight(1)
                AppButton({
                  label: '下一章',
                  variant: 'secondary',
                  onTap: (): void => this.goNext()
                }).layoutWeight(1)
              }
              .width('100%')
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
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height('100%')
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
