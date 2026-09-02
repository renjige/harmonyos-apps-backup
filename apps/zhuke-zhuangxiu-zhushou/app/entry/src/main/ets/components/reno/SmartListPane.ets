import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { RenoDates, RenoSuggestion, RenoTask } from '../../models/RenoModels'
import { RenoCatalog } from '../../services/RenoCatalog'
import { RenoService } from '../../services/RenoService'
import { RenoMedia } from '../../services/RenoMedia'

@Component
export struct SmartListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onTick') refreshToken: number = 0
  @State stage: string = '水电'
  @State rows: RenoSuggestion[] = []
  @State toast: string = ''
  onClose: () => void = () => {}
  onOpen: (item: RenoSuggestion) => void = (_i: RenoSuggestion) => {}
  onNeedProject: () => void = () => {}
  onAdded: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const current = RenoService.currentProject()
    this.stage = current !== null ? current.stage : '水电'
    this.rows = await RenoCatalog.suggestions(this.stage)
  }

  private async addOne(item: RenoSuggestion): Promise<void> {
    const current = RenoService.currentProject()
    if (current === null) {
      this.onNeedProject()
      return
    }
    const draft = new RenoTask()
    draft.title = item.title
    draft.stage = this.stage
    draft.status = 'todo'
    draft.date = RenoDates.today()
    draft.remark = item.summary
    draft.projectId = current.id
    await RenoService.saveTask(draft, false)
    this.toast = '已加入事项'
    setTimeout(() => { this.toast = '' }, 1800)
    this.onAdded()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('智能装修清单')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('关闭').fontSize(Theme.type.body).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).onClick(() => this.onClose())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 16, bottom: 8 })
        Text(`根据当前装修阶段（${this.stage}），为你整理了这些事项`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 12 })
          .width('100%')
        if (this.rows.length === 0) {
          AppEmpty({ title: '暂无推荐事项', description: '切换项目阶段后再试' })
        } else {
          Scroll() {
            Column({ space: 10 }) {
              ForEach(this.rows, (it: RenoSuggestion) => {
                Column({ space: 8 }) {
                  Image(RenoMedia.cover(it.coverKey))
                    .width('100%')
                    .height(128)
                    .borderRadius(10)
                    .objectFit(ImageFit.Cover)
                    .onClick(() => this.onOpen(it))
                  Row() {
                    Column({ space: 4 }) {
                      Text(it.title)
                        .fontSize(Theme.type.subtitleS)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .width('100%')
                      Text(it.summary)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .maxLines(2)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                  }
                  .width('100%')
                  .onClick(() => this.onOpen(it))
                  AppButton({
                    label: '加入事项',
                    variant: 'secondary',
                    onTap: () => { void this.addOne(it) }
                  })
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (it: RenoSuggestion) => it.id)
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

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().success)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
