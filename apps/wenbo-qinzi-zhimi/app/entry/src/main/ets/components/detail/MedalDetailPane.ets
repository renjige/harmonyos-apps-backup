import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { MedalItem } from '../../models/PuzzleModels'
import { QuizMedia } from '../../services/QuizMedia'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct MedalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: MedalItem = new MedalItem()
  onClose: () => void = () => {}
  onPlay: () => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(QuizMedia.cover(this.item.coverKey))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
          .opacity(ProgressStore.isMedalOn(this.item.id) ? 1 : 0.55)
        Column()
          .width('100%')
          .height(180)
          .linearGradient({
            angle: 180,
            colors: [['rgba(30,42,58,0.05)', 0], ['rgba(30,42,58,0.72)', 1]]
          })
        Column({ space: 6 }) {
          Text(ProgressStore.isMedalOn(this.item.id) ? '已点亮' : '待点亮')
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
        Text(this.item.subtitle)
          .fontSize(14)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
          .fontSize(16)
          .lineHeight(26)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(`达成条件：${this.item.rule}`)
          .fontSize(14)
          .lineHeight(22)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(18)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(22)
      .width('100%')

      AppButton({
        label: ProgressStore.isMedalOn(this.item.id) ? '继续挑战' : '去完成一题',
        onTap: (): void => { this.onPlay() }
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
