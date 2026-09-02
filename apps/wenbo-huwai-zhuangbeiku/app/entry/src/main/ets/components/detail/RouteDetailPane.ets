import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { GearBizService, ReadyResult } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearMedia } from '../../services/GearMedia'
import { CatalogItem } from '../../models/GearModels'
import { DetailShell } from './DetailShell'

@Component
export struct RouteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true
  @State ready: ReadyResult = new ReadyResult()
  @State confirmRemove: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await GearBizService.findMine('routes', this.itemId)
    const gear = await GearBizService.loadMine('gear')
    if (this.item !== undefined) {
      this.ready = GearBizService.readyForTrail(this.item, gear)
    }
    this.loading = false
  }

  private async removeMine(): Promise<void> {
    if (!this.confirmRemove) {
      this.confirmRemove = true
      this.toastText = '再点一次确认删除这条自建路线'
      return
    }
    const ok = await GearBizService.remove('routes', this.itemId)
    if (ok) {
      GearDetailNav.close()
      return
    }
    this.toastText = '删除失败，请稍后重试'
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开自建路线' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '路线', onClose: () => GearDetailNav.close() }) {
        AppEmpty({ title: '路线不存在', actionLabel: '返回', onAction: () => GearDetailNav.close() })
      }
    } else {
      this.Body()
    }
  }

  @Builder
  Body() {
    Stack() {
      DetailShell({ title: this.item !== undefined ? this.item.title : '路线', onClose: () => GearDetailNav.close() }) {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(GearMedia.resource(this.item !== undefined && this.item.coverKey.length > 0 ?
              this.item.coverKey : 'hero_ridge'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,26,0)', 0.0], ['rgba(26,26,26,0.82)', 1.0]]
              })
            Text(this.item !== undefined ? this.item.title : '')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F5F5F5')
              .padding(16)
          }
          .width('100%')
          .height(220)
          .clip(true)
          .borderRadius(Theme.radius.card)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: 8 }) {
            Text(this.item !== undefined ? this.item.summary : '')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`起点 ${this.item !== undefined ? this.item.origin : ''} · 终点 ${this.item !== undefined ? this.item.dest : ''}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`途经 ${this.item !== undefined ? this.item.waypoints : ''}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`就绪度 ${this.ready.score}% · 缺口 ${this.ready.missing}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Text(this.item !== undefined ? this.item.body : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: 10 }) {
            AppButton({
              label: '录入缺件装备',
              onTap: () => GearDetailNav.openGearNew()
            })
            AppButton({
              label: this.confirmRemove ? '再点一次确认删除' : '删除这条路线',
              variant: 'secondary',
              onTap: (): void => { void this.removeMine() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(10)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
  }
}
