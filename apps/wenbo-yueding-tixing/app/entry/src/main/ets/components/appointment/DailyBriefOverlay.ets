import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem } from '../../models/AppointmentModels'
import { AppointmentTools } from '../../services/AppointmentTools'
import { ScheduleEngine } from '../../services/ScheduleEngine'

@Component
export struct DailyBriefOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: AppointmentItem[] = []
  @Prop missedCount: number = 0
  onClose: () => void = () => {}
  onOpenItem: (id: string) => void = () => {}
  onComplete: (id: string) => void = () => {}
  onCopied: () => void = () => {}

  private copyBrief(): void {
    const text = AppointmentTools.briefingText(this.items)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.onCopied()
    } catch {
      this.onCopied()
    }
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('今日简报')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text(' ')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(`待办 ${this.items.length} 件 · 逾期 ${this.missedCount} 件`)
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          if (this.items.length === 0) {
            Text('今天日程空着。复制简报后可贴到消息，或去「找空档」安排一件事。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.items, (row: AppointmentItem) => {
              Column({ space: 6 }) {
                Text(row.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(row.allDay ? '全天' : row.timeRangeLabel())
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                if (ScheduleEngine.leaveByLabel(row).length > 0) {
                  Text(ScheduleEngine.leaveByLabel(row))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                }
                Row({ space: 12 }) {
                  Text('详情')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick((): void => { this.onOpenItem(row.id) })
                  Text('完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().success)
                    .onClick((): void => { this.onComplete(row.id) })
                }
                .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (row: AppointmentItem) => row.id)
          }
          AppButton({ label: '复制今日简报', onTap: (): void => { this.copyBrief() } })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
