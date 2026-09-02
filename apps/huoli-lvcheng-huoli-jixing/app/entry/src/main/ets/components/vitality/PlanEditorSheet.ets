import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { VitalityPlan } from '../../models/VitalityModels'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct PlanEditorSheet {
  @Prop @Watch('onVisibleChange') visible: boolean = false
  @Prop @Watch('onFormSessionChange') formSession: number = 0
  @Prop editingPlan: VitalityPlan | undefined = undefined
  onClose: () => void = () => {}
  onSave: (plan: VitalityPlan) => void = () => {}

  @State titleText: string = ''
  @State planType: string = 'checkin'
  @State targetText: string = '5'
  private lastOpenSession: number = -1

  aboutToAppear(): void {
    this.openFormIfNeeded()
  }

  onVisibleChange(): void {
    this.openFormIfNeeded()
  }

  onFormSessionChange(): void {
    this.lastOpenSession = -1
    this.openFormIfNeeded()
  }

  private openFormIfNeeded(): void {
    if (!this.visible) {
      return
    }
    if (this.formSession === this.lastOpenSession) {
      return
    }
    this.lastOpenSession = this.formSession
    this.syncForm()
  }

  private syncForm(): void {
    if (this.editingPlan !== undefined) {
      this.titleText = this.editingPlan.title
      this.planType = this.editingPlan.planType
      this.targetText = `${this.editingPlan.targetValue}`
    } else {
      this.titleText = ''
      this.planType = 'checkin'
      this.targetText = '5'
    }
  }

  private parseTargetInput(): number {
    const n = parseInt(this.targetText.trim(), 10)
    if (isNaN(n)) {
      return this.planType === 'prescription' ? 80 : 1
    }
    if (this.planType === 'prescription') {
      if (n < 1) {
        return 1
      }
      if (n > 100) {
        return 100
      }
      return n
    }
    return n >= 1 ? n : 1
  }

  private targetHint(): string {
    if (this.planType === 'prescription') {
      return '今日处方完成率目标（1–100%）'
    }
    if (this.planType === 'custom') {
      return '目标天数'
    }
    return '本周打卡目标天数'
  }

  build() {
    if (!this.visible) {
      Column()
    } else {
      Stack({ alignContent: Alignment.Bottom }) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Theme.colors().overlayScrim)
          .onClick((): void => this.onClose())

        Column({ space: Theme.space.s4 }) {
          Text(this.editingPlan !== undefined ? '编辑计划' : '新建活力计划')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)

          TextInput({ text: this.titleText, placeholder: '计划名称' })
            .onChange((v: string): void => { this.titleText = v })

          Row({ space: Theme.space.s2 }) {
            this.typeChip('本周打卡', 'checkin')
            this.typeChip('处方完成率', 'prescription')
            this.typeChip('自定义天数', 'custom')
          }
          .width('100%')

          Text(this.targetHint())
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          TextInput({ text: this.targetText, placeholder: '目标值' })
            .type(InputType.Number)
            .onChange((v: string): void => { this.targetText = v })

          Column() {
            AppButton({
              label: '保存计划',
              variant: 'primary',
              onTap: (): void => {
                const p = this.editingPlan !== undefined ? this.editingPlan.copy() : new VitalityPlan()
                if (p.id.length === 0) {
                  p.id = `plan-${Date.now()}`
                  p.startKey = DateHelper.weekKey(DateHelper.todayKey())
                  p.endKey = p.startKey
                  p.status = 'active'
                  p.currentValue = 0
                }
                p.title = this.titleText.trim().length > 0 ? this.titleText.trim() : '我的计划'
                p.planType = this.planType
                p.targetValue = this.parseTargetInput()
                this.onSave(p)
              }
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      }
      .width('100%')
      .height('100%')
      .zIndex(50)
    }
  }

  @Builder
  typeChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.planType === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.planType === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.planType = key
        if (key === 'prescription') {
          this.targetText = '80'
        } else if (key === 'checkin') {
          this.targetText = '5'
        } else {
          this.targetText = '7'
        }
      })
  }
}
