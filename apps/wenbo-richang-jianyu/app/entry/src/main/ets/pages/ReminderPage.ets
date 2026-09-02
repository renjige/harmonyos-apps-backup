import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField, AppTimePickerField } from '../components/design-system/AppDatePickerField'
import { LifePageShell } from '../components/life/LifePageShell'
import { LifeDates, ReminderItem } from '../models/LifeHubModels'
import { LifeHubNav } from '../services/LifeHubNav'
import { LifeHubStore } from '../services/LifeHubStore'
import { LifeReminderService } from '../services/LifeReminderService'
import { AuthService } from '../services/AuthService'
import { JournalChoice } from '../services/JournalCatalog'

@Component
export struct ReminderPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @State items: ReminderItem[] = []
  @State filter: string = ''
  @State formTitle: string = ''
  @State formCategory: string = 'life'
  @State formDate: string = ''
  @State formTime: string = '09:00'
  @State toastText: string = ''
  @State confirmId: string = ''
  @State hint: string = ''
  private cats: JournalChoice[] = [
    new JournalChoice('life', '生活'),
    new JournalChoice('health', '健康'),
    new JournalChoice('home', '家务'),
    new JournalChoice('social', '社交')
  ]

  aboutToAppear(): void {
    this.formDate = LifeDates.todayIso()
    this.formTime = LifeDates.nowTime()
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await LifeHubStore.loadReminders()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private catLabel(id: string): string {
    for (const c of this.cats) {
      if (c.id === id) {
        return c.label
      }
    }
    return '生活'
  }

  private visible(): ReminderItem[] {
    if (this.filter.length === 0) {
      return this.items
    }
    const out: ReminderItem[] = []
    for (const row of this.items) {
      if (row.category === this.filter) {
        out.push(row)
      }
    }
    return out
  }

  private async saveItem(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.hint = '请填写提醒事项'
      return
    }
    const item = new ReminderItem()
    item.id = LifeHubStore.newId('rmd')
    item.title = this.formTitle.trim()
    item.category = this.formCategory
    item.date = this.formDate.length >= 10 ? this.formDate : LifeDates.todayIso()
    item.time = this.formTime.length >= 5 ? this.formTime : '09:00'
    item.enabled = true
    const ctx = getContext(this) as common.UIAbilityContext
    item.agentId = await LifeReminderService.schedule(item, ctx)
    await LifeHubStore.upsertReminder(item)
    this.formTitle = ''
    this.hint = ''
    await this.reload()
    const msg = LifeReminderService.lastAction.length > 0 ? LifeReminderService.lastAction : '已添加提醒'
    this.showToast(msg)
  }

  private async confirmDelete(): Promise<void> {
    const removed = await LifeHubStore.removeReminder(this.confirmId)
    if (removed !== undefined) {
      await LifeReminderService.cancelAgent(removed.agentId)
    }
    this.confirmId = ''
    await this.reload()
    this.showToast('已删除提醒')
  }

  build() {
    Stack() {
      LifePageShell({
        title: '日常提醒',
        subtitle: '创建事项 · 设定时间 · 分类管理',
        onClose: (): void => { LifeHubNav.backOrClose() },
        body: () => { this.Body() }
      })
      if (this.confirmId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条提醒？')
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
            .maxLines(2)
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
      TextInput({ text: this.formTitle, placeholder: '提醒事项，例如：浇花、回电' })
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
        }, (c: JournalChoice) => `f_${c.id}`)
      }
      .width('100%')
      AppDatePickerField({
        label: '提醒日期',
        value: this.formDate,
        minDaysFromToday: 0,
        maxDaysFromToday: 365,
        onChange: (v: string): void => { this.formDate = v }
      })
      AppTimePickerField({
        label: '提醒时间',
        value: this.formTime,
        onChange: (v: string): void => { this.formTime = v }
      })
      if (this.hint.length > 0) {
        Text(this.hint)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      AppButton({
        label: '添加提醒',
        onTap: (): void => { void this.saveItem() }
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
        }, (c: JournalChoice) => `l_${c.id}`)
      }
      .width('100%')

      if (this.visible().length === 0) {
        AppEmpty({ title: '暂无提醒', description: '添加一条生活事项，并设定提醒时间' })
      } else {
        ForEach(this.visible(), (row: ReminderItem) => {
          Row() {
            Column({ space: 4 }) {
              Text(row.title)
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(`${this.catLabel(row.category)} · ${row.date} ${row.time}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
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
        }, (row: ReminderItem) => row.id)
      }
    }
    .width('100%')
  }
}
