import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppTextField } from '../design-system/AppTextField'
import { MoveItem, PlanItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

class ComboRow {
  id: string = ''
  name: string = ''
}

@Component
export struct ComboEditorPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop seedId: string = ''
  @State name: string = '我的训练方案'
  @State minutesText: string = '20'
  @State restText: string = '30'
  @State note: string = ''
  @State rows: ComboRow[] = []
  @State catalog: MoveItem[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    this.catalog = MoveLibrary.all()
    if (this.seedId.length > 0) {
      if (this.seedId.indexOf('|') >= 0) {
        const ids = MoveLibrary.splitIds(this.seedId)
        for (const id of ids) {
          this.addId(id)
        }
      } else {
        this.addId(this.seedId)
      }
    }
  }

  private addId(id: string): void {
    for (const r of this.rows) {
      if (r.id === id) {
        return
      }
    }
    const m = MoveLibrary.find(id)
    if (m === undefined) {
      return
    }
    const row = new ComboRow()
    row.id = m.id
    row.name = m.name
    const next: ComboRow[] = []
    for (const it of this.rows) {
      next.push(it)
    }
    next.push(row)
    this.rows = next
  }

  private removeAt(index: number): void {
    const next: ComboRow[] = []
    let i = 0
    for (const it of this.rows) {
      if (i !== index) {
        next.push(it)
      }
      i++
    }
    this.rows = next
  }

  private move(index: number, dir: number): void {
    const target = index + dir
    if (target < 0 || target >= this.rows.length) {
      return
    }
    const next: ComboRow[] = []
    for (const it of this.rows) {
      next.push(it)
    }
    const tmp = next[index]
    next[index] = next[target]
    next[target] = tmp
    this.rows = next
  }

  private async save(): Promise<void> {
    if (this.rows.length === 0) {
      this.toastText = '至少加入 1 个动作'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    const plan = new PlanItem()
    plan.id = TuceStore.newId('plan')
    plan.name = this.name.trim().length > 0 ? this.name.trim() : '未命名方案'
    const ids: string[] = []
    const reps: string[] = []
    for (const r of this.rows) {
      ids.push(r.id)
      reps.push('10')
    }
    plan.moveIds = ids.join('|')
    plan.reps = reps.join('|')
    plan.minutes = parseInt(this.minutesText, 10)
    plan.restSec = parseInt(this.restText, 10)
    plan.note = this.note
    plan.createdAt = Date.now()
    await TuceStore.savePlan(plan)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          AppTextField({
            text: this.name,
            placeholder: '方案名称，如晨间活力组合',
            onChange: (v: string): void => { this.name = v }
          })
          Row({ space: Theme.space.s3 }) {
            AppTextField({
              text: this.minutesText,
              placeholder: '时长(分钟)',
              inputType: InputType.Number,
              onChange: (v: string): void => { this.minutesText = v }
            }).layoutWeight(1)
            AppTextField({
              text: this.restText,
              placeholder: '休息(秒)',
              inputType: InputType.Number,
              onChange: (v: string): void => { this.restText = v }
            }).layoutWeight(1)
          }
          .width('100%')
          AppTextField({
            text: this.note,
            placeholder: '训练备注（可选）',
            onChange: (v: string): void => { this.note = v }
          })

          Text('已选动作（点上下调整顺序）')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.rows, (row: ComboRow, index: number) => {
            Row({ space: Theme.space.s2 }) {
              Text(`${index + 1}. ${row.name}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Row() {
                Text('上')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width(36)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.move(index, -1) })
              Row() {
                Text('下')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width(36)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.move(index, 1) })
              Row() {
                Text('移除')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().danger)
              }
              .width(44)
              .height(36)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.removeAt(index) })
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
          }, (row: ComboRow) => row.id)

          Text('从图鉴添加')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .margin({ top: Theme.space.s2 })
          ForEach(this.catalog, (m: MoveItem) => {
            Row() {
              Text(`${m.category} · ${m.name}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .onClick((): void => { this.addId(m.id) })
          }, (m: MoveItem) => m.id)

          AppButton({ label: '保存训练方案', variant: 'primary', onTap: (): void => { void this.save() } })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
