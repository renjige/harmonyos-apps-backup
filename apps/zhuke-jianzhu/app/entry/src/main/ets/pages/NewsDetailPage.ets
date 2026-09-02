import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { ContentCover } from '../components/common/ContentCover'
import { ContentService } from '../services/ContentService'
import { UserPrefsService } from '../services/UserPrefsService'
import { NewsItem } from '../models/ZhukeModels'

@Component
export struct NewsDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop newsId: string = ''
  @State item: NewsItem = new NewsItem()
  @State favorited: boolean = false
  onBack: () => void = () => {}

  aboutToAppear(): void {
    const found = ContentService.newsById(this.newsId)
    if (found !== null) {
      this.item = found
      UserPrefsService.addHistory('news', found.id, found.title)
      this.favorited = UserPrefsService.isFavorite('news', found.id)
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '资讯详情', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ContentCover({
            imageKey: this.item.coverKey,
            coverHeight: 160,
            coverRadius: Theme.radius.lg,
            showGradient: false
          })

          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row() {
            Text(ContentService.newsCategoryLabel(this.item.category))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({
                left: Theme.space.s2,
                right: Theme.space.s2,
                top: 2,
                bottom: 2
              })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
            Text(this.item.publishedAt)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .margin({ left: Theme.space.s3 })
          }
          .width('100%')

          AppCard({ title: '正文' }) {
            Text(this.item.content)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(26)
          }

          AppButton({
            label: this.favorited ? '已收藏' : '收藏资讯',
            variant: this.favorited ? 'secondary' : 'primary',
            onTap: () => {
              this.favorited = UserPrefsService.toggleFavorite('news', this.item.id, this.item.title)
            }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
