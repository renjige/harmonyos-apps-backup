import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentTemplate } from '../../models/AppointmentModels'
import { AppointmentMedia } from '../../services/AppointmentMedia'

@Component
export struct TemplateDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop template: AppointmentTemplate = new AppointmentTemplate()
  onCreate: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Image(AppointmentMedia.cover(this.template.coverKey))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Text(this.template.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.template.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(this.template.body)
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({ label: '一键创建约定', onTap: (): void => { this.onCreate() } })
      }
      .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
