import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { TodoSettleOverlay } from '../components/moment/TodoSettleOverlay'
import { TodoBucketSection } from '../components/moment/TodoBucketSection'
import { MomentTodo } from '../models/MomentModels'
import { MomentStore } from '../services/MomentStore'
import { MomentNav } from '../services/MomentNav'

@Component
export struct TodoPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State todos: MomentTodo[] = []
  @State progress: number = 0
  @State confirmClear: boolean = false
  @State toast: string = ''
  @State adding: boolean = false
  @State draftText: string = ''
  @State highlightId: string = ''
  @State settleId: string = ''
  @State settlePreview: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.todos = await MomentStore.loadTodos()
    this.progress = MomentStore.todayProgress(this.todos)
  }

  private group(bucket: string): MomentTodo[] {
    const out: MomentTodo[] = []
    for (const t of this.todos) {
      if (t.bucket === bucket) {
        out.push(t)
      }
    }
    return out
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2200)
  }

  private replaceTodos(next: MomentTodo[]): void {
    this.todos = next
    this.progress = MomentStore.todayProgress(next)
  }

  private tapAdd(): void {
    void this.addQuick(this.draftText)
  }

  private async addQuick(raw: string): Promise<void> {
    if (this.adding) {
      return
    }
    const text = raw.trim()
    if (text.length === 0) {
      this.showToast('请输入待办后再点添加')
      return
    }
    this.adding = true
    const t = MomentTodo.createNew()
    t.content = text
    t.bucket = 'today'
    const next: MomentTodo[] = [t]
    for (const old of this.todos) {
      next.push(old)
    }
    this.draftText = ''
    this.replaceTodos(next)
    this.showToast('已加入今日')
    const ok = await MomentStore.saveTodo(t)
    this.adding = false
    if (!ok) {
      await this.reload()
      this.showToast('请输入待办后再点添加')
      return
    }
    this.highlightId = t.id
    setTimeout((): void => {
      if (this.highlightId === t.id) {
        this.highlightId = ''
      }
    }, 1500)
  }

  private async toggle(id: string): Promise<void> {
    let becameDone = false
    let preview = ''
    const next: MomentTodo[] = []
    for (const t of this.todos) {
      const copy = new MomentTodo()
      copy.id = t.id
      copy.content = t.content
      copy.priority = t.priority
      copy.bucket = t.bucket
      copy.isCompleted = t.id === id ? !t.isCompleted : t.isCompleted
      copy.createdAt = t.createdAt
      copy.updatedAt = t.id === id ? Date.now() : t.updatedAt
      if (t.id === id && !t.isCompleted) {
        becameDone = true
        preview = t.content
      }
      next.push(copy)
    }
    this.replaceTodos(next)
    await MomentStore.toggleTodo(id)
    if (becameDone) {
      this.settleId = id
      this.settlePreview = preview
    }
  }

  private onSettleClosed(saved: boolean): void {
    this.settleId = ''
    this.settlePreview = ''
    if (saved) {
      this.showToast('已记入时间线')
    }
  }

  private async clearDone(): Promise<void> {
    const n = await MomentStore.clearCompletedTodos()
    this.confirmClear = false
    await this.reload()
    this.showToast(n > 0 ? `已清除 ${n} 项` : '没有已完成事项')
  }

  @Builder
  AddDock() {
    Column({ space: Theme.space.s2 }) {
      if (this.todos.length === 0 && this.draftText.trim().length > 0) {
        AppButton({
          label: '加入今日待办',
          onTap: (): void => this.tapAdd()
        })
      }
      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.draftText, placeholder: '添加今日待办' })
          .layoutWeight(1)
          .height(48)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(12)
          .padding({ left: 12, right: 12 })
          .enterKeyType(EnterKeyType.Done)
          .onChange((v: string): void => {
            this.draftText = v
          })
          .onSubmit((): void => this.tapAdd())
        Row() {
          Text('添加')
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width(96)
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(12)
        .onClick((): void => this.tapAdd())
      }
      .width('100%')
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      top: Theme.space.s2,
      bottom: Theme.space.s3
    })
    .backgroundColor(Theme.colors().surfacePage)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Text('待办清单')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })

        Column({ space: Theme.space.s2 }) {
          Row() {
            Text('今日完成')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
            Text(`${this.progress}%`)
              .fontSize(Theme.type.bodyS)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .width('100%')
          Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
            .color(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .height(8)
            .borderRadius(4)
            .width('100%')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: Theme.space.s3 })

        if (this.todos.length === 0) {
          Column() {
            Image($r('app.media.banner_todo_calm'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
            AppEmpty({
              title: '还没有待办',
              description: '在下方输入后点添加，或打开完整表单',
              actionLabel: '完整添加',
              onAction: (): void => MomentNav.openTodoEditor('')
            })
          }
          .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              TodoBucketSection({
                title: '今日',
                items: this.group('today'),
                highlightId: this.highlightId,
                onToggle: (id: string): void => { void this.toggle(id) },
                onOpen: (id: string): void => MomentNav.openTodo(id)
              })
              TodoBucketSection({
                title: '本周',
                items: this.group('week'),
                highlightId: this.highlightId,
                onToggle: (id: string): void => { void this.toggle(id) },
                onOpen: (id: string): void => MomentNav.openTodo(id)
              })
              TodoBucketSection({
                title: '以后',
                items: this.group('later'),
                highlightId: this.highlightId,
                onToggle: (id: string): void => { void this.toggle(id) },
                onOpen: (id: string): void => MomentNav.openTodo(id)
              })
              if (!this.confirmClear) {
                AppButton({
                  label: '清除已完成',
                  variant: 'secondary',
                  onTap: (): void => { this.confirmClear = true }
                })
              } else {
                Column({ space: Theme.space.s2 }) {
                  Text('将清除所有已完成待办，不可恢复')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().danger)
                  Row({ space: Theme.space.s2 }) {
                    Column() {
                      AppButton({
                        label: '取消',
                        variant: 'secondary',
                        onTap: (): void => { this.confirmClear = false }
                      })
                    }.layoutWeight(1)
                    Column() {
                      AppButton({
                        label: '确认清除',
                        variant: 'danger',
                        onTap: (): void => { void this.clearDone() }
                      })
                    }.layoutWeight(1)
                  }
                  .width('100%')
                }
              }
              Row().height(this.bottomInset + 72)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .layoutWeight(1)
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
        }

        this.AddDock()
      }
      .width('100%')
      .height('100%')

      if (this.settleId.length > 0) {
        Stack({ alignContent: Alignment.Top }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.36)')
            .onClick((): void => this.onSettleClosed(false))
          TodoSettleOverlay({
            todoId: this.settleId,
            preview: this.settlePreview,
            onClosed: (saved: boolean): void => this.onSettleClosed(saved)
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(30)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
