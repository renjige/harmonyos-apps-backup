import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreatePlanRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { AuthService } from '../services/AuthService'
import { GrowthService } from '../services/GrowthService'
import { InspirationConvertService } from '../services/InspirationConvertService'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop showBack: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onClose: () => void = () => {}
  onPlanCreated: () => void = () => {}
  @State plans: InspirationItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formGoal: string = ''
  @State formProgress: string = '0'
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.plans = await InspirationBizService.loadCreativePlans(this.currentUsername)
    } else {
      this.plans = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formGoal = ''
    this.formProgress = '0'
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    // Overlay 模式下（showBack）保持底栏隐藏，避免计划列表被底栏顶穿
    if (!this.showBack) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private parseProgress(): number {
    const n = parseInt(this.formProgress, 10)
    if (isNaN(n)) {
      return 0
    }
    return Math.min(100, Math.max(0, n))
  }

  private async submitPlan(): Promise<void> {
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写计划名称'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreatePlanRequest()
    req.title = this.formTitle.trim()
    req.goal = this.formGoal.trim()
    req.summary = req.goal.length > 0 ? req.goal : req.title
    req.progress = this.parseProgress()
    req.userId = this.currentUsername
    const created = await InspirationBizService.createCreativePlan(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      await GrowthService.afterEventAuto(
        this.currentUsername, 'plan', created.title, 'plan', created.id
      )
      this.onPlanCreated()
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.showBack) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { this.onClose() })
            Text('创意计划')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
        } else {
          AppHeader({ title: '计划', subtitle: '创意项目目标与进度跟踪' })
        }
        if (this.loading) {
          AppLoading({ label: '加载计划…' }).layoutWeight(1)
        } else if (this.plans.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无创意计划',
              description: AuthService.isLoggedIn()
                ? '创建计划，跟踪你的创意项目进度'
                : '登录后可创建并同步创意计划',
              actionLabel: '创建计划',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.plans, (item: InspirationItem) => {
                Column({ space: Theme.space.s3 }) {
                  Row() {
                    Column({ space: 4 }) {
                      Text(item.title)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                      Text(InspirationConvertService.listSubtitle(item.goal, item.summary))
                        .fontSize(Theme.type.footnote)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                      if (InspirationConvertService.stepProgressText(item.goal).length > 0) {
                        Text(InspirationConvertService.stepProgressText(item.goal))
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().brandPrimary)
                          .width('100%')
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    Text(`${item.progress}%`)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.colors().brandAccent)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width('100%')
                  Stack({ alignContent: Alignment.Start }) {
                    Row()
                      .width('100%')
                      .height(8)
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                    Row()
                      .width(`${item.progress}%`)
                      .height(8)
                      .backgroundColor(Theme.colors().success)
                      .borderRadius(Theme.radius.pill)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { InspirationDetailNav.openPlan(item.id) })
              }, (item: InspirationItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.PlanFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PlanFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建创意计划')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column({ space: Theme.space.s4 }) {
        Column({ space: 6 }) {
          Text('计划名称')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formTitle, placeholder: '例如：品牌视觉升级' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('目标')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextArea({ text: this.formGoal, placeholder: '描述计划要达成的创意目标…' })
            .width('100%')
            .height(120)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formGoal = v })
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('初始进度（0–100）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formProgress, placeholder: '0' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formProgress = v })
        }
        .width('100%')

        AppButton({
          label: this.submitting ? '创建中…' : '创建计划',
          disabled: this.submitting,
          onTap: (): void => { void this.submitPlan() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
