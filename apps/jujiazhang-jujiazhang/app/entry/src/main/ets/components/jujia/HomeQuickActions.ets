import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct HomeQuickActions {
  onApplyScene: () => void = () => {}
  onAddItem: () => void = () => {}
  onAddMemo: () => void = () => {}
  onSearch: () => void = () => {}
  onGrowth: () => void = () => {}

  @Builder
  Chip(label: string, icon: AppIconName, onTap: () => void) {
    Row({ space: 6 }) {
      AppIcon({ name: icon, iconSize: 16, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textPrimary)
    }
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.button)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => onTap())
  }

  build() {
    Column({ space: 8 }) {
      Text('快捷操作')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: 8 }) {
          this.Chip('生活场景', 'search', () => this.onApplyScene())
          this.Chip('登记物品', 'grid', () => this.onAddItem())
          this.Chip('写备忘', 'edit', () => this.onAddMemo())
          this.Chip('搜索', 'search', () => this.onSearch())
          this.Chip('成长回顾', 'chart', () => this.onGrowth())
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
