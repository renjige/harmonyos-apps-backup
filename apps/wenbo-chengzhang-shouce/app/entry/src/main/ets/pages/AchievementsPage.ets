import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AchievementBadgeItem, AchievementCatalog } from '../models/AchievementCatalog'
import { GrowthRecordItem } from '../models/GrowthModels'
import { AchievementService } from '../services/AchievementService'
import { GrowthBizService } from '../services/GrowthBizService'
import { AuthService } from '../services/AuthService'

@Component
export struct AchievementsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State unlocked: GrowthRecordItem[] = []
  @State catalog: AchievementBadgeItem[] = AchievementCatalog.all()
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.unlocked = await GrowthBizService.loadAchievements(this.currentUsername)
      const stats = await GrowthBizService.loadStats(this.currentUsername)
      this.unlocked = await AchievementService.syncFromStats(
        stats, this.unlocked, this.currentUsername, false
      )
    } else {
      this.unlocked = []
    }
    this.loading = false
  }

  private isBadgeUnlocked(badgeId: string): boolean {
    return AchievementService.isUnlocked(this.unlocked, badgeId)
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
        Text('成长徽章')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s4 })

      Text('完成记录、目标与坚持即可点亮')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s2 })
      if (this.loading) {
        AppLoading({ label: '加载徽章…' }).layoutWeight(1)
      } else if (!AuthService.isLoggedIn()) {
        Column() {
          AppEmpty({
            title: '登录后查看徽章墙',
            description: '写下第一条记录即可解锁「初芽新手」',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.catalog, (badge: AchievementBadgeItem) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({
                    name: 'check',
                    iconSize: Theme.icon.md,
                    color: this.isBadgeUnlocked(badge.badgeId) ?
                      Theme.colors().brandAccent : Theme.colors().textTertiary
                  })
                }
                .width(48)
                .height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.isBadgeUnlocked(badge.badgeId) ?
                  Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                Column({ space: 4 }) {
                  Text(badge.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(badge.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(this.isBadgeUnlocked(badge.badgeId) ? '已点亮' : '待解锁')
                    .fontSize(Theme.type.overline)
                    .fontColor(this.isBadgeUnlocked(badge.badgeId) ?
                      Theme.colors().brandPrimary : Theme.colors().textTertiary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            }, (badge: AchievementBadgeItem) => badge.badgeId)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
