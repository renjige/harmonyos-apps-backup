import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextInputField } from '../design-system/AppTextInputField'
import { AppIcon } from '../design-system/AppIcon'
import { PlanSlot, WeekPlan, WorkoutTypeOption } from '../../models/WorkoutModels'
import { DateHelper } from '../../services/DateHelper'
import { PlanStore } from '../../services/PlanStore'
import { WorkoutTypeGrid } from './WorkoutTypeGrid'

@Component
export struct WeekPlanSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  @State plan: WeekPlan = WeekPlan.empty(DateHelper.weekKey(DateHelper.todayKey()))
  @State mottoInput: string = ''
  @State editWeekday: number = -1
  @State minutesInput: string = '30'
  @State toastText: string = ''
  @State planReady: boolean = false
  @State planRevision: number = 0

  aboutToAppear(): void {
    const wk = DateHelper.weekKey(DateHelper.todayKey())
    this.plan = WeekPlan.empty(wk)
    void this.reload()
  }

  private async reload(): Promise<void> {
    const wk = DateHelper.weekKey(DateHelper.todayKey())
    const loaded = await PlanStore.loadPlan(wk)
    this.plan = loaded
    this.mottoInput = loaded.motto
    this.planReady = true
    this.planRevision++
  }

  private bumpPlan(): void {
    this.planRevision++
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private slotAt(weekday: number): PlanSlot {
    for (const s of this.plan.slots) {
      if (s.weekday === weekday) {
        return s
      }
    }
    return new PlanSlot()
  }

  private replaceSlot(next: PlanSlot): void {
    const copy = WeekPlan.empty(this.plan.weekKey)
    copy.motto = this.mottoInput
    const slots: PlanSlot[] = []
    for (const s of this.plan.slots) {
      if (s.weekday === next.weekday) {
        slots.push(PlanSlot.cloneOf(next))
      } else {
        slots.push(PlanSlot.cloneOf(s))
      }
    }
    copy.slots = slots
    this.plan = copy
    this.bumpPlan()
  }

  private toggleDay(weekday: number): void {
    const s = PlanSlot.cloneOf(this.slotAt(weekday))
    s.enabled = !s.enabled
    this.replaceSlot(s)
    if (s.enabled) {
      this.openEdit(weekday)
    }
  }

  private openEdit(weekday: number): void {
    const cur = this.slotAt(weekday)
    this.minutesInput = `${cur.targetMinutes}`
    this.editWeekday = weekday
    if (!cur.enabled) {
      const s = PlanSlot.cloneOf(cur)
      s.enabled = true
      this.replaceSlot(s)
    }
  }

  private applyType(key: string): void {
    if (this.editWeekday < 0) {
      return
    }
    const s = PlanSlot.cloneOf(this.slotAt(this.editWeekday))
    s.typeKey = key
    s.enabled = true
    this.replaceSlot(s)
  }

  private applyMinutes(v: string): void {
    this.minutesInput = v
    if (this.editWeekday < 0) {
      return
    }
    const mins = parseInt(v, 10)
    const s = PlanSlot.cloneOf(this.slotAt(this.editWeekday))
    s.targetMinutes = isNaN(mins) || mins <= 0 ? 30 : mins
    s.enabled = true
    this.replaceSlot(s)
  }

  private fillStarter(): void {
    const next = PlanStore.applyStarter(this.plan)
    next.motto = this.mottoInput
    this.plan = next
    this.bumpPlan()
    this.showToast('已填入交叉训练周训模板，可再改')
  }

  private async save(): Promise<void> {
    if (!this.planReady) {
      this.showToast('正在加载周训，请稍候再保存')
      return
    }
    if (this.plan.weekKey.length < 3) {
      this.plan.weekKey = DateHelper.weekKey(DateHelper.todayKey())
    }
    let anyEnabled = false
    for (const s of this.plan.slots) {
      if (s.enabled) {
        anyEnabled = true
      }
    }
    if (!anyEnabled) {
      this.showToast('请先点某一天右侧「开启」，或填入模板')
      return
    }
    this.plan.motto = this.mottoInput.trim()
    await PlanStore.savePlan(this.plan)
    this.showToast('周训图志已保存')
    this.onSaved()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
            .onClick((): void => { this.onClose() })
          Text('周训图志')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Row().width(28)
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('点某一天 → 选类型与分钟；或点右侧「开启」快速排期。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')

            AppButton({
              label: '填入交叉训练模板',
              variant: 'secondary',
              onTap: (): void => { this.fillStarter() }
            })

            ForEach(this.plan.slots, (s: PlanSlot) => {
              this.SlotRow(s.weekday)
            }, (s: PlanSlot) => `${s.weekday}-${s.enabled}-${s.typeKey}-${s.targetMinutes}-${this.planRevision}`)

            if (this.editWeekday >= 0) {
              Column({ space: Theme.space.s2 }) {
                Text(`编辑 ${this.slotAt(this.editWeekday).weekdayLabel}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                WorkoutTypeGrid({
                  selectedKey: this.slotAt(this.editWeekday).typeKey,
                  onSelect: (key: string): void => { this.applyType(key) }
                })
                AppTextInputField({
                  text: this.minutesInput,
                  placeholder: '目标分钟',
                  numeric: true,
                  onChange: (v: string): void => { this.applyMinutes(v) }
                })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
            }

            Column({ space: Theme.space.s2 }) {
              Text('本周图志寄语（可选）')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
              AppTextInputField({
                text: this.mottoInput,
                placeholder: '例如：这周把力量钉住三次',
                onChange: (v: string): void => { this.mottoInput = v }
              })
            }
            .width('100%')

            AppButton({
              label: '保存周训图志',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
            Row().height(Theme.space.s10)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .margin({ top: 48 })
          .backgroundColor('#1A2332')
          .borderRadius(Theme.radius.pill)
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SlotRow(weekday: number) {
    Row({ space: Theme.space.s3 }) {
      Column()
        .width(10)
        .height(10)
        .borderRadius(Theme.radius.pill)
        .backgroundColor(this.slotAt(weekday).enabled ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      Column({ space: 2 }) {
        Text(this.slotAt(weekday).weekdayLabel)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
        Text(this.slotAt(weekday).enabled ?
          `${WorkoutTypeOption.labelFor(this.slotAt(weekday).typeKey)} · ${this.slotAt(weekday).targetMinutes} 分钟` : '未排期 · 点右侧开启')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick((): void => { this.openEdit(weekday) })
      Text(this.slotAt(weekday).enabled ? '关闭' : '开启')
        .fontSize(Theme.type.bodyS)
        .fontColor(this.slotAt(weekday).enabled ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
        .fontWeight(FontWeight.Medium)
        .padding({ left: 14, right: 14, top: 10, bottom: 10 })
        .backgroundColor(this.slotAt(weekday).enabled ?
          Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .constraintSize({ minWidth: 56, minHeight: 44 })
        .onClick((): void => { this.toggleDay(weekday) })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.editWeekday === weekday ?
      Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .constraintSize({ minHeight: 56 })
  }
}
