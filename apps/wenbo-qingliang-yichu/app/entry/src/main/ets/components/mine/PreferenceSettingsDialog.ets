import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { WardrobeMedia } from '../../services/WardrobeMedia'

@Component
export struct PreferenceSettingsDialog {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSave: (season: string, style: string, scene: string) => void = () => {}

  @State defaultSeason: string = '夏季'
  @State defaultStyle: string = '清爽'
  @State defaultScene: string = '日常'

  aboutToAppear(): void {
    this.defaultSeason = AppStorage.get<string>('pref_default_season') ?? '夏季'
    this.defaultStyle = AppStorage.get<string>('pref_default_style') ?? '清爽'
    this.defaultScene = AppStorage.get<string>('pref_default_scene') ?? '日常'
  }

  private handleSave(): void {
    AppStorage.setOrCreate('pref_default_season', this.defaultSeason)
    AppStorage.setOrCreate('pref_default_style', this.defaultStyle)
    AppStorage.setOrCreate('pref_default_scene', this.defaultScene)
    this.onSave(this.defaultSeason, this.defaultStyle, this.defaultScene)
    this.onClose()
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // Background mask
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfaceMask)
        .onClick(() => this.onClose())

      // Sheet
      Column() {
        // Header
        Row() {
          Column() {
            Text('穿搭偏好设置')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

            Text('设定你的常驻季节与风格倾向，穿搭推荐更精准贴心')
              .fontSize(Theme.type.caption1)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .padding(8)
          .onClick(() => this.onClose())
        }
        .width('100%')
        .margin({ bottom: Theme.space.s4 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            // Default Season
            Column({ space: 6 }) {
              Text('常驻季节')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.SEASONS, (s: string) => {
                  Text(s)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.defaultSeason === s ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(this.defaultSeason === s ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.defaultSeason = s })
                }, (s: string) => s)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // Default Style
            Column({ space: 6 }) {
              Text('首选穿搭风格')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.STYLES, (st: string) => {
                  Text(st)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.defaultStyle === st ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(this.defaultStyle === st ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.defaultStyle = st })
                }, (st: string) => st)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // Default Scene
            Column({ space: 6 }) {
              Text('主要穿着场景')
                .fontSize(Theme.type.callout)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: 0 }, cross: { value: 8, unit: 0 } } }) {
                ForEach(WardrobeMedia.SCENES, (sc: string) => {
                  Text(sc)
                    .fontSize(Theme.type.caption1)
                    .fontColor(this.defaultScene === sc ? '#FFFFFF' : Theme.colors().textPrimary)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .backgroundColor(this.defaultScene === sc ? Theme.colors().brandPrimary : (Theme.isDark() ? '#22302D' : '#EEF5F2'))
                    .borderRadius(Theme.radius.pill)
                    .onClick(() => { this.defaultScene = sc })
                }, (sc: string) => sc)
              }
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .padding({ bottom: Theme.space.s6 })
        }
        .layoutWeight(1)

        // Actions
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: () => this.onClose()
          }).layoutWeight(1)

          AppButton({
            label: '保存偏好',
            variant: 'primary',
            onTap: () => this.handleSave()
          }).layoutWeight(1)
        }
        .width('100%')
        .padding({ top: Theme.space.s3 })
      }
      .width('100%')
      .constraintSize({ maxHeight: '70%' })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius({
        topLeft: Theme.radius.xl,
        topRight: Theme.radius.xl
      })
      .padding(Theme.space.cardPadding)
      .shadow({ radius: 24, color: 'rgba(0,0,0,0.18)', offsetY: -4 })
    }
    .width('100%')
    .height('100%')
  }
}
