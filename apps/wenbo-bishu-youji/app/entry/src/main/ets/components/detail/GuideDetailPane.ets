import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { GuideItem } from '../../models/EscapeModels'
import { EscapeBizService } from '../../services/EscapeBizService'
import { EscapeDetailNav } from '../../services/EscapeDetailNav'
import { EscapeMedia } from '../../services/EscapeMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct GuideDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  @State item: GuideItem | undefined = undefined
  @State loading: boolean = true
  @State favored: boolean = false
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onItemIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await EscapeBizService.findGuide(this.itemId)
    this.favored = await EscapeBizService.isFavored(this.itemId)
    this.loading = false
  }

  private current(): GuideItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new GuideItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    const g = this.current()
    this.favored = await EscapeBizService.toggleFavorite('guide', g.id, g.title, g.coverKey)
    this.showToast(this.favored ? '已收藏这篇内容' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开这篇文字' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '灵感', onClose: () => EscapeDetailNav.close() }) {
          AppEmpty({ title: '文章还在路上', actionLabel: '重试', onAction: () => { void this.reload() } })
        }
      } else {
        DetailShell({ title: this.current().kindLabel(), contentKey: this.current().id, onClose: () => EscapeDetailNav.close() }) {
          this.Body()
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(EscapeMedia.resource(this.current().coverKey))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(110)
          .linearGradient({
            angle: 180,
            colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.72)', 1]]
          })
        Text(this.current().title)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor('#F8FAFC')
          .padding(16)
      }
      .width('100%')
      .height(220)
      .borderRadius(Theme.radius.lg)
      .clip(true)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: 8 }) {
        Text(`${this.current().kindLabel()} · ${this.current().readMinutes} 分钟 · ${this.current().publishedAt}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.current().summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding(16)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(Theme.colors().surfaceGlass)
      .borderRadius(Theme.radius.md)
      .alignItems(HorizontalAlign.Start)

      Text(this.current().body)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')

      Column() {
        AppButton({
          label: this.favored ? '取消收藏' : '收藏这篇',
          variant: 'secondary',
          onTap: (): void => { void this.toggleFav() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
  }
}
