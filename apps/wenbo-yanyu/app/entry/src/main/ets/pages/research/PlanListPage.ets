import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { PlanStageRow } from '../../components/research/PlanStageRow'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchPlan } from '../../models/ResearchModels'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct PlanListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: ResearchPlan[] = []
  @State title: string = ''
  @State goal: string = ''
  @State stageA: string = ''
  @State stageB: string = ''
  @State stageC: string = ''
  @State pendingId: string = ''
  @State toastText: string = ''
  @State listEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.items = await ResearchStore.listPlans()
    this.listEpoch += 1
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写研究目标')
      return
    }
    const p = ResearchPlan.create()
    p.title = this.title.trim()
    p.goal = this.goal.trim()
    p.stageA = this.stageA.trim().length > 0 ? this.stageA.trim() : '收集材料'
    p.stageB = this.stageB.trim().length > 0 ? this.stageB.trim() : '整理观点'
    p.stageC = this.stageC.trim().length > 0 ? this.stageC.trim() : '写成笔记'
    await ResearchStore.savePlan(p)
    this.title = ''
    this.goal = ''
    this.stageA = ''
    this.stageB = ''
    this.stageC = ''
    this.showToast('研究计划已创建')
    await this.reload()
  }

  private async toggle(planId: string, which: string): Promise<void> {
    const list = await ResearchStore.listPlans()
    let target: ResearchPlan | undefined = undefined
    for (const p of list) {
      if (p.id === planId) {
        target = p
      }
    }
    if (target === undefined) {
      return
    }
    const next = new ResearchPlan()
    next.id = target.id
    next.title = target.title
    next.goal = target.goal
    next.stageA = target.stageA
    next.stageB = target.stageB
    next.stageC = target.stageC
    next.doneA = target.doneA
    next.doneB = target.doneB
    next.doneC = target.doneC
    next.createdAt = target.createdAt
    if (which === 'a') {
      next.doneA = next.doneA === '1' ? '0' : '1'
    } else if (which === 'b') {
      next.doneB = next.doneB === '1' ? '0' : '1'
    } else {
      next.doneC = next.doneC === '1' ? '0' : '1'
    }
    await ResearchStore.savePlan(next)
    await this.reload()
  }

  private async remove(id: string): Promise<void> {
    if (this.pendingId !== id) {
      this.pendingId = id
      this.showToast('再点一次确认删除计划')
      return
    }
    await ResearchStore.deletePlan(id)
    this.pendingId = ''
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '研究计划' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.title, placeholder: '研究目标，如：理清宋代夜市材料' })
              .onChange((v: string) => { this.title = v })
            TextArea({ text: this.goal, placeholder: '为什么做、想回答什么问题' })
              .height(64)
              .onChange((v: string) => { this.goal = v })
            TextInput({ text: this.stageA, placeholder: '阶段一（默认：收集材料）' })
              .onChange((v: string) => { this.stageA = v })
            TextInput({ text: this.stageB, placeholder: '阶段二（默认：整理观点）' })
              .onChange((v: string) => { this.stageB = v })
            TextInput({ text: this.stageC, placeholder: '阶段三（默认：写成笔记）' })
              .onChange((v: string) => { this.stageC = v })
            AppButton({ label: '创建计划', onTap: (): void => { void this.save() } })
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有研究计划',
                description: '把一个问题拆成三个阶段，勾选完成即可看到进度。'
              })
            } else {
              ForEach(this.items, (p: ResearchPlan) => {
                Column({ space: 8 }) {
                  Row() {
                    Text(p.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.of(this.darkModeOn).textPrimary)
                      .layoutWeight(1)
                    Text(p.progressLabel())
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                  }
                  .width('100%')
                  Text(p.goal)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                  PlanStageRow({
                    label: p.stageA,
                    done: p.doneA === '1',
                    onToggle: (): void => { void this.toggle(p.id, 'a') }
                  })
                  PlanStageRow({
                    label: p.stageB,
                    done: p.doneB === '1',
                    onToggle: (): void => { void this.toggle(p.id, 'b') }
                  })
                  PlanStageRow({
                    label: p.stageC,
                    done: p.doneC === '1',
                    onToggle: (): void => { void this.toggle(p.id, 'c') }
                  })
                  Text(this.pendingId === p.id ? '再点确认删除' : '删除计划')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).danger)
                    .onClick((): void => { void this.remove(p.id) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (p: ResearchPlan) => `${p.id}_${this.listEpoch}_${p.doneA}_${p.doneB}_${p.doneC}`)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
