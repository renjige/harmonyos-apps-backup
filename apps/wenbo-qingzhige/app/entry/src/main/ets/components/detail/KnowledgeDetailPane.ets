import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { KnowledgeItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'
import { KnowledgeMedia } from '../../services/KnowledgeMedia'

@Component
export struct KnowledgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: KnowledgeItem = new KnowledgeItem()
  @State toastText: string = ''
  @State loaded: boolean = false

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    const found = KnowledgeStore.find(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
      void KnowledgeStore.markRead(this.itemId)
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    await KnowledgeStore.toggleFavorite(this.itemId)
    this.reload()
    this.showToast(this.item.favorited ? '已轻轻收好' : '已取消收藏')
  }

  private async addReview(): Promise<void> {
    await KnowledgeStore.addToReview(this.itemId)
    this.reload()
    this.showToast('已加入今日复习')
  }

  private recordSimilar(): void {
    KnowledgeNav.closeDetail()
    KnowledgeNav.openWrite('')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '轻知',
        showFavorite: true,
        favorited: this.item.favorited,
        onClose: (): void => { KnowledgeNav.closeDetail() },
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '这条轻知不在了', description: '它可能已被删除。' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(KnowledgeMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(18,42,54,0)', 0.32], ['rgba(18,42,54,0.72)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.category)
                    .fontSize(Theme.type.caption)
                    .fontColor('#F6F1EA')
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F6F1EA')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.item.summaryLine())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              if (this.item.tags.length > 0) {
                Text(this.item.tags)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.item.favorited ? '取消收藏' : '收藏',
                  variant: 'primary',
                  onTap: (): void => { void this.toggleFav() }
                })
                AppButton({
                  label: '记录相似内容',
                  variant: 'secondary',
                  onTap: (): void => { this.recordSimilar() }
                })
                AppButton({
                  label: this.item.inReview ? '已在复习队列' : '加入复习',
                  variant: 'ghost',
                  onTap: (): void => { void this.addReview() }
                })
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

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
