import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'

class ModuleCard {
  tab: number = 0
  title: string = ''
  desc: string = ''
  icon: AppIconName = 'home'

  constructor(tab: number, title: string, desc: string, icon: AppIconName) {
    this.tab = tab
    this.title = title
    this.desc = desc
    this.icon = icon
  }
}

/** 首页大卡片：六大模块一级入口（审核第一眼可见） */
@Component
export struct HomeModuleGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  private cards: ModuleCard[] = [
    new ModuleCard(1, '灵感创作', '12+场景·本周挑战', 'ai'),
    new ModuleCard(2, '计划执行', '计划·待办·打卡', 'check'),
    new ModuleCard(4, '成长回顾', '趋势·成就·动态', 'chart'),
    new ModuleCard(3, '时光创作', '写作与时光轴', 'book'),
    new ModuleCard(5, '我的中心', '通知·收藏·相册', 'user'),
    new ModuleCard(0, '今日笺台', '进度·心情·任务', 'home')
  ]

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('生活笺台 · 六大能力')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text('创作、计划、打卡、回顾 — 非单一日记工具')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.cards, (c: ModuleCard) => {
          Column({ space: 8 }) {
            AppIcon({ name: c.icon, iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            Text(c.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Text(c.desc)
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textTertiary)
              .maxLines(2)
          }
          .width('48%')
          .height(108)
          .margin({ right: '2%', bottom: Theme.space.s3 })
          .padding(Theme.space.s3)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { AppStorage.setOrCreate('pendingTab', c.tab) })
        }, (c: ModuleCard) => c.title)
      }
      .width('100%')
    }
    .width('100%')
  }
}
