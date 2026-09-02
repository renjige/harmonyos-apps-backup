import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ChoiceChip } from '../components/travel/TravelCards'
import { ReminderItem, SystemNotice } from '../models/TravelModels'
import { TravelService } from '../services/TravelService'
import { AuthService } from '../services/AuthService'

@Component
export struct RemindersPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State reminders: ReminderItem[] = []
  @State notices: SystemNotice[] = []
  @State filterType: string = '全部'
  @State loading: boolean = false
  @Prop embedded: boolean = false
  @Prop @Watch('onEpochChange') dataEpoch: number = 0
  onCreate: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  onEditItem: (item: ReminderItem) => void = () => {}
  onDeleteItem: (item: ReminderItem) => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onEpochChange(): void {
    void this.load(true)
  }

  private async load(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.loading = true
    }
    try {
      this.reminders = await TravelService.reminders()
      this.notices = await TravelService.notices()
    } catch {
      this.reminders = []
      this.notices = []
    }
    this.loading = false
  }

  private visible(): ReminderItem[] {
    const out: ReminderItem[] = []
    for (const item of this.reminders) {
      if (this.filterType !== '全部' && item.reminderType !== this.filterType) {
        continue
      }
      out.push(item)
    }
    return out
  }

  private async toggle(item: ReminderItem): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    const next = item.completed !== true
    const ok = await TravelService.setReminderCompleted(item.id, next)
    if (!ok) {
      return
    }
    const copied: ReminderItem[] = []
    for (const row of this.reminders) {
      const mapped = TravelService.mapReminder(row)
      if (row.id === item.id) {
        mapped.completed = next
        mapped.status = next ? 'done' : 'pending'
      }
      copied.push(mapped)
    }
    this.reminders = copied
    this.onChanged()
  }

  private confirmDelete(item: ReminderItem): void {
    AlertDialog.show({
      title: '删除提醒',
      message: `确定删除「${item.title}」？`,
      primaryButton: {
        value: '删除',
        action: (): void => { this.onDeleteItem(item) }
      },
      secondaryButton: { value: '取消', action: (): void => {} }
    })
  }

  build() {
    if (this.embedded) {
      this.ListBody()
    } else {
      Column() {
        AppHeader({ title: '提醒', subtitle: '出发、入住与自定义事项及时掌握' })
        Scroll() {
          this.ListBody()
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
  }

  @Builder
  ListBody() {
    Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s2 }) {
            ChoiceChip({ label: '全部', selected: this.filterType === '全部',
              onTap: () => { this.filterType = '全部' } })
            ChoiceChip({ label: '出发', selected: this.filterType === '出发',
              onTap: () => { this.filterType = '出发' } })
            ChoiceChip({ label: '入住', selected: this.filterType === '入住',
              onTap: () => { this.filterType = '入住' } })
            ChoiceChip({ label: '自定义', selected: this.filterType === '自定义',
              onTap: () => { this.filterType = '自定义' } })
          }
          .width('100%')
          AppButton({ label: '创建提醒', onTap: () => this.onCreate() })
          if (this.loading) {
            LoadingProgress()
              .width(32)
              .height(32)
              .color(Theme.colors().brandPrimary)
          }
          if (this.visible().length === 0 && !this.loading) {
            AppEmpty({ title: '暂无提醒', description: '创建提醒，避免错过关键时间',
              actionLabel: '重新加载', onAction: () => { void this.load() } })
          } else {
            ForEach(this.visible(), (item: ReminderItem) => {
              Row({ space: Theme.space.s3 }) {
                Row() {
                  AppIcon({
                    name: item.completed ? 'check' : 'alert',
                    iconSize: Theme.icon.md,
                    color: item.completed ? Theme.colors().success : Theme.colors().brandPrimary
                  })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(item.completed ? Theme.colors().successContainer :
                  Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
                .onClick(() => { void this.toggle(item) })
                Column({ space: 4 }) {
                  Row({ space: 6 }) {
                    Text(item.reminderType)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    Text(item.remindAt)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  }
                  Text(item.title)
                    .fontSize(Theme.type.bodyM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(item.completed ? Theme.colors().textSecondary : Theme.colors().textPrimary)
                    .decoration({
                      type: item.completed ? TextDecorationType.LineThrough : TextDecorationType.None
                    })
                  if (item.note.length > 0) {
                    Text(item.note)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .maxLines(2)
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Column({ space: 4 }) {
                  Text('编辑')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                    .onClick(() => this.onEditItem(item))
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick(() => this.confirmDelete(item))
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (item: ReminderItem) => `${item.id}-${item.completed ? '1' : '0'}`)
          }
          if (this.notices.length > 0) {
            Text('系统通知')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .margin({ top: Theme.space.s3 })
            ForEach(this.notices, (notice: SystemNotice) => {
              Row({ space: Theme.space.s3 }) {
                Row() {
                  AppIcon({ name: 'message', iconSize: Theme.icon.md,
                    color: Theme.colors().brandPrimary })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
                Column({ space: 4 }) {
                  Text(notice.title)
                    .fontSize(Theme.type.bodyM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(notice.body)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
            }, (notice: SystemNotice) => notice.id)
          }
    }
    .width('100%')
    .padding({
      left: Theme.space.pageX,
      right: Theme.space.pageX,
      bottom: this.embedded ? Theme.space.s4 : Theme.space.s10
    })
  }
}
