import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { SolidButton } from '../design-system/SolidButton'
import { HubShell } from './HubShell'
import { GoalFormOverlay } from './GoalFormOverlay'
import { GoalCard } from './GoalCard'
import { GoalDraft, StageGoal } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { DataRefresh } from '../../services/DataRefresh'
import { PracticeNav } from '../../services/PracticeNav'

@Component
export struct GoalHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @State items: StageGoal[] = []
  @State showForm: boolean = false
  @State draft: GoalDraft = new GoalDraft()
  @State pendingDelete: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onDataEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.items = PracticeHubStore.listGoals()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private liveKey(g: StageGoal): string {
    return `${g.id}_${PracticeService.liveCount(g)}_${this.pendingDelete}`
  }

  private async submitGoal(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    await PracticeHubStore.saveGoal(PracticeService.createGoal(this.draft))
    this.showForm = false
    this.draft = new GoalDraft()
    DataRefresh.bump()
    this.reload()
    this.showToast('目标已创建，保存训练后进度会立刻变化')
  }

  private async bumpById(id: string, delta: number): Promise<void> {
    const found = this.findGoal(id)
    if (found === null) {
      return
    }
    const next = PracticeService.bumpGoal(found, delta)
    await PracticeHubStore.saveGoal(next)
    DataRefresh.bump()
    this.reload()
    this.showToast(`已更新为 ${PracticeService.liveCount(next)} / ${next.targetCount} ${next.unit}`)
  }

  private findGoal(id: string): StageGoal | null {
    for (const g of this.items) {
      if (g.id === id) {
        return g
      }
    }
    return null
  }

  private async confirmDelete(id: string): Promise<void> {
    if (this.pendingDelete !== id) {
      this.pendingDelete = id
      return
    }
    await PracticeHubStore.deleteGoal(id)
    this.pendingDelete = ''
    DataRefresh.bump()
    this.reload()
    this.showToast('已删除目标')
  }

  private goRecord(): void {
    AppStorage.setOrCreate('showTrainingForm', true)
    PracticeNav.closeHub()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.showForm) {
        GoalFormOverlay({
          draft: this.draft,
          onClose: (): void => { this.showForm = false },
          onSubmit: (): void => { void this.submitGoal() },
          onDraftChange: (d: GoalDraft): void => { this.draft = d }
        })
      } else {
        HubShell({
          title: '训练目标',
          onClose: (): void => { this.onClose() },
          body: (): void => { this.Body() }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Text('默认跟随训练记录实时计数。保存一条训练，进度马上从 0/20 变成 1/20，不读取健康数据。')
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.colors().textSecondary)
      .width('100%')

    Column() {
      SolidButton({
        label: '新建目标',
        tone: 'primary',
        onTap: (): void => { this.showForm = true }
      })
    }
    .width('100%')
    .onClick((): void => { this.showForm = true })

    if (this.items.length === 0) {
      AppEmpty({
        title: '还没有阶段目标',
        description: '设一个次数目标后，去首页点「开始训练」，回来即可看到进度'
      })
    } else {
      ForEach(this.items, (g: StageGoal) => {
        GoalCard({
          goal: g,
          pendingDelete: this.pendingDelete === g.id,
          onBump: (id: string, delta: number): void => { void this.bumpById(id, delta) },
          onAskDelete: (id: string): void => { void this.confirmDelete(id) },
          onGoRecord: (): void => { this.goRecord() }
        })
      }, (g: StageGoal) => this.liveKey(g))
    }
  }
}
