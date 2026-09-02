import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TermItem } from '../../models/SolarModels'
import { SolarRecipesBizService } from '../../services/SolarRecipesBizService'
import { SolarDetailNav } from '../../services/SolarDetailNav'
import { SolarMedia } from '../../services/SolarMedia'
import { SolarTermUtil } from '../../services/SolarTermUtil'

@Component
export struct TermDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTermIdChange') termId: string = ''
  @Prop @Watch('onTermIdChange') refreshToken: number = 0
  @State item: TermItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onTermIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await SolarRecipesBizService.findTerm(this.termId)
    this.loading = false
  }

  private current(): TermItem {
    if (this.item !== undefined) {
      return this.item
    }
    return new TermItem()
  }

  build() {
    if (this.loading) {
      AppLoading({ label: '正在打开节气' })
    } else if (this.item === undefined) {
      AppEmpty({ title: '节气不存在', actionLabel: '返回', onAction: () => SolarDetailNav.close() })
    } else {
      DetailShell({
        title: this.current().title,
        contentKey: this.termId,
        onClose: () => SolarDetailNav.close()
      }) {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(SolarMedia.resource(this.current().coverKey))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(96)
              .linearGradient({ direction: GradientDirection.Bottom, colors: [['#00000000', 0], ['#CC2C2420', 1]] })
            Column({ space: 4 }) {
              if (SolarTermUtil.isCurrentTerm(this.termId)) {
                Text('当前节气')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor(Theme.colors().brandPrimary)
                  .borderRadius(Theme.radius.pill)
              }
              Text(this.current().title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.current().dateRange)
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s4 })
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .clip(true)

          Column({ space: 8 }) {
            Text(`「${this.current().poem}」`)
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().brandAccent)
              .fontStyle(FontStyle.Italic)
            Text(this.current().summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.current().body)
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Column({ space: 8 }) {
            Text('当季食材')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.current().seasonalFoods.join(' · '))
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          AppButton({
            label: '查看本节气食谱',
            onTap: (): void => {
              SolarDetailNav.close()
              AppStorage.setOrCreate('librarySolarTermId', this.termId)
              AppStorage.setOrCreate('switchTabIndex', 1)
            }
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .width('100%')
      }
    }
  }
}
