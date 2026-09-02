import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CardListCard } from '../components/treasure/TreasureCards'
import { TreasureCard, VaultRecord } from '../models/TreasureModels'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { TreasureBizService } from '../services/TreasureBizService'
import { TreasureMedia } from '../services/TreasureMedia'
import { TreasureNav } from '../services/TreasureNav'
import { VaultStore } from '../services/VaultStore'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'

@Component
export struct VaultPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '知识探宝'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('vaultTotalPoints') totalPoints: number = 0
  @StorageLink('vaultWeekPoints') weekPoints: number = 0
  @StorageLink('vaultStreak') streakDays: number = 0
  @StorageLink('vaultFavoriteCount') favoriteCount: number = 0
  @StorageLink('vaultTodayCount') todayCount: number = 0
  @StorageLink('treasureTick') @Watch('onVaultTick') tick: number = 0
  @State favoriteCards: TreasureCard[] = []
  @State records: VaultRecord[] = []
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}

  aboutToAppear(): void {
    void this.reloadFavorites()
  }

  onVaultTick(): void {
    void this.reloadFavorites()
  }

  private async reloadFavorites(): Promise<void> {
    const ids = VaultStore.favoriteCards()
    const all = await TreasureBizService.loadCards()
    const favs: TreasureCard[] = []
    for (const id of ids) {
      const found = TreasureBizService.findInList(all, id)
      if (found !== undefined) {
        favs.push(found)
      }
    }
    this.favoriteCards = favs
    this.records = VaultStore.snapshot().records
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private openSettings(): void {
    this.confirmDelete = false
    this.showSettings = true
    AppStorage.setOrCreate('vaultSettingsOpen', true)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSettings(): void {
    this.showSettings = false
    AppStorage.setOrCreate('vaultSettingsOpen', false)
    if (!TreasureNav.keepTabHidden()) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.closeSettings()
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private handleClearCache(): void {
    AppStorage.setOrCreate('localCacheEpoch', Date.now())
    this.showToast('已清除本地缓存')
  }

  private async handleDeleteAccount(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认注销账号')
      return
    }
    const ok = await PrivacyService.deleteAccount()
    if (ok) {
      await AuthService.logout()
      this.closeSettings()
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Text('我的宝库')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                this.StatTile('智慧积分', `${this.totalPoints}`)
                this.StatTile('连续探宝', `${this.streakDays} 天`)
                this.StatTile('收藏', `${this.favoriteCount}`)
              }
              .width('100%')

              Text(`本周 +${this.weekPoints} 积分 · 今日闯关 ${this.todayCount}/5`)
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text(this.isLoggedIn() ? this.currentUsername : '游客')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(this.isLoggedIn() ? '已登录，可同步账号' : '游客可浏览，写操作需登录')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                if (this.isLoggedIn()) {
                  AppButton({
                    label: '退出',
                    variant: 'ghost',
                    onTap: (): void => {
                      void AuthService.logout()
                      this.onLogout()
                    }
                  })
                } else {
                  AppButton({
                    label: '登录',
                    variant: 'secondary',
                    onTap: (): void => { this.onOpenLogin() }
                  })
                }
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)

              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text('协议 · 撤回 · 注销')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .onClick((): void => { this.openSettings() })

              Text('我的收藏')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.favoriteCards.length === 0) {
                AppEmpty({
                  title: '宝库还是空的',
                  description: '阅读卡片时点「收藏到宝库」'
                })
              } else {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.favoriteCards, (c: TreasureCard) => {
                    CardListCard({
                      categoryLabel: c.categoryLabel,
                      category: c.category,
                      title: c.title,
                      summary: c.summary,
                      cover: TreasureMedia.resource(c.coverKey.length > 0 ? c.coverKey : c.category),
                      onOpen: (): void => { TreasureNav.openCard(c.id) }
                    })
                  }, (c: TreasureCard) => c.id)
                }
                .width('100%')
              }

              Text('闯关记录')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              if (this.records.length === 0) {
                AppEmpty({ title: '还没有闯关记录', description: '完成每日 5 题后这里会有记录' })
              } else {
                Column({ space: Theme.space.s2 }) {
                  ForEach(this.records.slice(0, 8), (r: VaultRecord) => {
                    Row() {
                      Column({ space: 4 }) {
                        Text(r.title)
                          .fontSize(Theme.type.body)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .maxLines(1)
                        Text(`${r.categoryLabel} · ${r.at}`)
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      Text(r.correct ? `+${r.pointsEarned}` : '—')
                        .fontSize(Theme.type.subhead)
                        .fontColor(r.correct ? Theme.colors().success : Theme.colors().textTertiary)
                    }
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                  }, (r: VaultRecord) => r.id)
                }
                .width('100%')
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s3,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
          .zIndex(24)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  StatTile(label: string, value: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { this.closeSettings() })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
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
          AppButton({
            label: this.confirmDelete ? '再点一次确认注销' : '注销账号',
            variant: 'danger',
            onTap: (): void => { void this.handleDeleteAccount() }
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
