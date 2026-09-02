import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from '../detail/DetailShell'
import { WorkoutRecord, WorkoutTypeOption } from '../../models/WorkoutModels'

@Component
export struct WorkoutHistoryPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: WorkoutRecord[] = []
  @Prop filterKey: string = 'all'
  onClose: () => void = () => {}
  onFilterChange: (key: string) => void = () => {}
  onOpenDetail: (id: string) => void = () => {}
  onRecord: () => void = () => {}

  private filterLabel(key: string): string {
    if (key === 'all') {
      return '全部'
    }
    return WorkoutTypeOption.labelFor(key)
  }

  private filterKeys(): string[] {
    const keys: string[] = ['all']
    for (const opt of WorkoutTypeOption.all()) {
      keys.push(opt.key)
    }
    return keys
  }

  build() {
    Column() {
      DetailShell({
        title: '训练日志库',
        onClose: (): void => this.onClose()
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('按类型筛选 · 点击条目查看详情与编辑')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.filterKeys(), (key: string) => {
                Text(this.filterLabel(key))
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterKey === key ?
                    Theme.colors().brandPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.filterKey === key ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.onFilterChange(key) })
              }, (key: string) => key)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.items.length === 0) {
            AppEmpty({
              title: '暂无匹配记录',
              description: '记录训练后会自动归档到这里，支持按类型筛选与详情编辑。'
            })
          } else {
            ForEach(this.items, (w: WorkoutRecord) => {
              Row({ space: Theme.space.s3 }) {
                AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
                Column({ space: 2 }) {
                  Text(w.sessionTitle.length > 0 ?
                    w.sessionTitle : WorkoutTypeOption.labelFor(w.typeKey))
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${w.dateKey} · ${w.durationMinutes} 分钟 · ${w.calories} 千卡`)
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
            label: '新建训练记录',
            variant: 'primary',
            onTap: (): void => this.onRecord()
          })
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
