import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import {
  CreatePlanRequest,
  CreateRecordRequest,
  GoalStepItem,
  GrowthRecordItem
} from '../models/GrowthModels'
import { StuckKindItem, StuckWorkshop } from '../models/StuckWorkshop'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct StuckWorkshopPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onSaved: () => void = () => {}
  @State kind: string = ''
  @State answer1: string = ''
  @State answer2: string = ''
  @State answer3: string = ''
  @State kindItems: StuckKindItem[] = StuckWorkshop.kinds()
  @State q1: string[] = []
  @State q2: string[] = []
  @State q3: string[] = StuckWorkshop.question3()
  @State goals: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State submitting: boolean = false
  @State toastText: string = ''
  @State errorText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      const all = await GrowthBizService.loadCreativePlans(this.currentUsername)
      const active: GrowthRecordItem[] = []
      for (const g of all) {
        if (g.progress < 100) {
          active.push(g)
        }
      }
      this.goals = active
    } else {
      this.goals = []
    }
    this.loading = false
  }

  private generatedStep(): string {
    if (this.kind.length === 0 || this.answer1.length === 0 ||
      this.answer2.length === 0 || this.answer3.length === 0) {
      return ''
    }
    return StuckWorkshop.stepOf(this.kind, this.answer1, this.answer2, this.answer3)
  }

  private async commit(): Promise<void> {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    const step = this.generatedStep()
    if (step.length === 0) {
      this.errorText = '请先选完卡点、动作和时间'
      return
    }
    this.submitting = true
    this.errorText = ''
    let goal = this.goals.length > 0 ? this.goals[0] : undefined
    if (goal === undefined) {
      const req = new CreatePlanRequest()
      req.title = `解卡行动 · ${StuckWorkshop.kindTitle(this.kind)}`
      req.goal = step
      req.summary = step
      const first = new GoalStepItem()
      first.title = step
      const steps: GoalStepItem[] = []
      steps.push(first)
      req.cardsJson = GoalStepItem.encode(steps)
      req.userId = this.currentUsername
      goal = await GrowthBizService.createCreativePlan(req)
    } else {
      goal = await GrowthBizService.appendGoalStep(goal, step)
    }
    const log = new CreateRecordRequest()
    log.title = `卡住工坊 · ${StuckWorkshop.kindTitle(this.kind)}`
    log.body = step
    log.summary = step
    const tags: string[] = []
    tags.push('卡住工坊')
    log.tags = tags
    log.coverKey = 'hero_rain_walk'
    log.userId = this.currentUsername
    await GrowthBizService.createRecord(log)
    this.submitting = false
    if (goal !== undefined) {
      this.onSaved()
      this.toastText = '已写入目标步骤'
      const id = goal.id
      setTimeout(() => {
        this.toastText = ''
        this.onClose()
        if (id.length > 0) {
          GrowthDetailNav.openPlan(id)
        }
      }, 700)
    } else {
      this.errorText = GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '写入失败'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '卡住工坊', subtitle: '三步点选，生成一条可勾选的最小动作' })
        if (this.loading) {
          AppLoading({ label: '加载目标…' }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Image($r('app.media.hero_rain_walk'))
                .width('100%')
                .height(132)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.xl)
              Text('1. 现在卡在哪？')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.kindItems, (k: StuckKindItem) => {
                Column({ space: 4 }) {
                  Text(k.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.kind === k.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(k.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.kind === k.id ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.kind === k.id ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => {
                  this.kind = k.id
                  this.answer1 = ''
                  this.answer2 = ''
                  this.answer3 = ''
                  this.q1 = StuckWorkshop.question1(k.id)
                  this.q2 = StuckWorkshop.question2(k.id)
                })
              }, (k: StuckKindItem) => k.id)

              if (this.kind.length > 0) {
                Text('2. 最接近的原因')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.q1, (opt: string) => {
                    Text(opt)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.answer1 === opt ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.answer1 === opt ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.answer1 = opt })
                  }, (opt: string) => opt)
                }
                .width('100%')
                Text('3. 下一步只做这一件')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.q2, (opt: string) => {
                    Text(opt)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.answer2 === opt ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.answer2 === opt ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.answer2 = opt })
                  }, (opt: string) => `q2-${opt}`)
                }
                .width('100%')
                Text('4. 什么时候完成')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.q3, (opt: string) => {
                    Text(opt)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.answer3 === opt ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.answer3 === opt ?
                        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.answer3 = opt })
                  }, (opt: string) => `q3-${opt}`)
                }
                .width('100%')
              }

              if (this.generatedStep().length > 0) {
                Text(this.generatedStep())
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.xl)
              }
              if (this.errorText.length > 0) {
                Text(this.errorText)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
              }
              AppButton({
                label: this.submitting ? '写入中…' : '写入进行中目标并勾选',
                onTap: (): void => { void this.commit() }
              })
              AppButton({
                label: '返回',
                variant: 'secondary',
                onTap: (): void => { this.onClose() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
