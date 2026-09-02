import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { SymbolHero } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { WisdomItem } from '../../models/WisdomHallModels'
import { FavoriteLocalService } from '../../services/FavoriteLocalService'
import { ReadTodayService } from '../../services/ReadTodayService'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct QuoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: WisdomItem = new WisdomItem()
  @State loaded: boolean = false
  @State favorited: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    const found = await WisdomHallBizService.findQuote(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      this.favorited = await FavoriteLocalService.isFavorited(found.id)
      await ReadTodayService.markReadToday()
    }
  }

  private async toggleFavorite(): Promise<void> {
    if (this.favorited) {
      await FavoriteLocalService.remove(this.item.id)
      this.favorited = false
      this.showToast('已取消收藏')
    } else {
      await FavoriteLocalService.add(this.item)
      this.favorited = true
      this.showToast('已加入收藏')
    }
    WisdomHallBizService.bumpRefresh()
  }

  private shareQuote(): void {
    const author = this.item.authorName.length > 0 ? `—— ${this.item.authorName}` : ''
    const text = `「${this.item.title}」\n${author}\n\n来自「知语集」`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.showToast('语录已复制，可粘贴分享')
    } catch {
      this.showToast('分享失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { WisdomHallNav.closeDetail() })
          Text('语录详情')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

        if (!this.loaded) {
          AppEmpty({ title: '语录不存在', description: '' })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              SymbolHero({
                category: this.item.category,
                coverKey: this.item.coverKey,
                bannerHeight: 260,
                overline: CategoryEmojiUtil.chipLabel(this.item.category),
                title: `「${this.item.title}」`,
                subtitle: this.item.authorName.length > 0 ? `—— ${this.item.authorName}` : ''
              })
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                AppCard({ title: '摘要' }) {
                  Text(this.item.summary.length > 0 ? this.item.summary : this.item.body)
                    .fontSize(Theme.type.bodyL)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .lineHeight(28)
                }
              }
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              if (this.item.description.length > 0 && this.item.description !== this.item.summary) {
                Text(this.item.description)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }

              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '取消收藏' : '收藏语录',
                  variant: this.favorited ? 'secondary' : 'primary',
                  onTap: (): void => { void this.toggleFavorite() }
                })
                  .layoutWeight(1)
                AppButton({
                  label: '分享',
                  variant: 'secondary',
                  onTap: (): void => { this.shareQuote() }
                })
                  .layoutWeight(1)
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s10
              })
            }
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
