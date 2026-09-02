import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { WeeklyReview } from '../models/GrowthModels'
import { GrowthService } from '../services/GrowthService'
import { QuizNav } from '../services/QuizNav'

@Component
export struct WeeklyReviewOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State review: WeeklyReview = new WeeklyReview()

  aboutToAppear(): void {
    this.review = GrowthService.weeklyReview()
  }

  build() {
    DetailShell({
      title: '本周回顾',
      onClose: () => QuizNav.close()
    }) {
      this.Body()
    }
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s5 }) {
      Text('这一周，你和家人一起动了多少脑？')
        .fontSize(16)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')

      this.ReviewRow('答对题数', `${this.review.correctCount} 题`)
      this.ReviewRow('亲子对答', `${this.review.familyCount} 次`)
      this.ReviewRow('新增收藏', `${this.review.newFavorites} 题`)
      this.ReviewRow('连续挑战', `${this.review.streakDays} 天`)

      Column({ space: 8 }) {
        Text('小建议')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.suggestText())
          .fontSize(14)
          .lineHeight(22)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(16)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(20)
      .width('100%')

      AppButton({
        label: '继续今日挑战',
        onTap: () => {
          QuizNav.close()
          AppStorage.setOrCreate('mainTab', 0)
        }
      })
    }
    .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
    .width('100%')
  }

  private suggestText(): string {
    if (this.review.correctCount >= 15 && this.review.familyCount >= 1) {
      return '本周计划完成得很棒！可以让孩子挑一题讲给家长听，巩固理解。'
    }
    if (this.review.familyCount === 0) {
      return '还没开始亲子对答？去「亲子」页玩一轮，默契会记在这里。'
    }
    if (this.review.correctCount < 5) {
      return '每天 3 题就够养成习惯，从「今日」页的随机一题开始吧。'
    }
    return '保持节奏，错题本里的题值得周末再练一遍。'
  }

  @Builder
  ReviewRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .layoutWeight(1)
      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
  }
}
