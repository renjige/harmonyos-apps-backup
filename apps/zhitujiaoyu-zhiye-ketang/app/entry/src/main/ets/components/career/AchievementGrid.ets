import { Theme } from '../design-system/Theme'
import { AppIcon, AppIconName } from '../design-system/AppIcon'
import { BadgeItem } from '../../models/CareerModels'

/** 成就徽章网格 — 解锁态高亮 */
@Component
export struct AchievementGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop badges: BadgeItem[] = []

  private iconOf(name: string): AppIconName {
    if (name === 'chart') return 'chart'
    if (name === 'biz') return 'biz'
    if (name === 'ai') return 'ai'
    if (name === 'message') return 'message'
    return 'check'
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('学习成就')
        .fontSize(Theme.type.subtitleS)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      GridRow({ columns: 4, gutter: Theme.space.s3 }) {
        ForEach(this.badges, (b: BadgeItem) => {
          GridCol() {
            Column({ space: 4 }) {
              Column() {
                AppIcon({
                  name: this.iconOf(b.iconName),
                  iconSize: Theme.icon.md,
                  color: b.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(b.unlocked ?
                Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .opacity(b.unlocked ? 1 : 0.55)
              Text(b.title)
                .fontSize(10)
                .fontColor(b.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
          }
        }, (b: BadgeItem) => b.id)
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
