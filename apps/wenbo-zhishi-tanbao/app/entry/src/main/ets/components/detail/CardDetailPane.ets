import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { TreasureCard } from '../../models/TreasureModels'
import { TreasureBizService } from '../../services/TreasureBizService'
import { TreasureNav } from '../../services/TreasureNav'
import { TreasureMedia } from '../../services/TreasureMedia'
import { VaultStore } from '../../services/VaultStore'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cardId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State card: TreasureCard = new TreasureCard()
  @State loaded: boolean = false
  @State favorited: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.cardId.length === 0) {
      this.loaded = false
      return
    }
    const found = await TreasureBizService.findCard(this.cardId)
    if (found !== undefined) {
      this.card = found
      this.favorited = VaultStore.isFavorite(found.id)
      this.loaded = true
    } else {
      this.loaded = false
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    await VaultStore.toggleFavorite(this.cardId)
    this.favorited = VaultStore.isFavorite(this.cardId)
    this.showToast(this.favorited ? '已收入宝库' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '智慧卡片',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { TreasureNav.closeDetail() },
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '卡片不存在', description: '请返回后刷新重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(TreasureMedia.resource(this.card.coverKey.length > 0 ?
                  this.card.coverKey : this.card.category))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,42,108,0.05)', 0.28], ['rgba(26,42,108,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.card.categoryLabel.length > 0 ? this.card.categoryLabel : '综合')
                    .fontSize(Theme.type.caption)
                    .fontColor('#F5F3F0')
                  Text(this.card.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F3F0')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column() {
                Text(this.card.summary.length > 0 ? this.card.summary : this.card.subtitle)
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

              Text(this.card.body.length > 0 ? this.card.body : this.card.description)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              if (this.card.tags.length > 0) {
                Text(this.card.tags)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
                  .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.favorited ? '取消收藏' : '收藏到宝库',
                  variant: 'primary',
                  onTap: (): void => { void this.toggleFav() }
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
