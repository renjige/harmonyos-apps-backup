import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CatalogItem } from '../../models/CampModels'
import { DetailShell } from './DetailShell'

@Component
export struct TripDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findTrip(this.itemId)
    this.loading = false
  }

  private async remove(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const ok = await CampBizService.remove('trips', this.item.id)
    if (ok) {
      CampDetailNav.close()
    }
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开行程' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.item === undefined) {
      DetailShell({ title: '行程', onClose: () => CampDetailNav.close() }) {
        AppEmpty({ title: '行程不存在', actionLabel: '返回', onAction: () => CampDetailNav.close() })
      }
    } else {
      DetailShell({ title: this.item.title, onClose: () => CampDetailNav.close() }) {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_camp_night'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(90)
              .linearGradient({
                angle: 180,
                colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.8)', 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F5F0E8')
              .padding(16)
              .width('100%')
          }
          .width('100%')
          .height(180)
          .clip(true)
          .borderRadius(Theme.radius.card)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: 8 }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`${this.item.people} 人 · ${this.item.days} 夜 · ${this.item.startAt.length > 0 ? this.item.startAt.slice(0, 10) : '日期待定'}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
          }
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          AppButton({
            label: '生成打包清单',
            onTap: () => CampDetailNav.openPackNew(this.itemId)
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          AppButton({
            label: '打开装备库',
            variant: 'secondary',
            onTap: () => CampDetailNav.openGear()
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          AppButton({
            label: '删除行程',
            variant: 'danger',
            onTap: () => { void this.remove() }
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
