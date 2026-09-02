import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ExplorationStore } from '../services/ExplorationStore'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { common } from '@kit.AbilityKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('progressRev') @Watch('onProgress') progressRev: number = 0
  @StorageLink('explorerLevel') level: number = 1
  @StorageLink('explorerLevelTitle') levelTitle: string = ''
  @StorageLink('exploreCount') exploreCount: number = 0
  @StorageLink('discoveryCount') discoveryCount: number = 0
  @StorageLink('badgeCount') badgeCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  @StorageLink('topicCount') topicCount: number = 0
  @Prop appName: string = '元素探索者'
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State darkModeOn: boolean = false
  onToast: (msg: string) => void = () => {}

  aboutToAppear(): void {
    this.darkModeOn = Theme.isDark()
  }

  onProgress(): void {
  }

  private showToast(message: string): void {
    ExploreToast.show(message)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    await ExplorationStore.savePrivacyAccepted(false)
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次使用相关功能须重新确认')
  }

  private handleClearCache(): void {
    void ExplorationStore.clearCache()
    this.showToast('已清除本地缓存')
  }

  private toggleTheme(): void {
    const ctx = getContext(this) as common.UIAbilityContext
    this.darkModeOn = ThemeAppearance.toggle(ctx)
    void ExplorationStore.saveThemeMode(this.darkModeOn ? 'dark' : 'light')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.section }) {
              Row({ space: Theme.space.s4 }) {
                Stack({ alignContent: Alignment.Center }) {
                  Column()
                    .width(72)
                    .height(72)
                    .linearGradient({
                      angle: 135,
                      colors: [[Theme.colors().brandDeep, 0], [Theme.colors().brandPrimary, 1]]
                    })
                    .borderRadius(36)
                  AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: '#FFFFFF' })
                }
                Column({ space: 4 }) {
                  Text(`Lv.${this.level} ${this.levelTitle}`)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`🌿 ${this.appName}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(Theme.space.pageX)

              Scroll() {
                Row({ space: Theme.space.s3 }) {
                  this.StatChip(`${this.exploreCount}`, '📖 图鉴')
                  this.StatChip(`${this.discoveryCount}`, '✍️ 发现')
                  this.StatChip(`${this.streakDays}天`, '🔥 连续')
                  this.StatChip(`${this.badgeCount}`, '🏅 徽章')
                }
                .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')

              Column({ space: Theme.space.s3 }) {
                this.MenuRow('bookmark', '我的收藏', `${this.favoriteCount} 项`, (): void => {
                  ExploreNav.openFavorites()
                })
                this.MenuRow('grid', '探索专题', `${this.topicCount} 个`, (): void => {
                  ExploreNav.openTopics()
                })
                this.MenuRow('chart', '探索统计', '领域分布与收藏数据', (): void => {
                  ExploreNav.openStats()
                })
                this.MenuRow('clock', '探索时间轴', '回顾你的探索足迹', (): void => {
                  ExploreNav.openTimeline()
                })
                this.MenuRow('calendar', '探索日历', '按日期查看动态', (): void => {
                  ExploreNav.openCalendar()
                })
                this.MenuRow('sparkle', '成就徽章', `${this.badgeCount} 枚已解锁`, (): void => {
                  ExploreNav.openBadges()
                })
                this.MenuRow('biz', '7 日挑战', '养成探索习惯', (): void => {
                  ExploreNav.openChallenge()
                })
                this.MenuRow('chart', '领域地图', '五大领域点亮进度', (): void => {
                  ExploreNav.openDomainMap()
                })
                this.MenuRow('gear', '设置与隐私', '主题 · 协议 · 撤回', (): void => {
                  this.showSettings = true
                })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .padding({ bottom: Theme.space.s10 + LayoutConstants.tabBarInset() })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
          .zIndex(25)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatChip(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .padding({
      left: Theme.space.s4,
      right: Theme.space.s4,
      top: Theme.space.s3,
      bottom: Theme.space.s3
    })
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  MenuRow(icon: AppIconName, title: string, subtitle: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({
          name: icon,
          iconSize: Theme.icon.md,
          color: Theme.colors().brandPrimary
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.showSettings = false })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row({ space: Theme.space.s3 }) {
            Text('深色模式')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkModeOn })
              .onChange((v: boolean): void => {
                if (v !== this.darkModeOn) {
                  this.toggleTheme()
                }
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'agreement'
              this.showLegal = true
            }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => {
              this.legalKind = 'privacy'
              this.showLegal = true
            }
          })
          AppButton({
            label: '清除缓存',
            variant: 'secondary',
            onTap: (): void => { this.handleClearCache() }
          })
          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleRevokePrivacy() })
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
    .width('100%')
    .height('100%')
  }
}
