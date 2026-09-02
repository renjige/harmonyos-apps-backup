import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { ZhiweiNav } from '../../services/ZhiweiNav'
import { ZhiweiStore } from '../../services/ZhiweiStore'

@Component
export struct QuickActionGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State reviewDue: number = 0

  aboutToAppear(): void {
    this.reviewDue = ZhiweiStore.reviewDueCount()
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        this.Item('记知识', 'add', (): void => ZhiweiNav.openCompose('', false))
        this.Item('口述', 'mic', (): void => ZhiweiNav.openCompose('', true))
        this.Item(this.reviewDue > 0 ? `复习${this.reviewDue}` : '复习', 'refresh', (): void => ZhiweiNav.openReviewDeck())
        this.Item('待消化', 'flag', (): void => ZhiweiNav.openInbox())
      }
      .width('100%')
      Row({ space: 8 }) {
        this.Item('每日一知', 'book', (): void => ZhiweiNav.openDaily(''))
        this.Item('知识文库', 'biz', (): void => ZhiweiNav.openKnowledgeCatalog())
        this.Item('知识库', 'bookmark', (): void => ZhiweiNav.openLibrary())
        this.Item('收藏夹', 'star', (): void => ZhiweiNav.openFocus('fav', '', '知识收藏夹'))
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  Item(label: string, icon: AppIconName, tap: () => void) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).brandPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colorOf(this.themeEpoch).brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
    }
    .layoutWeight(1)
    .padding({ top: 6, bottom: 6 })
    .onClick(() => tap())
  }
}
