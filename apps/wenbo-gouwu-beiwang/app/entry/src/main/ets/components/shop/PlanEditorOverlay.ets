import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ProcurementPlan, ShoppingList } from '../../models/ShoppingModels'
import { GrowthService } from '../../services/GrowthService'
import { GrowthLocalStore } from '../../services/GrowthLocalStore'
import { ShoppingLocalStore } from '../../services/ShoppingLocalStore'
import { ShoppingService } from '../../services/ShoppingService'

@Component
export struct PlanEditorOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plan: ProcurementPlan = new ProcurementPlan()
  @State title: string = ''
  @State targetCount: string = '12'
  @State budget: string = '300'
  @State startDate: string = ''
  @State endDate: string = ''
  @State lists: ShoppingList[] = []
  @State linked: string[] = []
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    this.lists = await ShoppingService.lists()
    const active = GrowthService.activePlan()
    if (active !== undefined) {
      this.plan = active
    } else {
      this.plan = new ProcurementPlan()
      this.plan.id = ''
      this.plan.status = 'active'
    }
    this.title = this.plan.title.length > 0 ? this.plan.title : '本周采购计划'
    this.targetCount = `${this.plan.targetItemCount > 0 ? this.plan.targetItemCount : 12}`
    this.budget = this.plan.targetBudgetYuan.length > 0 ? this.plan.targetBudgetYuan : '300'
    this.startDate = this.plan.startDate.length > 0 ? this.plan.startDate : ShoppingLocalStore.today()
    this.endDate = this.plan.endDate.length > 0 ? this.plan.endDate : this.startDate
    this.linked = this.plan.linkedListIds.slice()
  }

  private toggleList(id: string): void {
    const next: string[] = []
    let hit = false
    for (const row of this.linked) {
      if (row === id) {
        hit = true
        continue
      }
      next.push(row)
    }
    if (!hit) {
      next.push(id)
    }
    this.linked = next
  }

  private isLinked(id: string): boolean {
    for (const row of this.linked) {
      if (row === id) {
        return true
      }
    }
    return false
  }

  private async save(): Promise<void> {
    if (this.plan.id.length === 0) {
      this.plan.id = GrowthLocalStore.newId('plan')
      this.plan.createdAt = ShoppingLocalStore.nowIso()
    }
    this.plan.title = this.title.trim().length > 0 ? this.title.trim() : '本周采购计划'
    const count = Number.parseInt(this.targetCount)
    this.plan.targetItemCount = Number.isNaN(count) ? 12 : count
    this.plan.targetBudgetYuan = this.budget.trim().length > 0 ? this.budget.trim() : '300'
    this.plan.startDate = this.startDate
    this.plan.endDate = this.endDate
    this.plan.linkedListIds = this.linked.slice()
    this.plan.status = 'active'
    if (this.plan.createdAt.length === 0) {
      this.plan.createdAt = ShoppingLocalStore.nowIso()
    }
    await GrowthService.savePlan(this.plan)
    this.onSaved()
    this.onClose()
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.paint(this.themeEpoch).brandPrimary)
          .onClick(() => this.onClose())
        Blank()
        Text('编辑采购计划')
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.paint(this.themeEpoch).textPrimary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: 12 }) {
          TextInput({ text: this.title, placeholder: '计划名称' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.title = v })
          TextInput({ text: this.targetCount, placeholder: '目标勾选件数' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.targetCount = v })
          TextInput({ text: this.budget, placeholder: '预算（元）' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.budget = v })
          TextInput({ text: this.startDate, placeholder: '开始日期 YYYY-MM-DD' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.startDate = v })
          TextInput({ text: this.endDate, placeholder: '结束日期 YYYY-MM-DD' })
            .height(48)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .padding({ left: 14, right: 14 })
            .onChange((v: string) => { this.endDate = v })
          Text('关联清单（不选则统计全部清单）')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.paint(this.themeEpoch).textPrimary)
            .width('100%')
          ForEach(this.lists, (row: ShoppingList) => {
            Row() {
              Text(this.isLinked(row.id) ? '☑' : '☐')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().brandPrimary)
                .width(28)
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                .layoutWeight(1)
                .maxLines(1)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })
            .onClick((): void => { this.toggleList(row.id) })
          }, (row: ShoppingList) => row.id)
          AppButton({ label: '保存计划', onTap: (): void => { void this.save() } })
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.paint(this.themeEpoch).surfacePage)
  }
}
