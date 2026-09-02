import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'

class GrowthToolItem {
  label: string = ''
  subtitle: string = ''
  icon: AppIconName = 'home'
  action: string = ''
}

@Component
export struct GrowthToolsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onOpenRitual: () => void = () => {}
  onOpenStuck: () => void = () => {}
  onOpenContrast: () => void = () => {}
  onOpenTheme: () => void = () => {}
  onOpenDiagnose: () => void = () => {}
  onOpenHabits: () => void = () => {}
  onOpenReviews: () => void = () => {}
  onOpenOrganize: () => void = () => {}
  onOpenAnnualReport: () => void = () => {}
  onOpenFavorites: () => void = () => {}
  onOpenMessages: () => void = () => {}
  onOpenAchievements: () => void = () => {}

  private tools(): GrowthToolItem[] {
    const items: GrowthToolItem[] = []
    const t0 = new GrowthToolItem()
    t0.label = '今日仪式'
    t0.subtitle = '三问对齐'
    t0.icon = 'check'
    t0.action = 'ritual'
    items.push(t0)
    const t1 = new GrowthToolItem()
    t1.label = '卡住工坊'
    t1.subtitle = '写入最小步骤'
    t1.icon = 'alert'
    t1.action = 'stuck'
    items.push(t1)
    const t2 = new GrowthToolItem()
    t2.label = '对照卡'
    t2.subtitle = '看见变化'
    t2.icon = 'chart'
    t2.action = 'contrast'
    items.push(t2)
    const t3 = new GrowthToolItem()
    t3.label = '主题月'
    t3.subtitle = '本月经营'
    t3.icon = 'calendar'
    t3.action = 'theme'
    items.push(t3)
    const t4 = new GrowthToolItem()
    t4.label = '习惯打卡'
    t4.subtitle = '每日坚持'
    t4.icon = 'check'
    t4.action = 'habit'
    items.push(t4)
    const t5 = new GrowthToolItem()
    t5.label = '每周复盘'
    t5.subtitle = '四问回顾'
    t5.icon = 'book'
    t5.action = 'review'
    items.push(t5)
    const t6 = new GrowthToolItem()
    t6.label = '成长诊断'
    t6.subtitle = '规则报告'
    t6.icon = 'ai'
    t6.action = 'diagnose'
    items.push(t6)
    const t7 = new GrowthToolItem()
    t7.label = '智慧整理'
    t7.subtitle = '搜索归档'
    t7.icon = 'search'
    t7.action = 'organize'
    items.push(t7)
    const t8 = new GrowthToolItem()
    t8.label = '年度报告'
    t8.subtitle = '数据回顾'
    t8.icon = 'chart'
    t8.action = 'annual'
    items.push(t8)
    const t9 = new GrowthToolItem()
    t9.label = '成长收藏'
    t9.subtitle = '个人内容库'
    t9.icon = 'heart'
    t9.action = 'favorites'
    items.push(t9)
    const t10 = new GrowthToolItem()
    t10.label = '成长徽章'
    t10.subtitle = '成就墙'
    t10.icon = 'check'
    t10.action = 'achievements'
    items.push(t10)
    const t11 = new GrowthToolItem()
    t11.label = '消息'
    t11.subtitle = '成长提醒'
    t11.icon = 'message'
    t11.action = 'messages'
    items.push(t11)
    return items
  }

  private handle(action: string): void {
    this.onClose()
    if (action === 'ritual') {
      this.onOpenRitual()
      return
    }
    if (action === 'stuck') {
      this.onOpenStuck()
      return
    }
    if (action === 'contrast') {
      this.onOpenContrast()
      return
    }
    if (action === 'theme') {
      this.onOpenTheme()
      return
    }
    if (action === 'habit') {
      this.onOpenHabits()
      return
    }
    if (action === 'review') {
      this.onOpenReviews()
      return
    }
    if (action === 'diagnose') {
      this.onOpenDiagnose()
      return
    }
    if (action === 'organize') {
      this.onOpenOrganize()
      return
    }
    if (action === 'annual') {
      this.onOpenAnnualReport()
      return
    }
    if (action === 'favorites') {
      this.onOpenFavorites()
      return
    }
    if (action === 'achievements') {
      this.onOpenAchievements()
      return
    }
    if (action === 'messages') {
      this.onOpenMessages()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: 20, color: Theme.colors().textSecondary })
            .rotate({ angle: 180 })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('成长工具箱')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      Text('仪式、工坊、习惯与回顾')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
      Scroll() {
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach(this.tools(), (item: GrowthToolItem) => {
            Column({ space: 6 }) {
              Column() {
                AppIcon({ name: item.icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.lg)
              Text(item.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(item.subtitle)
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('30%')
            .margin({ bottom: Theme.space.s4 })
            .onClick((): void => { this.handle(item.action) })
          }, (item: GrowthToolItem) => item.action)
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
