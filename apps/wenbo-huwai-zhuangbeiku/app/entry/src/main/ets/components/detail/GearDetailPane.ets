import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearMedia } from '../../services/GearMedia'
import { CatalogItem } from '../../models/GearModels'
import { DetailShell } from './DetailShell'

@Component
export struct GearDetailPane {
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
    this.item = await GearBizService.findMine('gear', this.itemId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开装备' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '装备', onClose: () => GearDetailNav.close() }) {
        AppEmpty({ title: '装备不存在', actionLabel: '返回', onAction: () => GearDetailNav.close() })
      }
    } else {
      this.Body()
    }
  }

  @Builder
  Body() {
    DetailShell({ title: this.item !== undefined ? this.item.title : '装备', onClose: () => GearDetailNav.close() }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GearMedia.resource(this.item !== undefined && this.item.coverKey.length > 0 ? this.item.coverKey : 'gear_pack'))
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
          Text(`${this.item !== undefined ? this.item.category : ''} · ${this.item !== undefined ? this.item.weightKgText() : ''}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.item !== undefined ? this.item.summary : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(`品牌 ${this.item !== undefined && this.item.brand.length > 0 ? this.item.brand : '未填'} · 型号 ${this.item !== undefined && this.item.model.length > 0 ? this.item.model : '未填'}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(`购入 ${this.item !== undefined && this.item.boughtAt.length > 0 ? this.item.boughtAt : '未填'} · 使用 ${this.item !== undefined ? this.item.useCount : 0} 次 · 成色 ${this.item !== undefined && this.item.condition.length > 0 ? this.item.condition : '未评'}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)

        Text(this.item !== undefined && this.item.body.length > 0 ? this.item.body : (this.item !== undefined ? this.item.remark : ''))
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 10 }) {
          AppButton({
            label: '编辑这件装备',
            onTap: () => GearDetailNav.openGearEdit(this.itemId)
          })
          AppButton({
            label: '去对照路线',
            variant: 'secondary',
            onTap: () => GearDetailNav.close()
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
