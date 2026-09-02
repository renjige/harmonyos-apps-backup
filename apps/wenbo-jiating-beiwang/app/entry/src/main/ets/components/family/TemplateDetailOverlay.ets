import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { FamilyMedia } from '../../services/FamilyMedia'
import { FamilyTemplate } from '../../models/FamilyModels'

@Component
export struct TemplateDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: FamilyTemplate = new FamilyTemplate()
  onClose: () => void = () => {}
  onCreate: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(FamilyMedia.cover(this.template.coverKey))
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
            Text(this.template.subtitle.length > 0 ? this.template.subtitle : '家庭清单模板')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.template.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          Text(this.template.body.length > 0 ? this.template.body : '一键创建后，可按需要增删事项。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '一键创建家庭清单', onTap: () => this.onCreate() })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
