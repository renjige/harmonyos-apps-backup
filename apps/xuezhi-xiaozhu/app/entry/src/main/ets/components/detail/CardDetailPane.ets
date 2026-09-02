import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { CottageItem } from '../../models/CottageModels'
import { AuthService } from '../../services/AuthService'
import { CottageBizService } from '../../services/CottageBizService'
import { CottageMedia } from '../../services/CottageMedia'
import { CottageNav } from '../../services/CottageNav'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop entityId: string = ''
  @Prop kind: string = 'card'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State card: CottageItem = new CottageItem()
  @State loaded: boolean = false
  @State favorited: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (this.entityId.length === 0) {
      this.loaded = false
      return
    }
    let found: CottageItem | undefined = undefined
    if (this.kind === 'daily') {
      found = await CottageBizService.findDaily(this.entityId)
    } else {
      found = await CottageBizService.findCard(this.entityId)
      if (found === undefined) {
        found = await CottageBizService.findDaily(this.entityId)
      }
    }
    if (found === undefined) {
      this.loaded = false
      return
    }
    this.card = found
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    const favs = await CottageBizService.loadFavorites(uid)
    this.favorited = false
    for (const f of favs) {
      if (f.cardId === found.id) {
        this.favorited = true
        break
      }
    }
    this.loaded = true
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_card')) {
      this.onRequireAuth()
      return
    }
    const uid = AppStorage.get<string>('currentUsername') ?? ''
    if (this.favorited) {
      this.showToast('可在收藏夹取消收藏')
      return
    }
    const ok = await CottageBizService.addFavorite(uid, this.card)
    if (ok) {
      this.favorited = true
      CottageNav.bump()
      this.showToast('已收藏到知识库')
      return
    }
    this.showToast('收藏失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.kind === 'daily' ? '今日智慧' : '知识卡片',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { CottageNav.closeDetail() },
        onFavorite: (): void => { void this.toggleFav() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '内容不存在', description: '请返回后刷新重试' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(CottageMedia.resource(this.card.coverKey.length > 0 ?
                  this.card.coverKey : this.card.category))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(18,32,58,0.05)', 0.28], ['rgba(18,32,58,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.card.categoryLabel.length > 0 ? this.card.categoryLabel : '通识')
                    .fontSize(Theme.type.caption)
                    .fontColor('#F8FAFC')
                  Text(this.card.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F8FAFC')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.md)
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
                  label: this.favorited ? '已收藏' : '收藏这张卡片',
                  variant: this.favorited ? 'secondary' : 'primary',
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
