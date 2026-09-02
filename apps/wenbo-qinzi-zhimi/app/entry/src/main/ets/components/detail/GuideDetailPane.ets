import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { GuideItem } from '../../models/PuzzleModels'
import { QuizMedia } from '../../services/QuizMedia'

@Component
export struct GuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: GuideItem = new GuideItem()
  onClose: () => void = () => {}
  onTry: () => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image($r('app.media.hero_space'))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(160)
          .linearGradient({
            angle: 180,
            colors: [['rgba(30,42,58,0.05)', 0], ['rgba(30,42,58,0.72)', 1]]
          })
        Column({ space: 6 }) {
          Text('亲子指南')
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

      Column({ space: 8 }) {
        Text(this.item.summary.length > 0 ? this.item.summary : '和孩子一起轻松玩谜题的小技巧')
          .fontSize(15)
          .lineHeight(24)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.item.body.length > 0 ? this.item.body : '先读题、再讨论，不必追求一次答对。')
          .fontSize(16)
          .lineHeight(26)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(18)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(22)
      .width('100%')

      AppButton({
        label: '去今日挑战',
        onTap: (): void => { this.onTry() }
      })
      AppButton({
        label: '返回',
        variant: 'secondary',
        onTap: (): void => { this.onClose() }
      })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
    .width('100%')
  }
}
