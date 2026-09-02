import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { BrandIdentity } from '../../config/BrandIdentity'

@Component
export struct AboutOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('关于')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text(BrandIdentity.appName())
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.paint(this.themeEpoch).textPrimary)
              .width('100%')
            Text(`版本 ${BrandIdentity.version()}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.paint(this.themeEpoch).textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)

          Column({ space: 10 }) {
            this.InfoRow('应用名称', BrandIdentity.appName())
            this.InfoRow('开发者', BrandIdentity.developer())
            this.InfoRow('运营者', BrandIdentity.operator())
          }
          .width('100%')
          .padding(18)
          .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
          .borderRadius(Theme.radius.xl)

          Text('本应用为个人购物清单与备忘工具，不是购物商城，不提供商品浏览、下单或支付。以上名称与华为应用市场（AppGallery Connect）提交信息一致。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textSecondary)
            .width('100%')

          AppButton({ label: '我知道了', onTap: () => this.onClose() })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
      Blank()
      Text(value)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.paint(this.themeEpoch).textPrimary)
    }
    .width('100%')
  }
}
