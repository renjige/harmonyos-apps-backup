import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct HomeKpiGrid {
  @Prop checklistTotal: number = 0
  @Prop memoTotal: number = 0
  @Prop itemTotal: number = 0
  @Prop favoriteTotal: number = 0
  @Prop streakDays: number = 0
  onOpenMemos: () => void = () => {}
  onOpenItems: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenGrowth: () => void = () => {}

  @Builder
  Cell(label: string, value: string, icon: AppIconName, onTap: () => void) {
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
    .padding(12)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => onTap())
  }

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        this.Cell('居家清单', `${this.checklistTotal}`, 'check', () => this.onOpenMemos())
        this.Cell('家庭备忘', `${this.memoTotal}`, 'edit', () => this.onOpenMemos())
      }
      .width('100%')
      Row({ space: 8 }) {
        this.Cell('登记物品', `${this.itemTotal}`, 'grid', () => this.onOpenItems())
        this.Cell('连续活跃', `${this.streakDays}天`, 'calendar', () => this.onOpenGrowth())
      }
      .width('100%')
    }
    .width('100%')
  }
}
