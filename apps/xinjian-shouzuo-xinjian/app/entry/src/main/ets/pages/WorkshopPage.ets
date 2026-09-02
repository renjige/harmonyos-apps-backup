import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { CostItem, ChecklistItem, WorkshopStore } from '../services/WorkshopStore'

class ConvertRow {
  key: string = ''
  label: string = ''
  value: string = ''
}

class SizePreset {
  label: string = ''
  cm: string = ''
}

@Component
export struct WorkshopPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop embedded: boolean = false
  @State elapsed: number = 0
  @State running: boolean = false
  @State costName: string = ''
  @State costAmount: string = ''
  @State costs: CostItem[] = []
  @State checklist: ChecklistItem[] = []
  @State stepText: string = ''
  @State cmText: string = '15'
  @State convertRows: ConvertRow[] = []
  @State convertSummary: string = ''
  @State fabricWidth: string = '30'
  @State fabricHeight: string = '40'
  @State fabricSummary: string = ''
  private timerId: number = -1
  private sizePresets: SizePreset[] = WorkshopPage.buildPresets()

  private static buildPresets(): SizePreset[] {
    const values = ['10', '15', '20', '25', '30']
    const out: SizePreset[] = []
    for (const cm of values) {
      const p = new SizePreset()
      p.label = `${cm} cm`
      p.cm = cm
      out.push(p)
    }
    return out
  }

  aboutToAppear(): void {
    this.running = WorkshopStore.timerRunning()
    this.elapsed = WorkshopStore.tickSync()
    this.costs = WorkshopStore.costs()
    this.checklist = WorkshopStore.checklist()
    this.cmText = WorkshopStore.cmText()
    this.rebuildConvert()
    this.rebuildFabric()
    if (this.running) {
      this.startTick()
    }
  }

  aboutToDisappear(): void {
    this.stopTick()
  }

  private startTick(): void {
    this.stopTick()
    this.timerId = setInterval((): void => {
      this.elapsed = WorkshopStore.tickSync()
    }, 1000)
  }

  private stopTick(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private async handleStart(): Promise<void> {
    await WorkshopStore.startOrResume()
    this.running = true
    this.startTick()
  }

  private async handlePause(): Promise<void> {
    await WorkshopStore.pause()
    this.running = false
    this.stopTick()
    this.elapsed = WorkshopStore.elapsedSec()
  }

  private async handleReset(): Promise<void> {
    await WorkshopStore.reset()
    this.running = false
    this.stopTick()
    this.elapsed = 0
  }

  private rebuildConvert(): void {
    const cm = WorkshopStore.parseCmInput(this.cmText)
    if (cm <= 0) {
      this.convertSummary = '请输入有效边长（厘米，可含小数）'
      this.convertRows = []
      return
    }
    const inchRaw = cm / 2.54
    const inch = Math.floor(inchRaw * 10) / 10
    this.convertSummary = `${cm} cm ≈ ${inch} 英寸`
    const rows: ConvertRow[] = []
    const a = new ConvertRow()
    a.key = `inch_${cm}`
    a.label = '英寸'
    a.value = `${inch} in`
    rows.push(a)
    const b = new ConvertRow()
    b.key = `paper_${cm}`
    b.label = '折纸方形建议'
    b.value = cm >= 15 ? '可做信封 / 杯垫' : '适合书签、押花小片'
    rows.push(b)
    const c = new ConvertRow()
    c.key = `cloth_${cm}`
    c.label = '布料（含缝份）'
    c.value = `${Math.floor(cm + 2)} cm 裁片`
    rows.push(c)
    const d = new ConvertRow()
    d.key = `thread_${cm}`
    d.label = '绣线大约'
    d.value = `${Math.floor(cm * 4)} cm`
    rows.push(d)
    const e = new ConvertRow()
    e.key = `perimeter_${cm}`
    e.label = '正方形周长'
    e.value = `${Math.floor(cm * 4)} cm`
    rows.push(e)
    this.convertRows = rows
  }

  private rebuildFabric(): void {
    const w = WorkshopStore.parseCmInput(this.fabricWidth)
    const h = WorkshopStore.parseCmInput(this.fabricHeight)
    if (w <= 0 || h <= 0) {
      this.fabricSummary = '请输入有效的宽与高（厘米）'
      return
    }
    const area = Math.floor(w * h)
    const threadM = Math.floor((w + h) * 2 * 1.2)
    this.fabricSummary = `面积 ${area} cm² · 建议留线约 ${threadM} cm（含 20% 余量）`
  }

  private checklistDoneCount(): number {
    let n = 0
    for (const item of this.checklist) {
      if (item.done) {
        n += 1
      }
    }
    return n
  }

  private async onCmChange(v: string): Promise<void> {
    this.cmText = v
    this.rebuildConvert()
    await WorkshopStore.saveCmText(v)
  }

  private async addCost(): Promise<void> {
    if (this.costName.trim().length === 0) {
      return
    }
    const yuan = parseInt(this.costAmount)
    const fen = (yuan === yuan ? yuan : 0) * 100
    const item = new CostItem()
    item.id = `c_${Date.now()}`
    item.name = this.costName.trim()
    item.amountFen = fen
    const next = this.costs.slice(0)
    next.unshift(item)
    this.costs = next
    await WorkshopStore.saveCosts(this.costs)
    this.costName = ''
    this.costAmount = ''
  }

  private async removeCost(id: string): Promise<void> {
    const next: CostItem[] = []
    for (const item of this.costs) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    this.costs = next
    await WorkshopStore.saveCosts(this.costs)
  }

  private async addStep(): Promise<void> {
    if (this.stepText.trim().length === 0) {
      return
    }
    const item = new ChecklistItem()
    item.id = `s_${Date.now()}`
    item.text = this.stepText.trim()
    item.done = false
    const next = this.checklist.slice(0)
    next.unshift(item)
    this.checklist = next
    await WorkshopStore.saveChecklist(this.checklist)
    this.stepText = ''
  }

  private async toggleStep(id: string): Promise<void> {
    const next: ChecklistItem[] = []
    for (const item of this.checklist) {
      const copy = new ChecklistItem()
      copy.id = item.id
      copy.text = item.text
      copy.done = item.id === id ? !item.done : item.done
      next.push(copy)
    }
    this.checklist = []
    this.checklist = next
    await WorkshopStore.saveChecklist(this.checklist)
  }

  private async removeStep(id: string): Promise<void> {
    const next: ChecklistItem[] = []
    for (const item of this.checklist) {
      if (item.id !== id) {
        next.push(item)
      }
    }
    this.checklist = next
    await WorkshopStore.saveChecklist(this.checklist)
  }

  build() {
    Column() {
      if (!this.embedded) {
        AppHeader({ title: '制作助手', subtitle: '计时 · 换算 · 清单 · 成本 · 本机持久保存' })
      }
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '制作计时', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text(WorkshopStore.format(this.elapsed))
                .fontSize(Theme.type.title1)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.running ? '计时进行中，可用于记录一件作品耗时' : '开始后可随时暂停，适合分步制作')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppButton({
                    label: this.running ? '暂停' : '开始',
                    variant: 'primary',
                    onTap: (): void => {
                      if (this.running) {
                        void this.handlePause()
                      } else {
                        void this.handleStart()
                      }
                    }
                  })
                }.layoutWeight(1)
                Column() {
                  AppButton({
                    label: '清零',
                    variant: 'secondary',
                    onTap: (): void => { void this.handleReset() }
                  })
                }.layoutWeight(1)
              }.width('100%')
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          AppCard({ title: '尺寸换算', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text('输入边长（厘米），实时换算英寸与裁切建议')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.cmText, placeholder: '例如 15 或 12.5' })
                .width('100%')
                .type(InputType.NUMBER_DECIMAL)
                .onChange((v: string): void => { void this.onCmChange(v) })
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.sizePresets, (p: SizePreset) => {
                    Text(p.label)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.cmText === p.cm ?
                        Theme.colors().textOnInverse : Theme.colors().textSecondary)
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .backgroundColor(this.cmText === p.cm ?
                        Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { void this.onCmChange(p.cm) })
                  }, (p: SizePreset) => p.cm)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
              Text(this.convertSummary)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandDeep)
                .width('100%')
              ForEach(this.convertRows, (row: ConvertRow) => {
                Row() {
                  Text(row.label)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textSecondary)
                    .layoutWeight(1)
                  Text(row.value)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().textPrimary)
                }.width('100%')
              }, (row: ConvertRow) => row.key)
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          AppCard({ title: '布料用量估算', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text('输入裁片宽与高，估算面积与留线长度')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.fabricWidth, placeholder: '宽 cm' })
                  .layoutWeight(1)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string): void => {
                    this.fabricWidth = v
                    this.rebuildFabric()
                  })
                TextInput({ text: this.fabricHeight, placeholder: '高 cm' })
                  .layoutWeight(1)
                  .type(InputType.NUMBER_DECIMAL)
                  .onChange((v: string): void => {
                    this.fabricHeight = v
                    this.rebuildFabric()
                  })
              }.width('100%')
              Text(this.fabricSummary)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          AppCard({ title: '制作步骤清单', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text(`已完成 ${this.checklistDoneCount()} / ${this.checklist.length} 步`)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandDeep)
                .width('100%')
              Text('跟做教程时可勾选步骤，进度保存在本机')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.stepText, placeholder: '添加一步，如：裁剪布料' })
                .width('100%')
                .onChange((v: string) => { this.stepText = v })
              AppButton({
                label: '添加步骤',
                variant: 'secondary',
                onTap: (): void => { void this.addStep() }
              })
              ForEach(this.checklist, (item: ChecklistItem) => {
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppIcon({
                      name: item.done ? 'check' : 'empty',
                      iconSize: Theme.icon.sm,
                      color: item.done ? Theme.colors().success : Theme.colors().textSecondary
                    })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  Text(item.text)
                    .fontSize(Theme.type.subhead)
                    .fontColor(item.done ? Theme.colors().textSecondary : Theme.colors().textPrimary)
                    .decoration({ type: item.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                    .layoutWeight(1)
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.removeStep(item.id) })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { void this.toggleStep(item.id) })
              }, (item: ChecklistItem) => `${item.id}_${item.done ? '1' : '0'}`)
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          AppCard({ title: '材料成本', variant: 'outlined' }) {
            Column({ space: Theme.space.s3 }) {
              Text(`合计 ${WorkshopStore.yuanLabel(WorkshopStore.totalFen(this.costs))}`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              TextInput({ text: this.costName, placeholder: '材料名称，如 棉线一捆' })
                .width('100%')
                .onChange((v: string) => { this.costName = v })
              TextInput({ text: this.costAmount, placeholder: '金额（元，整数）' })
                .width('100%')
                .type(InputType.Number)
                .onChange((v: string) => { this.costAmount = v })
              AppButton({
                label: '记一笔',
                variant: 'primary',
                onTap: (): void => { void this.addCost() }
              })
              ForEach(this.costs, (item: CostItem) => {
                Row({ space: Theme.space.s2 }) {
                  Column({ space: 2 }) {
                    Text(item.name)
                      .fontSize(Theme.type.subhead)
                      .fontColor(Theme.colors().textPrimary)
                    Text(WorkshopStore.yuanLabel(item.amountFen))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
                  }
                  .width(44)
                  .height(44)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.removeCost(item.id) })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
              }, (item: CostItem) => item.id)
            }.width('100%').alignItems(HorizontalAlign.Start)
          }

          AppCard({ title: '手作参数速查', variant: 'glass' }) {
            Column({ space: Theme.space.s2 }) {
              Text('刺绣：常用针距 2–3 mm，回针固定起止点')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text('编织：起针数 ≈ 胸围 cm × 0.8（粗线取小值）')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text('陶艺：练泥含水 18–22%，晾至不粘手再塑形')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text('拼布：缝份默认 0.7 cm，对角线裁切需加 2 cm')
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }.width('100%').alignItems(HorizontalAlign.Start)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
