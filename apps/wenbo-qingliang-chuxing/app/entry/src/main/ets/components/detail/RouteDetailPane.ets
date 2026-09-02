import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { RouteItem, RouteNode, StopItem } from '../../models/CoolModels'
import { CoolBizService } from '../../services/CoolBizService'
import { CoolDetailNav } from '../../services/CoolDetailNav'
import { CoolMedia } from '../../services/CoolMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct RouteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRouteIdChange') routeId: string = ''
  @Prop @Watch('onRouteIdChange') refreshToken: number = 0
  @State item: RouteItem | undefined = undefined
  @State stops: StopItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  onNeedLogin: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRouteIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolBizService.findRoute(this.routeId)
    this.stops = []
    if (this.item !== undefined && this.item.restStopIds.length > 0) {
      const ids = this.item.restStopIds.split(',')
      const all = await CoolBizService.loadStops(this.item.cityId)
      const picked: StopItem[] = []
      for (const s of all) {
        for (const id of ids) {
          if (s.id === id) {
            picked.push(s)
          }
        }
      }
      this.stops = picked
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async fav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_place')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await CoolBizService.addFavorite(this.item.title, 'route', this.item.id)
    this.showToast(ok ? '已收藏这条清凉路线' : '收藏失败，请稍后重试')
  }

  private async plan(): Promise<void> {
    if (!AuthService.requireAuth('save_plan')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await CoolBizService.savePlan(this.item)
    this.showToast(ok ? '已保存到我的规划' : '保存失败，请稍后重试')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() {
          AppLoading({ label: '展开路线' })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '路线', onClose: () => CoolDetailNav.close() }) {
          AppEmpty({ title: '路线不存在', description: '请返回列表重试' })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.routeId, onClose: () => CoolDetailNav.close() }) {
          this.Body()
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CoolMedia.resource(this.item !== undefined ? this.item.coverKey : 'hero_city_shade'))
          .width('100%')
          .height(220)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(110)
          .linearGradient({
            angle: 180,
            colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.82)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.item !== undefined ? `${this.item.origin} → ${this.item.dest}` : '')
            .fontSize(Theme.type.footnote)
            .fontColor('#E8FBFF')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%')
      .height(220)

      Column({ space: 8 }) {
        Text(`${this.item !== undefined ? this.item.modeLabel() : ''} · ${this.item !== undefined ? this.item.durationMin : 0} 分钟 · 树荫 ${this.item !== undefined ? this.item.shadeRate : 0}% · 室内 ${this.item !== undefined ? this.item.indoorShare : 0}%`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(`清凉指数 ${this.item !== undefined ? this.item.coolIndex : 0}`)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width('100%')
        Text(this.item !== undefined ? this.item.summary : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      Column({ space: 8 }) {
        Text('路线说明')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding(Theme.space.s4)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .width('auto')

      Column({ space: Theme.space.s3 }) {
        Text('途经节点')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        ForEach(this.item !== undefined ? this.item.nodes : [], (n: RouteNode, idx: number) => {
          Column({ space: 4 }) {
            Text(`${n.minute}  ·  ${n.title}`)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(n.note)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
        }, (n: RouteNode, idx: number) => `n-${idx}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')

      if (this.stops.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('沿途休息点')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.stops, (s: StopItem) => {
            Row() {
              Text(`${s.title}  ·  ${s.typeLabel()}`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick(() => CoolDetailNav.openStop(s.id))
          }, (s: StopItem) => s.id)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }

      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '收藏这条路线', onTap: (): void => { void this.fav() } })
        AppButton({ label: '保存为我的规划', variant: 'secondary', onTap: (): void => { void this.plan() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      .width('100%')
    }
    .width('100%')
  }
}
