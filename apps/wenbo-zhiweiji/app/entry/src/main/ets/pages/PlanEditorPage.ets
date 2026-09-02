import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LearnPlan } from '../models/ZhiweiModels'
import { ZhiweiNav } from '../services/ZhiweiNav'
import { ZhiweiStore } from '../services/ZhiweiStore'

@Component
export struct PlanEditorPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State plan: LearnPlan = new LearnPlan()
  @State done: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    const active = ZhiweiStore.activePlan()
    if (active !== null) {
      this.plan = active
      this.done = ZhiweiStore.planProgress(active)
    } else {
      this.plan = new LearnPlan()
      this.plan.title = '本周消化 3 条'
      this.plan.targetCount = 3
      this.plan.metric = 'digest_done'
      this.plan.period = 'week'
      this.done = 0
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.plan.title.trim().length === 0) {
      this.showToast('请填写计划名称')
      return
    }
    if (this.plan.targetCount < 1) {
      this.showToast('目标至少为 1')
      return
    }
    const ok = await ZhiweiStore.savePlan(this.plan)
    if (ok) {
      this.showToast('学习计划已保存')
      this.reload()
      return
    }
    this.showToast('保存失败，请重试')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colorOf(this.themeEpoch).textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick(() => ZhiweiNav.closePlan())
          Text('学习计划')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('设定本周可完成的小目标，消化或记录都会计入进度。')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            Text('计划名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            TextInput({ text: this.plan.title, placeholder: '例如：本周消化 5 条' })
              .width('100%')
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.plan.title = v })
            Text('目标条数')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colorOf(this.themeEpoch).textSecondary)
              .width('100%')
            TextInput({ text: `${this.plan.targetCount}`, placeholder: '3' })
              .width('100%')
              .height(44)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
              .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => {
                const n = parseInt(v, 10)
                if (!isNaN(n) && n > 0) {
                  this.plan.targetCount = n
                }
              })
            Column({ space: 6 }) {
              Text(`当前进度 ${this.done} / ${this.plan.targetCount}`)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colorOf(this.themeEpoch).textPrimary)
                .width('100%')
              Progress({
                value: this.done,
                total: this.plan.targetCount > 0 ? this.plan.targetCount : 1,
                type: ProgressType.Linear
              })
                .width('100%')
                .color(Theme.colorOf(this.themeEpoch).brandPrimary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colorOf(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.card)
            AppButton({
              label: '保存计划',
              variant: 'primary',
              onTap: (): void => { void this.save() }
            })
            Blank().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colorOf(this.themeEpoch).surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
