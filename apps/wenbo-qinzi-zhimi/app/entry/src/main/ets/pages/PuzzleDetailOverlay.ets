import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { PuzzleItem } from '../models/PuzzleModels'
import { QuizBizService } from '../services/QuizBizService'
import { QuizMedia } from '../services/QuizMedia'
import { QuizNav } from '../services/QuizNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct PuzzleDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State item: PuzzleItem = new PuzzleItem()
  @State favoriteOn: boolean = false
  @State toastText: string = ''
  @State ready: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  async load(): Promise<void> {
    const list = await QuizBizService.loadPuzzles()
    const id = QuizNav.detailId()
    const found = QuizBizService.find(list, id)
    if (found !== undefined) {
      this.item = found
      this.favoriteOn = ProgressStore.isFavorite(found.id)
      this.ready = true
      return
    }
    this.ready = false
  }

  private startQuiz(): void {
    if (this.item.id.length === 0) {
      this.showToast('题目还没准备好')
      return
    }
    QuizNav.openQuiz([this.item.id], 0)
  }

  private async handleFavorite(): Promise<void> {
    if (this.item.id.length === 0) {
      return
    }
    await ProgressStore.toggleFavorite(this.item.id, this.item.title)
    this.favoriteOn = ProgressStore.isFavorite(this.item.id)
    this.showToast(this.favoriteOn ? '已收藏' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '谜题详情',
        onClose: (): void => { QuizNav.close() }
      }) {
        if (!this.ready) {
          Column({ space: 12 }) {
            Text('正在加载谜题…')
              .fontSize(15)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        } else {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(QuizMedia.cover(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(30,42,58,0.05)', 0], ['rgba(30,42,58,0.72)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.item.categoryLabel)
                  .fontSize(13)
                  .fontColor('#FFFFFF')
                Text(this.item.title)
                  .fontSize(22)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .maxLines(2)
              }
              .padding({ left: 20, right: 20, bottom: 18 })
            }
            .clip(true)
            .borderRadius(24)
            .width('100%')

            Row({ space: 10 }) {
              Text(this.item.difficulty)
                .fontSize(12)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
              if (this.item.ageLabel && this.item.ageLabel.length > 0) {
                Text(this.item.ageLabel)
                  .fontSize(12)
                  .fontColor(Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
              }
              if (ProgressStore.isCompleted(this.item.id)) {
                Text('已答对')
                  .fontSize(12)
                  .fontColor(Theme.colors().success)
                  .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                  .backgroundColor(Theme.colors().successContainer)
                  .borderRadius(Theme.radius.pill)
              }
            }
            .width('100%')

            Column({ space: 8 }) {
              Text('谜题简介')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.item.summary.length > 0 ? this.item.summary : '一起读题、一起选答案，答完会有温柔解析。')
                .fontSize(15)
                .lineHeight(24)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .padding(18)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(22)
            .width('100%')

            Column({ space: 8 }) {
              Text('题目预览')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.item.question)
                .fontSize(17)
                .lineHeight(28)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }
            .padding(18)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(22)
            .width('100%')

            AppButton({
              label: '开始答题',
              onTap: (): void => { this.startQuiz() }
            })
            Row() {
              AppButton({
                label: this.favoriteOn ? '已收藏' : '收藏这题',
                variant: 'secondary',
                onTap: (): void => { void this.handleFavorite() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.handleFavorite() })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
          .width('100%')
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(30,42,58,0.88)')
          .borderRadius(20)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
