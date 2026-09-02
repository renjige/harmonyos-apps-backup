import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { LifeHubNav } from '../../services/LifeHubNav'

class QuickChip {
  id: string = ''
  label: string = ''
  icon: AppIconName = 'home'

  constructor(id: string, label: string, icon: AppIconName) {
    this.id = id
    this.label = label
    this.icon = icon
  }
}

@Component
export struct HomeQuickRow {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onWrite: () => void = () => {}
  private chips: QuickChip[] = [
    new QuickChip('inspire', '灵感', 'ai'),
    new QuickChip('plan', '计划', 'check'),
    new QuickChip('growth', '成长', 'chart'),
    new QuickChip('write', '创作', 'book'),
    new QuickChip('mood', '心情', 'heart'),
    new QuickChip('search', '搜索', 'search')
  ]

  private tap(id: string): void {
    if (id === 'inspire') {
      AppStorage.setOrCreate('pendingTab', 1)
      return
    }
    if (id === 'plan') {
      AppStorage.setOrCreate('pendingTab', 2)
      return
    }
    if (id === 'growth') {
      AppStorage.setOrCreate('pendingTab', 4)
      return
    }
    if (id === 'write') {
      this.onWrite()
      return
    }
    if (id === 'mood') {
      LifeHubNav.open('mood', false)
      return
    }
    LifeHubNav.open(id, false)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('快捷操作')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.chips, (c: QuickChip) => {
          Column({ space: 6 }) {
            AppIcon({ name: c.icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
            Text(c.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }
          .width('31%')
          .height(72)
          .margin({ right: '2%', bottom: Theme.space.s3 })
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.tap(c.id) })
        }, (c: QuickChip) => c.id)
      }
      .width('100%')
    }
    .width('100%')
  }
}
