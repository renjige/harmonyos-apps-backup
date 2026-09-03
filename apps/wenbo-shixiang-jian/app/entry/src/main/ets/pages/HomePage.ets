import { Theme } from '../components/design-system/Theme'
import { SketchStyle } from '../components/design-system/SketchStyle'
import { SketchTitle } from '../components/design-system/SketchTitle'
import { SketchNote } from '../components/design-system/SketchNote'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { TaskListCard } from '../components/task/TaskListCard'
import { TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { AuthService } from '../services/AuthService'
import { CommitmentRules } from '../services/CommitmentRules'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '魏文波'
  @Prop appName: string = '事项笺'
  @Prop tagline: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onQuickAdd: () => void = () => {}
  onOpenDiagnose: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onStartFocus: (item: TaskItem) => void = (_item: TaskItem) => {}
  onCloseDay: () => void = () => {}
  @State toastText: string = ''
  @State todayTasks: TaskItem[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private today(): string {
    return TaskBizService.todayLocal()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.todayTasks = await TaskBizService.loadTasks(this.currentUsername, '', '', this.today())
    } else {
      this.todayTasks = []
    }
    this.loading = false
  }

  private slotItem(slot: string): TaskItem | undefined {
    return CommitmentRules.inSlot(this.todayTasks, this.today(), slot)
  }

  private waitlist(): TaskItem[] {
    return CommitmentRules.waitlistOf(this.todayTasks, this.today())
  }

  private doneN(): number {
    return CommitmentRules.doneCommitCount(this.todayTasks, this.today())
  }

  private openN(): number {
    return CommitmentRules.openCommitCount(this.todayTasks, this.today())
  }

  private slotClosed(slot: string): boolean {
    const it = this.slotItem(slot)
    if (it === undefined) {
      return true
    }
    return it.isDone() || it.closeReason.length > 0
  }

  private slotStatus(slot: string): string {
    const it = this.slotItem(slot)
    if (it === undefined) {
      return ''
    }
    if (it.isDone()) {
      return '已收工'
    }
    if (it.focusReady) {
      return '专注完成，可以收工'
    }
    if (it.closeReason.length > 0) {
      return `已关帐 · ${it.closeReason}`
    }
    return '待专注'
  }

  private slotTitleText(slot: string): string {
    const it = this.slotItem(slot)
    return it !== undefined ? it.title : ''
  }

  private slotReady(slot: string): boolean {
    const it = this.slotItem(slot)
    return it !== undefined && it.focusReady
  }

  private async handlePromote(item: TaskItem): Promise<void> {
    if (!AuthService.requireAuth('edit_task')) {
      return
    }
    const today = this.today()
    let slot = item.timeSlot.length > 0 ? item.timeSlot : CommitmentRules.defaultSlot()
    if (CommitmentRules.slotTaken(this.todayTasks, today, slot, item.id)) {
      slot = ''
      for (const s of CommitmentRules.slotKeys()) {
        if (!CommitmentRules.slotTaken(this.todayTasks, today, s, item.id)) {
          slot = s
          break
        }
      }
    }
    if (slot.length === 0) {
      this.toastText = '今日 3 个承诺席位已满，请先完成或关帐一件'
      setTimeout(() => { this.toastText = '' }, 2400)
      return
    }
    const updated = await TaskBizService.setLane(item.id, item, 'commitment', slot)
    if (updated === undefined) {
      this.toastText = TaskBizService.lastError.length > 0 ? TaskBizService.lastError : '升级失败'
    } else {
      this.toastText = `已锁定到${CommitmentRules.slotTitle(slot)}`
      void this.reload()
    }
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  build() {
    Stack() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        SketchTitle({
          text: '今日承诺工位',
          subtitle: '每天最多 3 件 · 进上午/午后/晚间席位 · 专注计时后才能收工',
          large: true
        })

        Row({ space: Theme.space.s3 }) {
          Image($r('app.media.hero_productivity'))
            .layoutWeight(1)
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.sketchRadius())
            .border({ width: 2, color: SketchStyle.borderInk() })
            .shadow(Theme.sketchShadow(4))
            .rotate({ angle: -1.2 })
          Image($r('app.media.banner_schedule'))
            .layoutWeight(1)
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.sketchRadius())
            .border({ width: 2, color: SketchStyle.borderInk() })
            .shadow(Theme.sketchShadow(4))
            .rotate({ angle: 1.0 })
        }
        .width('100%')

        SketchNote({ noteIndex: 0, interactive: true }) {
          Row({ space: Theme.space.s4 }) {
            Column({ space: 2 }) {
              Text(`${this.doneN()}/3`)
                .fontSize(Theme.type.title1)
                .fontWeight(SketchStyle.titleWeight())
                .fontStyle(SketchStyle.titleStyle())
                .fontColor(Theme.colors().brandPrimary)
              Text('已收工承诺')
                .fontSize(Theme.type.caption)
                .fontColor(SketchStyle.inkMuted())
            }
            Column({ space: 2 }) {
              Text(`${CommitmentRules.focusMinutes(this.todayTasks, this.today())}`)
                .fontSize(Theme.type.title1)
                .fontWeight(SketchStyle.titleWeight())
                .fontStyle(SketchStyle.titleStyle())
                .fontColor(Theme.colors().success)
              Text('今日专注分钟')
                .fontSize(Theme.type.caption)
                .fontColor(SketchStyle.inkMuted())
            }
            .layoutWeight(1)
          }
          .width('100%')
        }

        AppButton({
          label: '锁定今日承诺',
          onTap: (): void => { this.onQuickAdd() }
        })

        if (this.loading) {
          AppLoading({ variant: 'skeleton' })
        } else {
          ForEach(CommitmentRules.slotKeys(), (slot: string) => {
            this.SlotCard(slot)
          }, (slot: string) => slot)

          Column({ space: Theme.space.s3 }) {
            Text(`候补池 · ${this.waitlist().length}`)
              .fontSize(Theme.type.title3)
              .fontWeight(SketchStyle.titleWeight())
              .fontStyle(SketchStyle.titleStyle())
              .fontColor(SketchStyle.ink())
              .width('100%')
            if (this.waitlist().length === 0) {
              Text('超额事项会进入候补，不能占用今日承诺席位。')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
            } else {
              ForEach(this.waitlist(), (item: TaskItem) => {
                Column({ space: 8 }) {
                  TaskListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { TaskDetailNav.openTask(item.id, item) }
                  })
                  if (AuthService.isLoggedIn()) {
                    Text('升级为承诺（需有空时段）')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .onClick((): void => { void this.handlePromote(item) })
                  }
                }
                .width('100%')
              }, (item: TaskItem) => item.id)
            }
          }
          .width('100%')

          if (this.openN() > 0 && AuthService.isLoggedIn()) {
            AppButton({
              label: '今日关帐（未兑现须选原因）',
              variant: 'secondary',
              onTap: (): void => { this.onCloseDay() }
            })
          }
        }

        Row({ space: Theme.space.s3 }) {
          this.FeatureChip('效率自诊', 'chart', (): void => { this.onOpenDiagnose() })
          this.FeatureChip('智慧整理', 'biz', (): void => { this.onOpenOrganize() })
          this.FeatureChip('习惯打卡', 'check', (): void => { this.onOpenHabits() })
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageClear())
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)

    if (this.toastText.length > 0) {
      Column() {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.sketchRadius())
          .border({ width: 2, color: SketchStyle.borderInk() })
          .shadow(Theme.sketchShadow(4))
      }
      .width('100%')
      .padding({ top: Theme.space.s6 })
      .alignItems(HorizontalAlign.Center)
    }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SlotCard(slot: string) {
    SketchNote({
      noteIndex: SketchStyle.slotIndex(slot),
      interactive: true
    }) {
      Column({ space: Theme.space.s3 }) {
        Row() {
          Text(CommitmentRules.slotTitle(slot))
            .fontSize(Theme.type.subhead)
            .fontWeight(SketchStyle.titleWeight())
            .fontStyle(SketchStyle.titleStyle())
            .fontColor(SketchStyle.ink())
            .layoutWeight(1)
          Text(CommitmentRules.slotHint(slot))
            .fontSize(Theme.type.caption)
            .fontColor(SketchStyle.inkMuted())
        }
        .width('100%')
        if (this.slotItem(slot) === undefined) {
          Text('空席 · 可锁定 1 件承诺')
            .fontSize(Theme.type.footnote)
            .fontColor(SketchStyle.inkMuted())
            .width('100%')
        } else {
          Text(this.slotTitleText(slot))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(SketchStyle.ink())
            .width('100%')
          Text(this.slotStatus(slot))
            .fontSize(Theme.type.caption)
            .fontColor(SketchStyle.inkMuted())
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            if (!this.slotClosed(slot)) {
              AppButton({
                label: this.slotReady(slot) ? '去收工' : '开始专注',
                onTap: (): void => {
                  const it = this.slotItem(slot)
                  if (it !== undefined) {
                    if (it.focusReady) {
                      TaskDetailNav.openTask(it.id, it)
                    } else {
                      this.onStartFocus(it)
                    }
                  }
                }
              })
                .layoutWeight(1)
            }
            AppButton({
              label: '详情',
              variant: 'secondary',
              onTap: (): void => {
                const it = this.slotItem(slot)
                if (it !== undefined) {
                  TaskDetailNav.openTask(it.id, it)
                }
              }
            })
              .layoutWeight(1)
          }
          .width('100%')
        }
      }
      .width('100%')
    }
  }

  @Builder
  FeatureChip(label: string, iconName: 'chart' | 'biz' | 'check', onTap: () => void) {
    Column() {
      SketchNote({ noteIndex: 3, interactive: true }) {
        Column({ space: 6 }) {
          AppIcon({ name: iconName, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          Text(label)
            .fontSize(Theme.type.caption)
            .fontWeight(FontWeight.Medium)
            .fontColor(SketchStyle.ink())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .onClick((): void => { onTap() })
      }
    }
    .layoutWeight(1)
  }
}
