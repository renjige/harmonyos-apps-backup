import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ShoppingMedia } from '../../services/ShoppingMedia'
import { ShoppingTemplate } from '../../models/ShoppingModels'

@Component
export struct TemplateDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: ShoppingTemplate = new ShoppingTemplate()
  onCreate: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(ShoppingMedia.cover(this.template.coverKey))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(8,42,90,0.05)', 0], ['rgba(8,42,90,0.76)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text(this.template.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding(18)
        }
        Column({ space: 10 }) {
          Text(this.template.subtitle.length > 0 ? this.template.subtitle : '清单模板')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
            .width('100%')
          Text(this.template.summary)
            .fontSize(Theme.type.body)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(18)
        .backgroundColor(Theme.paint(this.themeEpoch).surfaceCard)
        .borderRadius(Theme.radius.xl)
        Text(this.template.body.length > 0 ? this.template.body : '一键创建后，可按需要增删物品。')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).textSecondary)
          .width('100%')
        AppButton({ label: '一键创建清单', onTap: () => this.onCreate() })
      }
      .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
    }
    .width('100%')
    .layoutWeight(1)
  }
}
