import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoInspect } from '../../models/RenoModels'
import { RenoService } from '../../services/RenoService'

@Component
export struct InspectListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @StorageLink('renoRev') @Watch('onRev') renoRev: number = 0
  @State rows: RenoInspect[] = []
  @State done: number = 0
  onClose: () => void = () => {}
  onOpen: (item: RenoInspect) => void = (_i: RenoInspect) => {}
  onNeedProject: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const current = RenoService.currentProject()
    if (current === null) {
      this.rows = []
      this.done = 0
      return
    }
    const list = await RenoService.inspectForProject(current.id)
    this.rows = list
    this.done = RenoService.inspectRate(list)
  }

  build() {
    Column() {
      Row() {
        Text('验收清单')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 8 })
      Text(`验收进度 ${this.done}/${this.rows.length}`)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        .padding({ left: Theme.space.pageX, bottom: 8 })
        .width('100%')
      Text('结果仅供个人记录参考，不构成专业鉴定。')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .width('100%')
      if (this.rows.length === 0) {
        AppEmpty({
          title: '请先创建装修项目',
          description: '验收清单会关联当前项目',
          actionLabel: '去创建',
          onAction: () => this.onNeedProject()
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.rows, (it: RenoInspect) => {
              Row() {
                Column({ space: 4 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(`${it.category} · ${RenoDates.inspectLabel(it.result)}`)
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
            }, (it: RenoInspect) => it.id)
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
