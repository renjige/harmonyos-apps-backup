import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationItem } from '../models/WanderModels'
import { WanderBizService } from '../services/WanderBizService'
import { WanderDetailNav } from '../services/WanderDetailNav'
import { WanderLocalStore } from '../services/WanderLocalStore'
import { WanderMedia } from '../services/WanderMedia'

@Component
export struct InspirationPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State items: InspirationItem[] = []
  @State index: number = 0
  @State favorited: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await WanderBizService.loadInspirations()
    this.index = InspirationPage.dayIndex(this.items.length)
    await this.syncFavorite()
    this.loading = false
  }

  private static dayIndex(len: number): number {
    if (len <= 0) {
      return 0
    }
    const d = new Date()
    return (d.getDate() + d.getMonth() * 31) % len
  }

  private current(): InspirationItem | undefined {
    if (this.items.length === 0 || this.index < 0 || this.index >= this.items.length) {
      return undefined
    }
    return this.items[this.index]
  }

  private async syncFavorite(): Promise<void> {
    const cur = this.current()
    if (cur === undefined) {
      this.favorited = false
      return
    }
    this.favorited = await WanderLocalStore.isInspirationFavorited(cur.id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async toggleFavorite(): Promise<void> {
    const cur = this.current()
    if (cur === undefined) {
      return
    }
    if (this.favorited) {
      await WanderLocalStore.removeInspirationFavorite(cur.id)
      this.favorited = false
      WanderLocalStore.notifyDataChanged()
      this.showToast('已取消收藏')
      return
    }
    await WanderLocalStore.addInspirationFavorite(cur.id)
    this.favorited = true
    WanderLocalStore.notifyDataChanged()
    this.showToast('已收藏灵感')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('今日漫游灵感')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text(new Date().toLocaleDateString('zh-CN'))
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 8 })

        if (this.loading) {
          AppLoading({ label: '灵感正在路上' }).layoutWeight(1)
        } else if (this.current() === undefined) {
          AppEmpty({
            title: '暂无灵感',
            description: '稍后再来看看',
            actionLabel: '刷新',
            onAction: (): void => { void this.reload() }
          }).layoutWeight(1)
        } else {
          Swiper() {
            ForEach(this.items, (it: InspirationItem) => {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(WanderMedia.resource(it.coverKey))
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height('55%')
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(45,52,54,0)', 0.1], ['rgba(45,52,54,0.88)', 1]]
                  })
                Column({ space: 10 }) {
                  Text(it.title)
                    .fontSize(Theme.type.title1)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .width('100%')
                  Text(it.subtitle)
                    .fontSize(Theme.type.body)
                    .fontColor('#FFFFFF')
                    .width('100%')
                  if (it.body.length > 0) {
                    Text(it.body)
                      .fontSize(Theme.type.subhead)
                      .fontColor('#FFFFFF')
                      .width('100%')
                      .maxLines(4)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  Text('按季节主题推荐')
                    .fontSize(Theme.type.caption)
                    .fontColor('rgba(255,255,255,0.85)')
                }
                .padding(24)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .height('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)
              .onClick(() => WanderDetailNav.openInspiration(it.id))
            }, (it: InspirationItem) => it.id)
          }
          .index(this.index)
          .indicator(true)
          .loop(false)
          .duration(320)
          .itemSpace(12)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .layoutWeight(1)
          .onChange((i: number) => {
            this.index = i
            void this.syncFavorite()
          })

          Row({ space: 16 }) {
            Column() {
              AppIcon({
                name: 'check',
                iconSize: Theme.icon.md,
                color: this.favorited ? Theme.colors().brandAccent : Theme.colors().textPrimary
              })
            }
            .width(48)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.toggleFavorite() })

            Text(this.favorited ? '已收藏' : '收藏灵感')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)

            Text('左右滑动浏览')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 12, bottom: 16 })
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
          .backgroundColor(Theme.colors().overlayScrim)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
