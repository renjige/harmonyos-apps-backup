import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { GearBizService, ReadyResult } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearMedia } from '../../services/GearMedia'
import { CatalogItem, GearWriteRequest } from '../../models/GearModels'
import { DetailShell } from './DetailShell'

@Component
export struct TrailDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true
  @State ready: ReadyResult = new ReadyResult()
  @State favId: string = ''
  @State toastText: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await GearBizService.findTrail(this.itemId)
    const gear = await GearBizService.loadMine('gear')
    if (this.item !== undefined) {
      this.ready = GearBizService.readyForTrail(this.item, gear)
    }
    this.favId = ''
    const favs = await GearBizService.loadMine('favorites')
    for (const f of favs) {
      if (f.targetId === this.itemId) {
        this.favId = f.id
      }
    }
    this.loading = false
  }

  private async toggleFav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_trail')) {
      this.onRequireAuth()
      return
    }
    if (this.favId.length > 0) {
      const ok = await GearBizService.remove('favorites', this.favId)
      if (ok) {
        this.favId = ''
        this.toastText = '已取消收藏'
      }
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new GearWriteRequest()
    req.title = this.item.title
    req.targetKind = 'trail'
    req.targetId = this.itemId
    const ok = await GearBizService.create('favorites', req)
    if (ok) {
      this.toastText = '已收藏'
      await this.reload()
    }
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开路线' })
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
            Image(GearMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_ridge'))
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
            Text(this.item !== undefined ? this.item.subtitle : '')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(`起点 ${this.item !== undefined ? this.item.origin : ''} · 终点 ${this.item !== undefined ? this.item.dest : ''}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`途经 ${this.item !== undefined ? this.item.waypoints : ''}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(this.item !== undefined ? this.item.summary : '')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Column({ space: 8 }) {
            Text(`就绪度 ${this.ready.score}%`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`已覆盖 ${this.ready.covered}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Text(`缺口 ${this.ready.missing}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
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
              label: this.favId.length > 0 ? '取消收藏' : '收藏这条路线',
              onTap: (): void => { void this.toggleFav() }
            })
            AppButton({
              label: '录入缺件装备',
              variant: 'secondary',
              onTap: (): void => {
                if (!AuthService.requireAuth('manage_gear')) {
                  this.onRequireAuth()
                  return
                }
                GearDetailNav.openGearNew()
              }
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
