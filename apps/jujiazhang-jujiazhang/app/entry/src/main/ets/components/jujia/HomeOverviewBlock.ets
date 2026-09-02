import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct HomeOverviewBlock {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemTotal: number = 0
  @Prop itemExpiring: number = 0
  @Prop taskPendingToday: number = 0
  @Prop taskPendingAll: number = 0
  @Prop memoTotal: number = 0
  @Prop checklistTotal: number = 0
  @Prop diaryTotal: number = 0
  @Prop memberTotal: number = 0
  onOpenItems: () => void = () => {}
  onOpenMemos: () => void = () => {}
  onOpenMembers: () => void = () => {}
  onOpenTasks: () => void = () => {}

  @Builder
  StatCell(label: string, value: string, icon: AppIconName, onTap: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: 18, color: Theme.colors().brandPrimary })
      Text(value)
        .fontSize(Theme.type.subtitleM)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => onTap())
  }

  build() {
    Column({ space: 8 }) {
      Text('家庭概览')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: 8 }) {
        this.StatCell('今日待办', `${this.taskPendingToday}`, 'biz', () => this.onOpenTasks())
        this.StatCell('全部待办', `${this.taskPendingAll}`, 'clock', () => this.onOpenTasks())
        this.StatCell('登记物品', `${this.itemTotal}`, 'grid', () => this.onOpenItems())
        this.StatCell('30 天内到期', `${this.itemExpiring}`, 'bell', () => this.onOpenItems())
      }
      .width('100%')
      Row({ space: 8 }) {
        this.StatCell('家庭备忘', `${this.memoTotal}`, 'message', () => this.onOpenMemos())
        this.StatCell('家人', `${this.memberTotal}`, 'user', () => this.onOpenMembers())
        this.StatCell('居家清单', `${this.checklistTotal}`, 'check', () => this.onOpenMemos())
        this.StatCell('生活日记', `${this.diaryTotal}`, 'edit', () => this.onOpenMemos())
      }
      .width('100%')
    }
    .width('100%')
  }
}
