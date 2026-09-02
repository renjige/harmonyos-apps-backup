import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem } from '../../models/AppointmentModels'

@Component
export struct OverdueDeskOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: AppointmentItem[] = []
  onClose: () => void = () => {}
  onOpenItem: (id: string) => void = () => {}
  onPostponeAll: () => void = () => {}
  onComplete: (id: string) => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text('逾期台')
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
          Text(this.items.length === 0 ?
            '没有逾期约定。守约节奏正常。' :
            `有 ${this.items.length} 件已过期未完成，可改到明天或标记完成。`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          ForEach(this.items, (row: AppointmentItem) => {
            Column({ space: 6 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(`${row.dueDate} ${row.dueTime} · ${row.sceneLabel()}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .width('100%')
              Row({ space: 16 }) {
                Text('打开')
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

          if (this.items.length > 0) {
            AppButton({ label: '全部改到明天同一时刻', onTap: (): void => { this.onPostponeAll() } })
          }
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
