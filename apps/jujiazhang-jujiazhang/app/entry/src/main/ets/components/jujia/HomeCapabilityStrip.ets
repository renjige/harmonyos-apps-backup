import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

@Component
export struct HomeCapabilityStrip {
  onOpenDiscover: () => void = () => {}
  onOpenItems: () => void = () => {}
  onOpenMemos: () => void = () => {}
  onOpenTasks: () => void = () => {}
  onOpenSearch: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenGrowth: () => void = () => {}

  @Builder
  Tile(label: string, sub: string, icon: AppIconName, onTap: () => void) {
    Column({ space: 4 }) {
      AppIcon({ name: icon, iconSize: 20, color: Theme.colors().brandPrimary })
      Text(label)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
      Text(sub)
        .fontSize(10)
        .fontColor(Theme.colors().textTertiary)
        .maxLines(1)
    }
    .width(72)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => onTap())
  }

  build() {
    Column({ space: 8 }) {
      Text('家庭生活工作台')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Scroll() {
        Row({ space: 8 }) {
          this.Tile('发现', '8 大场景', 'search', () => this.onOpenDiscover())
          this.Tile('物品', '到期维护', 'grid', () => this.onOpenItems())
          this.Tile('生活', '备忘日记', 'edit', () => this.onOpenMemos())
          this.Tile('计划', '月历提醒', 'biz', () => this.onOpenTasks())
          this.Tile('搜索', '全局检索', 'search', () => this.onOpenSearch())
          this.Tile('成长', '统计成就', 'chart', () => this.onOpenGrowth())
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
