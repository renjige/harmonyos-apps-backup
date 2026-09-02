import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TipItem } from '../../models/SolarModels'
import { SolarRecipesBizService } from '../../services/SolarRecipesBizService'
import { SolarDetailNav } from '../../services/SolarDetailNav'
import { SolarMedia } from '../../services/SolarMedia'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'

@Component
export struct TipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTipIdChange') tipId: string = ''
  @Prop @Watch('onTipIdChange') refreshToken: number = 0
  @State item: TipItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onTipIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const tips = await SolarRecipesBizService.loadTips()
    let found: TipItem | undefined = undefined
    for (const t of tips) {
      if (t.id === this.tipId) {
        found = t
      }
    }
    this.item = found
    this.loading = false
  }

  private current(): TipItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new TipItem()
  }

  build() {
    if (this.loading) {
      AppLoading({ label: '正在打开贴士' })
    } else if (this.item === undefined) {
      AppEmpty({ title: '贴士不存在', actionLabel: '返回', onAction: () => SolarDetailNav.close() })
    } else {
      DetailShell({
        title: this.current().title,
        contentKey: this.tipId,
        onClose: () => SolarDetailNav.close()
      }) {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(SolarMedia.resource(this.current().coverKey))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(80)
              .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#CC2C2420', 1]] })
            Text(this.current().title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
              .width('100%')
          }
          .clip(true)

          Column({ space: 8 }) {
            Text(this.current().solarTerm.length > 0
              ? `${CategoryEmojiUtil.markForSolarTerm(this.current().solarTerm)} ${this.current().solarTerm} · 食养贴士`
              : '💡 食养贴士')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(this.current().summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.current().body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          AppButton({
            label: '去食谱库看看',
            onTap: (): void => {
              SolarDetailNav.close()
              AppStorage.setOrCreate('switchTabIndex', 1)
            }
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
