import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WisdomItem, WisdomMapper } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { WisdomMedia } from '../../services/WisdomMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct FeaturedDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: WisdomItem = new WisdomItem()
  @State loaded: boolean = false
  @State toastText: string = ''
  @State liked: boolean = false
  @State favorited: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await WisdomHallBizService.findFeatured(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async like(): Promise<void> {
    if (!AuthService.requireAuth('like_featured')) {
      this.onRequireAuth()
      return
    }
    const res = await WisdomHallBizService.likeFeatured(this.itemId)
    if (res !== undefined) {
      this.item = WisdomMapper.fromWire(res.row)
      this.liked = res.liked
      this.showToast(res.liked ? '已点赞' : '已记录')
    } else {
      this.showToast('点赞失败，请先登录')
    }
  }

  private async favorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    const ok = await WisdomHallBizService.addFavorite('featured', this.itemId, this.item.title)
    if (ok) {
      this.favorited = true
      this.showToast('已收藏')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '精选思考',
        showFavorite: true,
        favorited: this.favorited,
        onClose: (): void => { WisdomHallNav.closeDetail() },
        onFavorite: (): void => { void this.favorite() }
      }) {
        if (!this.loaded) {
          AppEmpty({ title: '精选内容不存在', description: '' })
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WisdomMedia.resource(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(220)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0)', 0.28], ['rgba(26,26,46,0.78)', 1]]
                  })
                Column({ space: 6 }) {
                  Text(this.item.authorName.length > 0 ? this.item.authorName : '思友')
                    .fontSize(Theme.type.caption)
                    .fontColor('#C9A84C')
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F0E8')
                    .maxLines(3)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
              }
              .width('100%')
              .borderRadius(Theme.radius.card)
              .clip(true)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(`${this.item.likeCount} 赞`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Text(this.item.body)
                .fontSize(Theme.type.bodyL)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(28)
                .width('100%')
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

              Column({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.liked ? '已点赞' : '点赞',
                  variant: 'primary',
                  onTap: (): void => { void this.like() }
                })
                AppButton({
                  label: this.favorited ? '已收藏' : '收藏',
                  variant: 'secondary',
                  onTap: (): void => { void this.favorite() }
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
