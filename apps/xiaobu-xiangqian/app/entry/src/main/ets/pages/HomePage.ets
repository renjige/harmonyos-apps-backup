import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ProgressRing } from '../components/step/ProgressRing'
import { MicroGoalCard } from '../components/step/MicroGoalCard'
import { MicroGoalItem } from '../models/MicroGoalModels'
import { StepBizService } from '../services/StepBizService'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '小步向前'
  @Prop tagline: string = ''
  @StorageLink('accessToken') accessToken: string = ''
  @State goals: MicroGoalItem[] = []
  @State progress: number = 0
  @State streak: number = 0
  @State suggestions: string[] = []
  @State loading: boolean = true
  @State showAdd: boolean = false
  @State showComplete: boolean = false
  @State newTitle: string = ''
  @State newDesc: string = ''
  @State completeNote: string = ''
  @State activeGoalId: string = ''
  @State toastText: string = ''
  onOpenMessages: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onRefreshToken: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  private greeting(): string {
    const h = new Date().getHours()
    if (h < 12) {
      return '早上好，今天也要加油哦'
    }
    if (h < 18) {
      return '下午好，再完成一小步吧'
    }
    return '晚上好，回顾今日成长'
  }

  private dateLabel(): string {
    const d = new Date()
    return `${d.getMonth() + 1}月${d.getDate()}日`
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2600)
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  async reload(): Promise<void> {
    this.loading = true
    const stats = await StepBizService.loadStats()
    this.streak = stats.streakDays
    if (stats.todayTotal > 0) {
      this.progress = Math.round((stats.todayDone / stats.todayTotal) * 100)
    } else {
      this.progress = 0
    }
    this.goals = await StepBizService.loadTodayGoals()
    const journal = await StepBizService.loadJournal('')
    const insights = await StepBizService.loadInsights()
    this.suggestions = StepBizService.suggestMicroGoals(journal, insights)
    this.loading = false
  }

  private openAdd(): void {
    if (!this.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    if (this.goals.length >= 3) {
      this.showToast('每日最多 3 个微目标')
      return
    }
    this.newTitle = ''
    this.newDesc = ''
    this.showAdd = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async submitAdd(): Promise<void> {
    if (this.newTitle.trim().length === 0) {
      this.showToast('请填写微目标标题')
      return
    }
    const row = await StepBizService.createGoal(this.newTitle.trim(), this.newDesc.trim(), '日常')
    if (row === null) {
      this.showToast('创建失败，请稍后重试')
      return
    }
    this.showAdd = false
    AppStorage.setOrCreate('tabBarHidden', false)
    await this.reload()
  }

  private openComplete(id: string): void {
    this.activeGoalId = id
    this.completeNote = ''
    this.showComplete = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private async submitComplete(): Promise<void> {
    const ok = await StepBizService.completeGoal(this.activeGoalId, this.completeNote.trim())
    this.showComplete = false
    AppStorage.setOrCreate('tabBarHidden', false)
    if (!ok) {
      this.showToast('打卡失败')
      return
    }
    await this.reload()
    this.showToast('太棒了，又向前一小步')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.hero_texture'))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column({ space: 6 }) {
              Text(this.dateLabel())
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
              Text(this.greeting())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textOnInverse)
              Text(this.tagline)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
                .maxLines(2)
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.72)', 1]],
            })
          }
          .width('100%')
          .height(180)

          Row({ space: Theme.space.s4 }) {
            ProgressRing({ progress: this.progress })
            Column({ space: Theme.space.s3 }) {
              Text(`${this.streak}`)
                .fontSize(Theme.type.displayS)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('天坚持指数')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Row({ space: Theme.space.s2 }) {
                AppIcon({ name: 'message', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                Text('消息')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              }
              .onClick(() => {
                this.onOpenMessages()
              })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          Row() {
            Text('今日微目标')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Blank()
            Text(`${this.goals.length}/3`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')

          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.goals.length === 0) {
            Column() {
              Image($r('app.media.ambient_empty'))
                .width('100%')
                .height(120)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              AppEmpty({
                title: '还没有微目标',
                description: '从极小的一步开始，比如读 5 页书',
                actionLabel: '添加第一个',
                onAction: () => {
                  this.openAdd()
                }
              })
            }
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.goals, (g: MicroGoalItem) => {
                MicroGoalCard({
                  item: g,
                  onComplete: () => {
                    this.openComplete(g.id)
                  },
                  onTap: () => {}
                })
              }, (g: MicroGoalItem) => g.id)
            }
          }

          if (this.suggestions.length > 0) {
            Column({ space: Theme.space.s3 }) {
              Text('智慧推荐')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.suggestions, (s: string, idx: number) => {
                Row({ space: Theme.space.s2 }) {
                  Text('✨')
                    .fontSize(Theme.type.subhead)
                  Text(s)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .layoutWeight(1)
                  AppIcon({ name: 'add', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => {
                  if (!this.isLoggedIn()) {
                    this.onRequireAuth()
                    return
                  }
                  this.newTitle = s.startsWith('参考：') ? s.substring(3) : s
                  this.newDesc = ''
                  this.showAdd = true
                  AppStorage.setOrCreate('tabBarHidden', true)
                })
              }, (s: string, idx: number) => `${idx}_${s}`)
            }
          }

          AppButton({
            label: '添加微目标',
            variant: 'primary',
            onTap: () => {
              this.openAdd()
            }
          })
        }
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      if (this.showAdd) {
        this.FormOverlay('新建微目标', true)
      }
      if (this.showComplete) {
        this.CompleteOverlay()
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  FormOverlay(title: string, isAdd: boolean) {
    Column() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text(title)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
          Blank()
          AppIcon({
            name: 'close',
            iconSize: Theme.icon.md,
            color: Theme.colors().textSecondary
          })
            .onClick(() => {
              this.showAdd = false
              AppStorage.setOrCreate('tabBarHidden', false)
            })
        }
        .width('100%')

        TextInput({ text: this.newTitle, placeholder: '微目标，如：读 5 页书' })
          .onChange((v: string) => {
            this.newTitle = v
          })
        TextInput({ text: this.newDesc, placeholder: '可选描述' })
          .onChange((v: string) => {
            this.newDesc = v
          })

        AppButton({
          label: '保存',
          variant: 'primary',
          onTap: (): void => {
            void this.submitAdd()
          }
        })
      }
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .margin(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
    .zIndex(20)
  }

  @Builder
  CompleteOverlay() {
    Column() {
      Column({ space: Theme.space.s4 }) {
        Text('完成感悟')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
        TextArea({ text: this.completeNote, placeholder: '可选，≤200 字' })
          .height(120)
          .onChange((v: string) => {
            this.completeNote = v
          })
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => {
              this.showComplete = false
              AppStorage.setOrCreate('tabBarHidden', false)
            }
          }).layoutWeight(1)
          AppButton({
            label: '完成打卡',
            variant: 'primary',
            onTap: (): void => {
              void this.submitComplete()
            }
          }).layoutWeight(1)
        }
      }
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .margin(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Theme.colors().overlayScrim)
    .zIndex(20)
  }
}
