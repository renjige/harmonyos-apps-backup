import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { StopItem } from '../../models/CoolModels'
import { CoolBizService } from '../../services/CoolBizService'
import { CoolDetailNav } from '../../services/CoolDetailNav'
import { CoolMedia } from '../../services/CoolMedia'
import { AuthService } from '../../services/AuthService'

@Component
export struct StopDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onStopIdChange') stopId: string = ''
  @Prop @Watch('onStopIdChange') refreshToken: number = 0
  @State item: StopItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  onNeedLogin: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onStopIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CoolBizService.findStop(this.stopId)
    this.loading = false
  }

  private async fav(): Promise<void> {
    if (!AuthService.requireAuth('favorite_place')) {
      this.onNeedLogin()
      return
    }
    if (this.item === undefined) {
      return
    }
    const ok = await CoolBizService.addFavorite(this.item.title, 'stop', this.item.id)
    this.toastText = ok ? '已收藏这个休息点' : '收藏失败，请稍后重试'
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private openRelated(): void {
    if (this.item === undefined || this.item.relatedRouteIds.length === 0) {
      CoolDetailNav.switchTabRoutes()
      CoolDetailNav.close()
      return
    }
    const parts = this.item.relatedRouteIds.split(',')
    let first = ''
    for (const p of parts) {
      if (p.length > 0 && first.length === 0) {
        first = p
      }
    }
    if (first.length > 0) {
      CoolDetailNav.openRoute(first)
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.loading) {
        Column() { AppLoading({ label: '打开休息点' }) }
          .width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else if (this.item === undefined) {
        DetailShell({ title: '休息点', onClose: () => CoolDetailNav.close() }) {
          AppEmpty({ title: '休息点不存在' })
        }
      } else {
        DetailShell({ title: this.item.title, contentKey: this.stopId, onClose: () => CoolDetailNav.close() }) {
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
        Image(CoolMedia.resource(this.item !== undefined ? this.item.coverKey : 'stop_mall'))
          .width('100%').height(200).objectFit(ImageFit.Cover)
        Column()
          .width('100%').height(96)
          .linearGradient({
            angle: 180,
            colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.82)', 1]]
          })
        Column({ space: 4 }) {
          Text(this.item !== undefined ? this.item.title : '')
            .fontSize(Theme.type.title2).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          Text(this.item !== undefined ? this.item.address : '')
            .fontSize(Theme.type.footnote).fontColor('#E8FBFF')
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 16 })
      }
      .width('100%').height(200)

      Column({ space: 8 }) {
        Text(`${this.item !== undefined ? this.item.typeLabel() : ''} · 清凉 ${this.item !== undefined ? this.item.coolScore : 0}`)
          .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
        Text(this.item !== undefined ? this.item.summary : '')
          .fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.footnote).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        AppButton({ label: '查看相关清凉路线', onTap: (): void => this.openRelated() })
        AppButton({ label: '收藏休息点', variant: 'secondary', onTap: (): void => { void this.fav() } })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
  }
}
