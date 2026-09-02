import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

@Component
export struct HomeDiscoverHero {
  @Prop orderScore: number = 0
  @Prop orderHeadline: string = ''
  onOpenDiscover: () => void = () => {}

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.home_hero'))
        .width('100%')
        .height(168)
        .objectFit(ImageFit.Cover)
      Column() {
        Row() {
          Column({ space: 4 }) {
            Text('家庭生活工作台')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F5')
            Text(this.orderHeadline)
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFF8F5')
              .width('100%')
          }
          .layoutWeight(1)
          Column({ space: 2 }) {
            Text(`${this.orderScore}`)
              .fontSize(Theme.type.titleL)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFF8F5')
            Text('有序指数')
              .fontSize(Theme.type.caption)
              .fontColor('#FFF8F5')
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        Row({ space: 8 }) {
          Row({ space: 6 }) {
            AppIcon({ name: 'search', iconSize: 16, color: Theme.colors().brandPrimary })
            Text('打开生活发现')
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
          }
          .padding({ left: 14, right: 16, top: 10, bottom: 10 })
          .backgroundColor('#FFFFFF')
          .borderRadius(Theme.radius.button)
          .onClick(() => this.onOpenDiscover())
          Text('场景包 · 居家指南 · 维护模板')
            .fontSize(Theme.type.caption)
            .fontColor('#FFF8F5')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16, top: 48 })
      .linearGradient({
        angle: 180,
        colors: [['rgba(26,58,92,0.05)', 0], ['rgba(26,58,92,0.88)', 1]]
      })
    }
    .width('100%')
    .clip(true)
    .borderRadius(Theme.radius.xl)
    .onClick(() => this.onOpenDiscover())
  }
}
