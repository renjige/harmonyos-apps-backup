import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AuthService } from '../../services/AuthService'
import { GearBizService } from '../../services/GearBizService'
import { GearDetailNav } from '../../services/GearDetailNav'
import { GearMedia } from '../../services/GearMedia'
import { CatalogItem } from '../../models/GearModels'
import { DetailShell } from './DetailShell'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await GearBizService.findNote(this.itemId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开手记' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '手记', onClose: () => GearDetailNav.close() }) {
        AppEmpty({ title: '手记不存在', actionLabel: '返回', onAction: () => GearDetailNav.close() })
      }
    } else {
      this.Body()
    }
  }

  @Builder
  Body() {
    DetailShell({ title: this.item !== undefined ? this.item.title : '手记', onClose: () => GearDetailNav.close() }) {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(GearMedia.resource(this.item !== undefined ? this.item.coverKey : 'note_ridge'))
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
          Text(this.item !== undefined && this.item.readMinutes > 0 ?
            `约 ${this.item.readMinutes} 分钟` : '山野手记')
            .fontSize(Theme.type.caption)
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

        Text(this.item !== undefined ? this.item.body : '')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: 10 }) {
          AppButton({
            label: '对照装备库',
            onTap: () => GearDetailNav.close()
          })
          AppButton({
            label: '出装检视',
            variant: 'secondary',
            onTap: (): void => {
              if (!AuthService.requireAuth('save_inspect')) {
                this.onRequireAuth()
                return
              }
              GearDetailNav.openInspect()
            }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
