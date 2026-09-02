import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { RenoEvent } from '../../models/RenoModels'
import { RenoLedger } from '../../services/RenoLedger'
import { RenoService } from '../../services/RenoService'

@Component
export struct TimelinePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State rows: RenoEvent[] = []
  @State hasProject: boolean = false
  onClose: () => void = () => {}
  onOpen: (item: RenoEvent) => void = (_i: RenoEvent) => {}
  onNeedProject: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    const current = RenoService.currentProject()
    this.hasProject = current !== null
    this.rows = current !== null ? RenoLedger.timeline(current.id) : []
  }

  private kindLabel(kind: string): string {
    if (kind === 'task') {
      return '事项'
    }
    if (kind === 'material') {
      return '材料'
    }
    if (kind === 'expense') {
      return '费用'
    }
    return '记录'
  }

  build() {
    Column() {
      Row() {
        Text('施工时间线')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 8 })
      Text('把事项、材料、现场记录和费用按日期串起来，方便回顾施工过程。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
        .width('100%')
      if (!this.hasProject) {
        AppEmpty({
          title: '请先创建装修项目',
          description: '时间线会汇总当前项目的全部记录',
          actionLabel: '去创建',
          onAction: () => this.onNeedProject()
        })
      } else if (this.rows.length === 0) {
        AppEmpty({ title: '还没有时间线条目', description: '记事项、材料、现场情况或费用后会出现在这里' })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.rows, (it: RenoEvent) => {
              Row() {
                Column({ space: 4 }) {
                  Text(`${it.date} · ${this.kindLabel(it.kind)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .width('100%')
                  Text(it.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick(() => this.onOpen(it))
            }, (it: RenoEvent) => it.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
