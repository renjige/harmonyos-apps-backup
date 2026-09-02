import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifePageShell } from '../components/life/LifePageShell'
import { LifeDates, TodoItem } from '../models/LifeHubModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { AuthService } from '../services/AuthService'
import { JournalChoice } from '../services/JournalCatalog'

@Component
export struct TodoPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State items: TodoItem[] = []
  @State filter: string = ''
  @State formTitle: string = ''
  @State formCategory: string = 'life'
  @State confirmId: string = ''
  @State toastText: string = ''
  private cats: JournalChoice[] = [
    new JournalChoice('life', '生活'),
    new JournalChoice('work', '工作'),
    new JournalChoice('study', '学习')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeHubStore.loadTodos()
  }

  private catLabel(id: string): string {
    for (const c of this.cats) {
      if (c.id === id) {
        return c.label
      }
    }
    return '生活'
  }

  private visible(): TodoItem[] {
    if (this.filter.length === 0) {
      return this.items
    }
    const out: TodoItem[] = []
    for (const row of this.items) {
      if (row.category === this.filter) {
        out.push(row)
      }
    }
    return out
  }

  private async addTodo(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.toastText = '请填写任务内容'
      setTimeout(() => { this.toastText = '' }, 2000)
      return
    }
    const item = new TodoItem()
    item.id = LifeHubStore.newId('todo')
    item.title = this.formTitle.trim()
    item.category = this.formCategory
    item.done = false
    item.date = LifeDates.todayIso()
    await LifeHubStore.upsertTodo(item)
    this.formTitle = ''
    await this.reload()
    this.toastText = '已加入待办'
    setTimeout(() => { this.toastText = '' }, 2000)
  }

  private async toggle(row: TodoItem): Promise<void> {
    row.done = !row.done
    await LifeHubStore.upsertTodo(row)
    await this.reload()
  }

  private async confirmDelete(): Promise<void> {
    await LifeHubStore.removeTodo(this.confirmId)
    this.confirmId = ''
    await this.reload()
  }

  build() {
    Stack() {
      LifePageShell({
        title: '待办清单',
        subtitle: '创建任务 · 勾选完成 · 分类查看',
        onClose: (): void => { LifeHubNav.backOrClose() },
        body: () => { this.Body() }
      })
      if (this.confirmId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条待办？')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          AppButton({
            label: '确认删除',
            variant: 'danger',
            onTap: (): void => { void this.confirmDelete() }
          })
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmId = '' }
          })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
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
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      TextInput({ text: this.formTitle, placeholder: '新任务，例如：买菜、整理书桌' })
        .width('100%')
        .height(44)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.formTitle = v })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cats, (c: JournalChoice) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.formCategory === c.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.formCategory === c.id ?
              Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.formCategory = c.id })
        }, (c: JournalChoice) => `fc_${c.id}`)
      }
      .width('100%')
      AppButton({
        label: '添加任务',
        onTap: (): void => { void this.addTodo() }
      })
      Flex({ wrap: FlexWrap.Wrap }) {
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(this.filter.length === 0 ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.filter.length === 0 ?
            Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .margin({ right: 8, bottom: 8 })
          .onClick((): void => { this.filter = '' })
        ForEach(this.cats, (c: JournalChoice) => {
          Text(c.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.filter === c.id ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.filter === c.id ?
              Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.filter = c.id })
        }, (c: JournalChoice) => `fl_${c.id}`)
      }
      .width('100%')
      if (this.visible().length === 0) {
        AppEmpty({ title: '清单还空着', description: '添加生活、工作或学习任务，完成后点一下勾选' })
      } else {
        ForEach(this.visible(), (row: TodoItem) => {
          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(row.done ? '已完成' : '待完成')
                .fontSize(Theme.type.overline)
                .fontColor(row.done ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            }
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(row.done ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { void this.toggle(row) })
            Column({ space: 2 }) {
              Text(row.title)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .decoration({ type: row.done ? TextDecorationType.LineThrough : TextDecorationType.None })
                .width('100%')
              Text(`${this.catLabel(row.category)} · ${row.date}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            .onClick((): void => { void this.toggle(row) })
            Text('删除')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().danger)
              .onClick((): void => { this.confirmId = row.id })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
        }, (row: TodoItem) => row.id)
      }
    }
    .width('100%')
  }
}
