import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { InspItem } from '../../models/ScenicModels'
import { ScenicBizService } from '../../services/ScenicBizService'
import { ScenicDetailNav } from '../../services/ScenicDetailNav'
import { ScenicMedia } from '../../services/ScenicMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct InspDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  @State item: InspItem | undefined = undefined
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
    this.item = await ScenicBizService.findInsp(this.itemId)
    this.favored = await ScenicBizService.isFavored(this.itemId)
    this.loading = false
  }

  private current(): InspItem {
    return this.item !== undefined ? this.item : new InspItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    const g = this.current()
    this.favored = await ScenicBizService.toggleFavorite('inspiration', g.id, g.title, g.coverKey)
    this.showToast(this.favored ? '已收藏' : '已取消收藏')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开这篇灵感' })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '灵感', onClose: () => ScenicDetailNav.close() }) {
          AppEmpty({ title: '文章还在路上', actionLabel: '重试', onAction: () => { void this.reload() } })
        }
      } else {
        DetailShell({ title: '旅行灵感', contentKey: this.current().id, onClose: () => ScenicDetailNav.close() }) {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(ScenicMedia.resource(this.current().coverKey))
                .width('100%').height(220).objectFit(ImageFit.Cover)
              Column().width('100%').height(100).linearGradient({
                angle: 180,
                colors: [['rgba(15,23,42,0)', 0], ['rgba(27,58,92,0.75)', 1]]
              })
              Text(this.current().title)
                .fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor('#F8FAFC')
                .padding(16)
            }
            .width('100%').height(220).borderRadius(Theme.radius.lg).clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: 8 }) {
              Text(`${this.current().sourceLabel} · ${this.current().destName}`)
                .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
              Text(this.current().summary)
                .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
            }
            .padding(16).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(Theme.radius.md)

            Text(this.current().body)
              .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: 10 }) {
              if (this.current().destId.length > 0) {
                AppButton({
                  label: '查看相关目的地',
                  onTap: (): void => { ScenicDetailNav.openDest(this.current().destId) }
                })
              }
              AppButton({
                label: this.favored ? '取消收藏' : '收藏这篇灵感',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFav() }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
        }
      }
      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText).fontSize(Theme.type.footnote).fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary).borderRadius(Theme.radius.pill)
        }.width('100%').padding({ top: Theme.space.s6 }).alignItems(HorizontalAlign.Center).zIndex(30)
      }
    }
    .width('100%').height('100%')
  }
}
