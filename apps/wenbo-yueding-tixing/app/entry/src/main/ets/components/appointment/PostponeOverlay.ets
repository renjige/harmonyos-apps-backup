import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem } from '../../models/AppointmentModels'

class PostponeOption {
  key: string = ''
  label: string = ''
  minutes: number = 0
}

@Component
export struct PostponeOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: AppointmentItem = new AppointmentItem()
  onClose: () => void = () => {}
  onPick: (minutes: number) => void = () => {}

  private options(): PostponeOption[] {
    const a = new PostponeOption(); a.key = '15'; a.label = '延后 15 分钟'; a.minutes = 15
    const b = new PostponeOption(); b.key = '60'; b.label = '延后 1 小时'; b.minutes = 60
    const c = new PostponeOption(); c.key = 'day'; c.label = '改到明天同一时间'; c.minutes = 24 * 60
    const d = new PostponeOption(); d.key = 'week'; d.label = '改到下周同一时间'; d.minutes = 7 * 24 * 60
    return [a, b, c, d]
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('改期')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Blank()
      }
      .width('100%')
      Text(`当前：${this.item.dateTimeLabel()}`)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      ForEach(this.options(), (opt: PostponeOption) => {
        AppButton({
          label: opt.label,
          variant: 'secondary',
          onTap: (): void => { this.onPick(opt.minutes) }
        })
      }, (opt: PostponeOption) => opt.key)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
