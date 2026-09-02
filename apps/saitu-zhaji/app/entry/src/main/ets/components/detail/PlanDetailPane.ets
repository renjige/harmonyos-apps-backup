import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { JourneyPlan, PlanTask } from '../../models/SaituGrowthModels'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituPlanStore } from '../../services/SaituPlanStore'
import { SaituDetailNav } from '../../services/SaituDetailNav'
import { SaituAchievementStore } from '../../services/SaituAchievementStore'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPlanIdChange') planId: string = ''
  onChanged: () => void = () => {}
  @State plan: JourneyPlan = new JourneyPlan()
  @State journeyName: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onPlanIdChange(): void {
    void this.load()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async load(): Promise<void> {
    if (this.planId.length === 0) {
      return
    }
    const found = await SaituPlanStore.findPlan(this.planId)
    if (found !== undefined) {
      this.plan = found
      const j = await SaituLocalStore.findJourney(found.journeyId)
      this.journeyName = j !== undefined ? j.name : ''
    }
  }

  private async toggleTask(id: string): Promise<void> {
    const next: PlanTask[] = []
    for (const t of this.plan.tasks) {
      const copy = new PlanTask()
      copy.id = t.id
      copy.title = t.title
      copy.done = t.id === id ? !t.done : t.done
      next.push(copy)
    }
    this.plan.tasks = next
    let done = 0
    for (const t of next) {
      if (t.done) {
        done++
      }
    }
    if (next.length > 0 && done === next.length) {
      this.plan.status = 'done'
    }
    await SaituPlanStore.savePlan(this.plan)
    await SaituAchievementStore.evaluateAndUnlock()
    this.onChanged()
    this.showToast('任务状态已更新')
  }

  private async deletePlan(): Promise<void> {
    await SaituPlanStore.deletePlan(this.plan.id)
    SaituDetailNav.closePlan()
    this.onChanged()
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(this.plan.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.journeyName.length > 0) {
          Text(`旅途 · ${this.journeyName}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }
        Text(`${this.plan.statusLabel()} · ${this.plan.progressLabel()}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        Row() {
          Row()
            .width(`${Math.max(8, Math.round(this.plan.progressRatio() * 100))}%`)
            .height(10)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(5)
        }
        .width('100%')
        .height(10)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(5)

        if (this.plan.tasks.length > 0) {
          Text('任务清单')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          ForEach(this.plan.tasks, (t: PlanTask) => {
            Row({ space: Theme.space.s3 }) {
              Text(t.done ? '☑' : '☐')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().brandPrimary)
              Text(t.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { void this.toggleTask(t.id) })
          }, (t: PlanTask) => `${t.id}_${t.done ? '1' : '0'}`)
        }

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => SaituDetailNav.openPlanEditor(this.plan.id)
          })
          AppButton({
            label: '删除',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '赛途计划',
        onClose: (): void => SaituDetailNav.closePlan(),
        body: (): void => this.bodyContent()
      })

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('确认删除此计划？')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = false }
            })
            AppButton({
              label: '删除',
              variant: 'primary',
              onTap: (): void => {
                this.confirmDelete = false
                void this.deletePlan()
              }
            })
          }
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '10%', y: '35%' })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
