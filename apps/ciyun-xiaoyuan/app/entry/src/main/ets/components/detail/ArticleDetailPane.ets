import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { CourtyardMedia } from '../../services/CourtyardMedia'
import { CourtyardBizService } from '../../services/CourtyardBizService'
import { CourtyardDetailNav } from '../../services/CourtyardDetailNav'
import { ArticleItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct ArticleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop articleId: string = ''
  @State item: ArticleItem = new ArticleItem()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await CourtyardBizService.findArticle(this.articleId)
    if (row !== undefined) {
      this.item = row
    }
  }

  build() {
    DetailShell({
      title: this.item.title.length > 0 ? this.item.title : '赏析',
      onClose: (): void => { this.onClose() }
    }) {
      Column({ space: Theme.space.s4 }) {
        Stack() {
          Image(CourtyardMedia.cover(this.item.coverKey.length > 0 ? this.item.coverKey : 'cover_article_1'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
          Column() {
            Text(this.item.category)
              .fontSize(Theme.type.caption)
              .fontColor('#F5F0E8')
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .linearGradient({
            angle: 180,
            colors: [['rgba(44,24,16,0)', 0], ['rgba(44,24,16,0.86)', 1]]
          })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignContent(Alignment.BottomStart)
        .clip(true)
        .borderRadius(Theme.radius.md)

        AppCard({ title: '导读' }) {
          Text(this.item.summary)
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        Text(this.item.body)
          .fontSize(Theme.type.bodyM)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
        AppButton({
          label: '去读今日一诗',
          onTap: (): void => {
            AppStorage.setOrCreate('switchTab', 0)
            CourtyardDetailNav.close()
          }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
