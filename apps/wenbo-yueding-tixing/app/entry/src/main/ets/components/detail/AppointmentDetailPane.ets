import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem } from '../../models/AppointmentModels'
import { AppointmentMedia } from '../../services/AppointmentMedia'
import { AppointmentCardUtil } from '../appointment/AppointmentCards'

@Component
export struct AppointmentDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: AppointmentItem = new AppointmentItem()
  onEdit: () => void = () => {}
  onComplete: () => void = () => {}

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(AppointmentMedia.coverForItem(this.item))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.xl)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(17,24,39,0.08)', 0], ['rgba(17,24,39,0.78)', 1]]
            })
            .borderRadius(Theme.radius.xl)
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding(16)
        }
        Text(AppointmentCardUtil.rowMeta(this.item))
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (!this.item.isDone()) {
          AppButton({ label: '标记完成', onTap: (): void => { this.onComplete() } })
        }
        AppButton({ label: '编辑约定', variant: 'secondary', onTap: (): void => { this.onEdit() } })
      }
      .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
