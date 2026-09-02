import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

class CapItem {
  tab: number = 0
  label: string = ''
  desc: string = ''
  icon: AppIconName = 'home'

  constructor(tab: number, label: string, desc: string, icon: AppIconName) {
    this.tab = tab
    this.label = label
    this.desc = desc
    this.icon = icon
  }
}

/** 首页能力条：六 Tab 产品结构（3.5 审核第一眼） */
@Component
export struct HomeCapabilityBanner {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private items: CapItem[] = [
    new CapItem(0, '笺台', '进度·心情', 'home'),
    new CapItem(1, '灵感', '12+场景', 'ai'),
    new CapItem(2, '计划', '待办·打卡', 'check'),
    new CapItem(3, '创作', '时光轴', 'book'),
    new CapItem(4, '成长', '趋势·成就', 'chart'),
    new CapItem(5, '我的', '收藏·相册', 'user')
  ]

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('六大模块 · 数字生活笺台')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('创作 · 计划 · 打卡 · 回顾一体，非单一日记工具')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Scroll() {
        Row({ space: Theme.space.s3 }) {
          ForEach(this.items, (c: CapItem) => {
            Column({ space: 6 }) {
              AppIcon({ name: c.icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              Text(c.label)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(c.desc)
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textTertiary)
            }
            .width(96)
            .height(84)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { AppStorage.setOrCreate('pendingTab', c.tab) })
          }, (c: CapItem) => c.label)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
