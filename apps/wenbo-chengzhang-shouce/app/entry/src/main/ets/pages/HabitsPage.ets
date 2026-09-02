import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateHabitRequest, CheckinHabitRequest, GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { AuthService } from '../services/AuthService'
import { HabitDetailPane } from '../components/detail/HabitDetailPane'

@Component
export struct HabitsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State habits: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formCategory: string = '学习'
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @State selectedId: string = ''
  @State detailToken: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.habits = await GrowthBizService.loadHabits(this.currentUsername)
    } else {
      this.habits = []
    }
    this.loading = false
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private openForm(): void {
    if (!AuthService.requireAuth('create_habit')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formCategory = '学习'
    this.formError = ''
    this.showForm = true
  }

  private async submitHabit(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写习惯名称'
      return
    }
    this.submitting = true
    const req = new CreateHabitRequest()
    req.title = this.formTitle.trim()
    req.category = this.formCategory
    req.userId = this.currentUsername
    const created = await GrowthBizService.createHabit(req)
    this.submitting = false
    if (created !== undefined) {
      this.showForm = false
      await this.reload()
      this.showToast('习惯已创建')
    } else {
      this.formError = GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '创建失败'
    }
  }

  private async quickCheckin(item: GrowthRecordItem): Promise<void> {
    if (!AuthService.requireAuth('checkin_habit')) {
      this.onRequireAuth()
      return
    }
    const req = new CheckinHabitRequest()
    const updated = await GrowthBizService.checkinHabit(item.id, req)
    if (updated !== undefined) {
      await this.reload()
      this.showToast('今日已打卡')
    } else {
      this.showToast(GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '打卡失败')
    }
  }

  private categories(): string[] {
    const list: string[] = []
    list.push('学习')
    list.push('运动')
    list.push('作息')
    list.push('情绪')
    return list
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('习惯打卡')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Column() {
            AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.openForm() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.showForm) {
          this.FormPane()
        } else if (this.loading) {
          AppLoading({ label: '加载习惯…' }).layoutWeight(1)
        } else if (this.habits.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有习惯',
              description: AuthService.isLoggedIn()
                ? '创建阅读、运动、早起等习惯，每天打卡累积连续天数'
                : '登录后可创建习惯并每日打卡',
              actionLabel: '创建习惯',
              onAction: (): void => { this.openForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.habits, (item: GrowthRecordItem) => {
              ListItem() {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 4 }) {
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`${item.category} · 连续 ${item.progress} 天`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Text(GrowthBizService.habitCheckedToday(item) ? '已打卡' : '打卡')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandOnPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimary)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { void this.quickCheckin(item) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => {
                  this.selectedId = item.id
                  this.detailToken += 1
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (item: GrowthRecordItem) => item.id)
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.selectedId.length > 0) {
        HabitDetailPane({
          itemId: this.selectedId,
          refreshToken: this.detailToken,
          onRequireAuth: (): void => { this.onRequireAuth() },
          onHabitUpdated: (): void => { void this.reload() },
          onClose: (): void => {
            this.selectedId = ''
            void this.reload()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
      }

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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormPane() {
    Column({ space: Theme.space.s4 }) {
      Text('新建习惯')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      TextInput({ text: this.formTitle, placeholder: '例如：晨读 20 分钟' })
        .onChange((v: string) => { this.formTitle = v })
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        ForEach(this.categories(), (c: string) => {
          Text(c)
            .fontSize(Theme.type.caption)
            .fontColor(this.formCategory === c ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.formCategory === c ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.formCategory = c })
        }, (c: string) => c)
      }
      .width('100%')
      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      Text(this.submitting ? '创建中…' : '保存习惯')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandOnPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding(14)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { void this.submitHabit() })
      Text('取消')
        .fontSize(Theme.type.subhead)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding(10)
        .onClick((): void => { this.showForm = false })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    .width('100%')
    .layoutWeight(1)
  }
}
