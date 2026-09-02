import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { KnowledgeArticle } from '../../models/JujiaModels'

@Component
export struct GuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop article: KnowledgeArticle = new KnowledgeArticle()
  onClose: () => void = () => {}

  build() {
    DetailShell({
      title: this.article.title,
      onClose: (): void => { this.onClose() },
      body: (): void => { this.BodyContent() }
    })
  }

  @Builder
  BodyContent() {
    Scroll() {
      Column({ space: 12 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.home_hero'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
          Column({ space: 4 }) {
            Text(this.article.category)
              .fontSize(Theme.type.caption)
              .fontColor('#FFF8F5')
              .width('100%')
            Text(this.article.title)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFF8F5')
              .width('100%')
          }
          .width('100%')
          .padding(16)
          .linearGradient({
            angle: 180,
            colors: [['rgba(26,58,92,0)', 0], ['rgba(26,58,92,0.88)', 1]]
          })
        }
        .width('100%')
        .borderRadius(Theme.radius.xl)
        .clip(true)

        Text(this.article.summary)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.article.body)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .lineHeight(22)

        Row() {
          AppButton({
            label: '返回发现',
            variant: 'primary',
            onTap: (): void => { this.onClose() }
          })
        }
        .width('100%')
        .onClick((): void => { this.onClose() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }
}
