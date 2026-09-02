import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { LearningHubService } from '../services/LearningHubService'
import { AchievementDef } from '../models/LearningHubModels'

@Component
export struct AchievementsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: AchievementDef[] = []

  aboutToAppear(): void {
    this.items = LearningHubService.achievements()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44).height(44).justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('学习成就')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      List({ space: Theme.space.s2 }) {
        ForEach(this.items, (row: AchievementDef) => {
          ListItem() {
            Row({ space: Theme.space.s3 }) {
              Column() {
                AppIcon({
                  name: row.unlocked ? 'ai' : 'empty',
                  iconSize: Theme.icon.lg,
                  color: row.unlocked ? Theme.colors().brandPrimary : Theme.colors().textTertiary
                })
              }
              .width(48).height(48).justifyContent(FlexAlign.Center)
              .backgroundColor(row.unlocked ?
                Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              Column({ space: 4 }) {
                Text(row.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(row.desc)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                if (row.unlocked) {
                  Text(`解锁于 ${row.unlockedAt.substring(0, 10)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().success)
                    .width('100%')
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .padding(Theme.space.s4)
            .width('100%')
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
          }
        }, (row: AchievementDef) => row.key)
      }
      .layoutWeight(1)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
    }
    .width('100%').height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(18)
  }
}
