import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { DateFormatUtil } from '../design-system/DateFormatUtil'
import { WisdomItem } from '../../models/WisdomHallModels'
import { FavoriteLocalService } from '../../services/FavoriteLocalService'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

@Component
export struct FavoritesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('whRefresh') @Watch('onRefresh') whRefresh: number = 0
  onRequireAuth: () => void = () => {}
  @State items: WisdomItem[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async reload(): Promise<void> {
    this.items = await FavoriteLocalService.list()
  }

  private async removeItem(item: WisdomItem): Promise<void> {
    await FavoriteLocalService.remove(item.targetId.length > 0 ? item.targetId : item.id)
    this.showToast('已取消收藏')
    WisdomHallBizService.bumpRefresh()
    await this.reload()
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
          .onClick((): void => { WisdomHallNav.closeFavorites() })
          Text(`我的收藏 (${this.items.length})`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: 8 })

        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有收藏',
            description: '去发现智慧吧，点击语录卡片上的收藏即可保存',
            actionLabel: '去语录库',
            onAction: (): void => {
              WisdomHallNav.closeFavorites()
              WisdomHallNav.switchTab(1)
            }
          })
            .layoutWeight(1)
        } else {
          List({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: WisdomItem) => {
              ListItem() {
                Column({ space: 8 }) {
                  Text(`「${item.title}」`)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Row() {
                    Text(item.authorName.length > 0 ? `—— ${item.authorName}` : '')
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .layoutWeight(1)
                    Text(DateFormatUtil.formatDate(DateFormatUtil.parseDate(item.createdAt)))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textTertiary)
                  }
                  .width('100%')
                  Text('取消收藏')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick((): void => { void this.removeItem(item) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(16)
                .onClick((): void => {
                  const id = item.targetId.length > 0 ? item.targetId : item.id
                  WisdomHallNav.closeFavorites()
                  WisdomHallNav.openDetail('quote', id)
                })
              }
            }, (item: WisdomItem) => item.id + item.createdAt)
          }
          .layoutWeight(1)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
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
