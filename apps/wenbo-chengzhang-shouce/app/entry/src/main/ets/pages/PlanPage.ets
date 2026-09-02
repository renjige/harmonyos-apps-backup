import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreatePlanRequest, GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct PlanPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State plans: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formGoal: string = ''
  @State formProgress: string = '0'
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('accessToken') @Watch('onLoginChange') accessToken: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onLoginChange(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.plans = []
      this.loading = false
      return
    }
    this.loading = true
    try {
      const uid = this.resolveUserId()
      if (uid.length === 0) {
        this.plans = []
        return
      }
      this.plans = await GrowthBizService.loadCreativePlans(uid)
    } catch {
      this.plans = []
    } finally {
      this.loading = false
    }
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formGoal = ''
    this.formProgress = '0'
    this.formError = ''
    this.submitting = false
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    this.submitting = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private sanitizeProgressInput(raw: string): string {
    let digits = ''
    for (let i = 0; i < raw.length; i++) {
      const ch = raw.charAt(i)
      if (ch >= '0' && ch <= '9') {
        digits += ch
      }
    }
    if (digits.length === 0) {
      return '0'
    }
    if (digits.length > 3) {
      digits = digits.substring(0, 3)
    }
    const n = parseInt(digits, 10)
    if (n > 100) {
      return '100'
    }
    return `${n}`
  }

  private parseProgress(): number {
    const n = parseInt(this.formProgress, 10)
    if (isNaN(n)) {
      return 0
    }
    return Math.min(100, Math.max(0, n))
  }

  private resolveUserId(): string {
    if (this.currentUsername.length > 0) {
      return this.currentUsername
    }
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null && u.length > 0 ? u : ''
  }

  private async submitPlan(): Promise<void> {
    if (this.submitting) {
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写目标名称'
      this.showToast('请填写目标名称')
      return
    }
    if (!AuthService.isLoggedIn()) {
      this.formError = '请先登录后再创建目标'
      this.showToast('请先登录后再创建目标')
      this.onRequireAuth()
      return
    }
    const userId = this.resolveUserId()
    if (userId.length === 0) {
      this.formError = '请先登录后再创建目标'
      this.showToast('请先登录后再创建目标')
      this.onRequireAuth()
      return
    }
    this.submitting = true
    this.formError = ''
    this.showToast('正在创建…')
    try {
      const req = new CreatePlanRequest()
      req.title = this.formTitle.trim()
      req.goal = this.formGoal.trim()
      req.summary = req.goal.length > 0 ? req.goal : req.title
      req.progress = this.parseProgress()
      req.userId = userId
      const created = await GrowthBizService.createCreativePlan(req)
      if (created !== undefined) {
        this.showToast('成长目标已创建')
        this.closeForm()
        void this.reload()
      } else {
        const msg = GrowthBizService.lastError
        const errText = msg.length > 0 ? msg : '创建失败，请稍后重试'
        this.formError = errText
        this.showToast(errText)
      }
    } catch {
      this.formError = '创建失败，请稍后重试'
      this.showToast('创建失败，请稍后重试')
    } finally {
      this.submitting = false
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '成长目标', subtitle: '设定目标并跟踪完成进度' })
        if (this.loading) {
          AppLoading({ label: '加载目标…' }).layoutWeight(1)
        } else if (this.plans.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无成长目标',
              description: AuthService.isLoggedIn()
                ? '创建成长目标，记录每一步进步'
                : '登录后可创建并同步成长目标',
              actionLabel: '创建目标',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.plans, (item: GrowthRecordItem) => {
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
                      Text(item.goal.length > 0 ? item.goal : item.summary)
                        .fontSize(Theme.type.footnote)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
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
                .onClick((): void => { GrowthDetailNav.openPlan(item.id) })
              }, (item: GrowthRecordItem) => item.id)
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
        Column() {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.closeForm() })
            Text('创建成长目标')
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
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
          }

          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 6 }) {
                Text('目标名称')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                TextInput({ text: this.formTitle, placeholder: '例如：每日阅读 30 分钟' })
                  .width('100%')
                  .height(44)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onChange((v: string) => { this.formTitle = v })
              }
              .width('100%')

              Column({ space: 6 }) {
                Text('目标描述')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                TextArea({ text: this.formGoal, placeholder: '描述你想达成的成长目标…' })
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
                  .type(InputType.Number)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onChange((v: string) => { this.formProgress = this.sanitizeProgressInput(v) })
              }
              .width('100%')

              Text(this.submitting ? '创建中…' : '创建成长目标')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().brandOnPrimary)
                .textAlign(TextAlign.Center)
                .width('100%')
                .padding({ top: 14, bottom: 14 })
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.lg)
                .opacity(this.submitting ? 0.55 : 1)
                .onClick((): void => { void this.submitPlan() })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s4,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(25)
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('#1B2A41')
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s8 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }
}
