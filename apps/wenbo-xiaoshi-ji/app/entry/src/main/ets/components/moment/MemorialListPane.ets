import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { LifeMemorial } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct MemorialListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @State items: LifeMemorial[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await MomentStore.loadMemorials()
  }

  private hint(m: LifeMemorial): string {
    const days = DateHelper.daysUntil(m.dateKey)
    if (days === 0) {
      return `今天 ${m.time}`
    }
    if (days > 0) {
      return `${days} 天后 · ${m.time}`
    }
    return `${DateHelper.displayDate(m.dateKey)} 已过`
  }

  build() {
    DetailShell({
      title: '重要纪念日',
      onClose: (): void => MomentNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        Text('生日、节日或重要事件可设日期与提醒，到点由系统通知。')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(20)
          .width('100%')

        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有纪念日',
            description: '记下生日、节日或值得每年回看的日子',
            actionLabel: '添加纪念日',
            onAction: (): void => MomentNav.openMemorialEditor('')
          })
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (m: LifeMemorial) => {
                Column({ space: 6 }) {
                  Text(m.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${DateHelper.displayDate(m.dateKey)} · ${this.hint(m)}${m.enabled ? ' · 提醒开' : ''}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                  if (m.note.length > 0) {
                    Text(m.note)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(2)
                      .width('100%')
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(14)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(16)
                .onClick((): void => MomentNav.openMemorialEditor(m.id))
              }, (m: LifeMemorial) => m.id)
              Row().height(Theme.space.s8)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .width('100%')
        }

        AppButton({
          label: '添加纪念日',
          onTap: (): void => MomentNav.openMemorialEditor('')
        })
        Row().height(Theme.space.s6)
      }
      .width('100%')
      .height('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
    }
  }
}
