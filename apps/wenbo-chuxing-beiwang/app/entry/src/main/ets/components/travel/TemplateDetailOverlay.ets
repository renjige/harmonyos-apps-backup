import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { TravelMedia } from '../../services/TravelMedia'
import { TravelTemplate } from '../../models/TravelModels'

@Component
export struct TemplateDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: TravelTemplate = new TravelTemplate()
  @Prop favorited: boolean = false
  @State applying: boolean = false
  onClose: () => void = () => {}
  onApply: () => void = () => {}
  onToggleFavorite: () => void = () => {}

  aboutToAppear(): void {
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private daysLabel(): string {
    const days = this.template.days > 0 ? this.template.days : 2
    return `${days} 天参考行程`
  }

  private close(): void {
    AppStorage.setOrCreate('tabBarHidden', false)
    this.onClose()
  }

  build() {
    Column() {
      Row() {
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 4, right: 12, top: 8, bottom: 8 })
          .onClick(() => this.close())
        Text('行程模板')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Row() {
          AppIcon({
            name: 'star',
            iconSize: Theme.icon.md,
            color: this.favorited ? Theme.colors().brandPrimary : Theme.colors().textSecondary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.onToggleFavorite())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TravelMedia.cover(this.template.coverKey))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.sheet)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [['rgba(11,39,86,0.04)', 0], ['rgba(7,32,74,0.84)', 1]]
              })
              .borderRadius(Theme.radius.sheet)
            Column({ space: 6 }) {
              Text(this.template.title)
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(`${this.template.destination} · ${this.daysLabel()}`)
                .fontSize(Theme.type.subhead)
                .fontColor('#FFFFFF')
            }
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
          }

          Column({ space: Theme.space.s2 }) {
            Text(this.template.subtitle.length > 0 ? this.template.subtitle : '公开行程模板')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.template.summary)
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Text(this.template.body.length > 0 ? this.template.body :
            '使用模板将创建行程、写入出发与返程安排，并导入证件、衣物、设备、用品四类打包清单。')
            .fontSize(Theme.type.bodyM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(24)
            .width('100%')

          AppButton({
            label: this.applying ? '正在创建…' : '使用此模板创建行程',
            disabled: this.applying,
            onTap: () => this.onApply()
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
