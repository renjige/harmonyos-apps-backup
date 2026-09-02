import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppError } from '../components/design-system/AppError'
import { BizService, EngProjectView } from '../services/BizService'

class StepItem {
  code: string = ''
  label: string = ''

  static all(): StepItem[] {
    const codes: string[] = ['planned', 'in_progress', 'accepting', 'archived']
    const labels: string[] = ['立项', '在建', '验收', '归档']
    const list: StepItem[] = []
    for (let i = 0; i < codes.length; i++) {
      const s = new StepItem()
      s.code = codes[i]
      s.label = labels[i]
      list.push(s)
    }
    return list
  }
}

class ProjectAction {
  label: string = ''
  status: string = ''

  static make(label: string, status: string): ProjectAction {
    const a = new ProjectAction()
    a.label = label
    a.status = status
    return a
  }
}

@Component
export struct ProjectDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop projectId: string = ''
  @Prop projectName: string = ''
  @Prop initialStatusCode: string = 'planned'
  @State name: string = ''
  @State code: string = ''
  @State statusCode: string = 'planned'
  @State statusLabel: string = ''
  @State clientName: string = ''
  @State managerName: string = ''
  @State address: string = ''
  @State progressPct: number = 0
  @State outputDone: number = 0
  @State outputTarget: number = 0
  @State contractAmount: number = 0
  @State riskOpenCount: number = 0
  @State tip: string = ''
  @State tipOk: boolean = true
  @State saving: boolean = false
  @State loading: boolean = true
  @State loadError: string = ''
  @State actions: ProjectAction[] = []
  private steps: StepItem[] = StepItem.all()
  onBack: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear() {
    this.name = this.projectName
    this.statusCode = this.initialStatusCode
    this.statusLabel = BizService.projectStatusLabel(this.statusCode)
    this.refreshActions()
    this.loadDetail()
  }

  private stepIndex(code: string): number {
    for (let i = 0; i < this.steps.length; i++) {
      if (this.steps[i].code === code) {
        return i
      }
    }
    return 0
  }

  private refreshActions(): void {
    const list: ProjectAction[] = []
    if (this.statusCode === 'planned') {
      list.push(ProjectAction.make('开工推进', 'in_progress'))
    }
    if (this.statusCode === 'in_progress') {
      list.push(ProjectAction.make('发起验收', 'accepting'))
    }
    if (this.statusCode === 'accepting') {
      list.push(ProjectAction.make('确认归档', 'archived'))
    }
    this.actions = list
  }

  private applyView(view: EngProjectView): void {
    this.name = view.name
    this.code = view.code
    this.statusCode = view.statusCode
    this.statusLabel = view.status
    this.clientName = view.clientName
    this.managerName = view.managerName
    this.address = view.address
    this.progressPct = view.progressPct
    this.outputDone = view.outputDone
    this.outputTarget = view.outputTarget
    this.contractAmount = view.contractAmount
    this.riskOpenCount = view.riskOpenCount
    this.refreshActions()
  }

  private async loadDetail(): Promise<void> {
    this.loading = true
    this.loadError = ''
    const view = await BizService.getProject(this.projectId)
    this.loading = false
    if (view === null) {
      this.loadError = '项目加载失败'
      return
    }
    this.applyView(view)
  }

  private async applyStatus(status: string): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    this.tip = ''
    this.tipOk = true
    const view = await BizService.patchProjectStatus(this.projectId, status)
    this.saving = false
    if (view === null) {
      this.tipOk = false
      this.tip = BizService.lastError.length > 0 ? BizService.lastError : '状态更新未成功，请稍后重试'
      return
    }
    this.applyView(view)
    this.tipOk = true
    this.tip = `已更新为${view.status}`
    this.onChanged()
  }

  build() {
    Column() {
      AppNavBar({ title: '项目详情', onBack: () => this.onBack() })
      if (this.loading) {
        AppLoading({ label: '加载中' })
      } else if (this.loadError.length > 0) {
        AppError({
          message: this.loadError,
          retryLabel: '重试',
          onRetry: () => this.loadDetail()
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            AppCard({ title: this.name }) {
              Column({ space: Theme.space.s1 }) {
                Text(`${this.code} · ${this.statusLabel}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(`甲方 ${this.clientName}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                Text(`经理 ${this.managerName} · ${this.address}`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }.width('100%').alignItems(HorizontalAlign.Start)
            }

            AppCard({ title: '生命周期' }) {
              Row() {
                ForEach(this.steps, (s: StepItem, index: number) => {
                  Column({ space: Theme.space.s1 }) {
                    Circle({ width: 12, height: 12 })
                      .fill(index <= this.stepIndex(this.statusCode) ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    Text(s.label)
                      .fontSize(Theme.type.overline)
                      .fontColor(index <= this.stepIndex(this.statusCode) ?
                        Theme.colors().brandPrimary : Theme.colors().textTertiary)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Center)
                }, (s: StepItem) => s.code)
              }.width('100%')
            }

            AppCard({ title: '经营摘要' }) {
              Column({ space: Theme.space.s2 }) {
                Text(`合同额 ${BizService.formatAmount(this.contractAmount)}`)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(`产值 ${BizService.formatAmount(this.outputDone)} / ${BizService.formatAmount(this.outputTarget)}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(`进度 ${this.progressPct}% · 开放风险 ${this.riskOpenCount}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .width('100%')
              }.width('100%').alignItems(HorizontalAlign.Start)
            }

            if (this.tip.length > 0) {
              Text(this.tip)
                .fontSize(Theme.type.subhead)
                .fontColor(this.tipOk ? Theme.colors().success : Theme.colors().danger)
                .width('100%')
            }

            ForEach(this.actions, (a: ProjectAction) => {
              AppButton({
                label: this.saving ? '处理中…' : a.label,
                onTap: () => this.applyStatus(a.status)
              })
            }, (a: ProjectAction) => a.status)
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s8
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
