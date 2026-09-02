import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { HomeTaskRow } from '../../models/LifeGrowthModels'

@Component
export struct HomeTodayTasks {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEpoch') listEpoch: number = 0
  @Prop rows: HomeTaskRow[] = []
  onToggle: (row: HomeTaskRow) => void = (_row: HomeTaskRow) => {}
  onEmptyWrite: () => void = () => {}

  onEpoch(): void {
    return
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('今日待办与打卡')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.rows.length === 0) {
        Text('还没有今日任务。创建一个习惯或待办，首页就会开始记账。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Text('去写一页')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onEmptyWrite() })
      } else {
        ForEach(this.rows, (row: HomeTaskRow) => {
          Row({ space: Theme.space.s3 }) {
            AppIcon({
              name: row.done ? 'check' : 'empty',
              iconSize: Theme.icon.sm,
              color: row.done ? Theme.colors().brandPrimary : Theme.colors().textTertiary
            })
            Column({ space: 2 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .decoration({ type: row.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                .maxLines(1)
              Text(row.kind === 'habit' ? `打卡 · ${row.meta}` : `待办 · ${row.meta}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.onToggle(row) })
        }, (row: HomeTaskRow) => `${row.kind}_${row.id}_${row.done}_${this.listEpoch}`)
      }
    }
    .width('100%')
  }
}
