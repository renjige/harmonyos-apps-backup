import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { FieldRecord, GewuPlan } from '../../models/FieldModels'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct PlanDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('practiceFocusId') @Watch('onFocusChange') focusId: string = ''
  onChanged: () => void = () => {}
  @State plan: GewuPlan = new GewuPlan()
  @State done: number = 0
  @State recs: FieldRecord[] = []
  @State confirmDel: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onFocusChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const p = await FieldStore.findPlan(this.focusId)
    if (p === undefined) {
      this.plan = new GewuPlan()
      this.recs = []
      this.done = 0
      return
    }
    this.plan = p
    const all = await FieldStore.loadRecords()
    this.done = FieldStore.planDoneCount(p, all)
    const matched: FieldRecord[] = []
    for (const r of all) {
      if (!DateHelper.inRange(r.dateKey, p.startKey, p.endKey)) {
        continue
      }
      if (p.atlasKind !== 'all' && r.atlasKind !== p.atlasKind) {
        continue
      }
      matched.push(r)
    }
    this.recs = matched
  }

  private pct(): number {
    if (this.plan.targetCount <= 0) {
      return 0
    }
    const v = (this.done / this.plan.targetCount) * 100
    if (v > 100) {
      return 100
    }
    return v
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async remove(): Promise<void> {
    await FieldStore.deletePlan(this.plan.id)
    this.onChanged()
    this.showToast('功课已删除')
    setTimeout((): void => { GewuDetailNav.closePractice() }, 400)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.plan.title.length > 0 ? this.plan.title : '功课',
        onClose: (): void => { GewuDetailNav.closePractice() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(this.plan.rangeLabel())
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Text(this.plan.atlasKind === 'all' ? '图鉴范围：不限' : `图鉴范围：${this.plan.atlasKind}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Progress({ value: this.pct(), total: 100, type: ProgressType.Linear })
          .width('100%')
          .color(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
        Text(`已完成 ${this.done} / ${this.plan.targetCount}`)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
        if (this.plan.note.length > 0) {
          Text(this.plan.note)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        AppButton({
          label: '写下观察计入进度',
          variant: 'primary',
          onTap: (): void => {
            GewuDetailNav.closePractice()
            GewuDetailNav.openEditor('new')
          }
        })
        AppButton({
          label: '编辑功课',
          variant: 'secondary',
          onTap: (): void => { GewuDetailNav.openPractice('plan', this.plan.id) }
        })
        Text('期内观察')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        if (this.recs.length === 0) {
          AppEmpty({
            title: '还没有计入的观察',
            description: '在周期内写下匹配图鉴范围的记录，进度会自动增加。',
            actionLabel: '写第一条',
            onAction: (): void => {
              GewuDetailNav.closePractice()
              GewuDetailNav.openEditor('new')
            }
          })
        } else {
          ForEach(this.recs, (r: FieldRecord) => {
            Column({ space: 4 }) {
              Text(r.title)
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(`${r.dateKey} · ${r.atlasKind}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .onClick((): void => {
              GewuDetailNav.closePractice()
              GewuDetailNav.openRecord(r.id)
            })
          }, (r: FieldRecord) => r.id)
        }
        if (!this.confirmDel) {
          AppButton({
            label: '删除这份功课',
            variant: 'ghost',
            onTap: (): void => { this.confirmDel = true }
          })
        } else {
          Text('删除后不可恢复，确认删除？')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '取消',
                variant: 'ghost',
                onTap: (): void => { this.confirmDel = false }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '确认删除',
                variant: 'danger',
                onTap: (): void => { void this.remove() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        Row().height(Theme.space.s10)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
