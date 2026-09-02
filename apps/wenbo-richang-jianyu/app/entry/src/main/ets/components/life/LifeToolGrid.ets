import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { LifeToolEntry } from '../../models/LifeHubModels'
import { LifeHubNav } from '../../services/LifeHubNav'

@Component
export struct LifeToolGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop fromMenu: boolean = false
  private tools: LifeToolEntry[] = LifeHubNav.tools()

  private iconOf(name: string): AppIconName {
    if (name === 'heart') {
      return 'heart'
    }
    if (name === 'alert') {
      return 'alert'
    }
    if (name === 'check') {
      return 'check'
    }
    if (name === 'calendar') {
      return 'calendar'
    }
    if (name === 'book') {
      return 'book'
    }
    if (name === 'search') {
      return 'search'
    }
    if (name === 'ai') {
      return 'ai'
    }
    if (name === 'photo') {
      return 'photo'
    }
    if (name === 'biz') {
      return 'biz'
    }
    return 'chart'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('生活工具箱')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tools, (t: LifeToolEntry) => {
          Column({ space: 6 }) {
            AppIcon({
              name: this.iconOf(t.icon),
              iconSize: Theme.icon.md,
              color: Theme.colors().brandPrimary
            })
            Text(t.title)
              .fontSize(Theme.type.caption)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .maxLines(1)
            Text(t.subtitle)
              .fontSize(Theme.type.overline)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
              .textAlign(TextAlign.Center)
          }
          .width('31%')
          .height(108)
          .padding(Theme.space.s2)
          .margin({ right: '2%', bottom: Theme.space.s3 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick((): void => { LifeHubNav.open(t.id, this.fromMenu) })
        }, (t: LifeToolEntry) => t.id)
      }
      .width('100%')
    }
    .width('100%')
  }
}
