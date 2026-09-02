import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from '../detail/DetailShell'
import { WorkoutRecord, WorkoutTypeOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct DayWorkoutList {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop dateKey: string = ''
  @Prop items: WorkoutRecord[] = []
  onClose: () => void = () => {}
  onOpenDetail: (id: string) => void = () => {}
  onRecordDay: () => void = () => {}

  private titleText(): string {
    if (this.dateKey.length < 8) {
      return '当日图志'
    }
    return DateHelper.displayDate(this.dateKey)
  }

  build() {
    Column() {
      DetailShell({
        title: this.titleText(),
        onClose: (): void => this.onClose()
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.dateKey.length >= 8 ?
            `${DateHelper.displayWeekday(this.dateKey)} · 当日图志` : '当日图志')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.items.length === 0) {
            AppEmpty({
              title: '这一天还是空白',
              description: '可以从热力图补记过去的训练，图志才会连成线。'
            })
          } else {
            ForEach(this.items, (w: WorkoutRecord) => {
              Row({ space: Theme.space.s3 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                Column({ space: 2 }) {
                  Text(`${WorkoutTypeOption.labelFor(w.typeKey)} · ${w.durationMinutes} 分钟`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${w.calories} 千卡`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .constraintSize({ minHeight: 48 })
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.onOpenDetail(w.id) })
            }, (w: WorkoutRecord) => w.id)
          }

          AppButton({
            label: '补记这一天',
            variant: 'primary',
            onTap: (): void => this.onRecordDay()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
