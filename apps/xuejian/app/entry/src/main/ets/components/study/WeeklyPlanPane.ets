import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { WeeklyPlan, WeeklyPlanItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct WeeklyPlanPane {
  @StorageLink('studyDataEpoch') @Watch('onDataEpoch') studyDataEpoch: number = 0
  @State plan: WeeklyPlan = new WeeklyPlan()
  @State newTitle: string = ''
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDataEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.plan = await StudyStore.ensureWeeklyPlan()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async toggleItem(id: string): Promise<void> {
    await StudyStore.toggleWeeklyItem(id)
    await this.load()
    this.showToast('已更新本周计划')
  }

  private async addItem(): Promise<void> {
    const t = this.newTitle.trim()
    if (t.length === 0) {
      this.showToast('请填写计划内容')
      return
    }
    await StudyStore.addWeeklyItem(t)
    this.newTitle = ''
    await this.load()
    this.showToast('已加入本周计划')
  }

  private doneCount(): number {
    let n = 0
    for (const it of this.plan.items) {
      if (it.done) {
        n++
      }
    }
    return n
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('返回')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => { this.onClose() })
          Text('本周学习计划')
            .fontSize(Theme.type.subtitleM)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Blank().width(44)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(`完成 ${this.doneCount()}/${this.plan.items.length} 项 · 每周一自动重置`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.bodyMuted())
              .width('100%')

            ForEach(this.plan.items, (it: WeeklyPlanItem) => {
              Row({ space: 10 }) {
                Text(it.done ? '✓' : '○')
                  .fontSize(Theme.type.body)
                  .fontColor(it.done ? Theme.colors().success : Theme.colors().textPrimary)
                  .width(24)
                Text(it.title)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .decoration({ type: it.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(12)
              .constraintSize({ minHeight: 48 })
              .onClick((): void => { void this.toggleItem(it.id) })
            }, (it: WeeklyPlanItem) => it.id)

            Row({ space: 8 }) {
              TextInput({ text: this.newTitle, placeholder: '自定义本周目标（最多 5 条）' })
                .layoutWeight(1)
                .height(44)
                .fontColor(Theme.inputInk())
                .placeholderColor(Theme.inputHint())
                .backgroundColor(Theme.inputFill())
                .border({ width: 1, color: '#64748B' })
                .borderRadius(12)
                .onChange((v: string) => { this.newTitle = v })
              Text('添加')
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
                .padding({ left: 14, right: 14, top: 12, bottom: 12 })
                .backgroundColor('#1A2A4A')
                .borderRadius(12)
                .constraintSize({ minHeight: 44 })
                .onClick((): void => { void this.addItem() })
            }
            .width('100%')
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('#1A2A4A')
          .borderRadius(12)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
