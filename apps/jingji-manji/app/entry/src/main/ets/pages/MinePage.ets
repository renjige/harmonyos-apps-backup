import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AuthService } from '../services/AuthService'
import { PrivacyService } from '../services/PrivacyService'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ProfileStore } from '../services/ProfileStore'
import { SportAnalytics } from '../services/SportAnalytics'
import { AchievementEngine } from '../services/AchievementEngine'
import { AchievementItem, SportSummary, UserProfile } from '../models/SportModels'
import { ExportService } from '../services/ExportService'
import { SportDetailNav } from '../services/SportDetailNav'
import { LocalCacheService } from '../services/LocalCacheService'
import { FavoriteStore } from '../services/FavoriteStore'
import { TagService, TagItem } from '../services/TagService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '竞技漫记'
  @StorageLink('accessToken') accessToken: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @State showSettings: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State confirmDelete: boolean = false
  @State profile: UserProfile = new UserProfile()
  @State summary: SportSummary = new SportSummary()
  @State achievements: AchievementItem[] = []
  @State tagTopics: TagItem[] = []
  @State favoriteCount: number = 0
  @State nextBadgeHint: string = ''
  @State editNickname: string = ''
  @State editBio: string = ''
  @State editGoal: string = '12'
  @State darkMode: boolean = true
  @State confirmClearCache: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.profile = ProfileStore.get()
    this.summary = SportAnalytics.summarize()
    this.achievements = AchievementEngine.evaluate()
    this.tagTopics = TagService.allTags()
    this.favoriteCount = FavoriteStore.count()
    const nextBadge = AchievementEngine.nextBadge()
    this.nextBadgeHint = nextBadge !== null ? `下一枚：${nextBadge.title} — ${nextBadge.description}` : ''
    this.editNickname = this.profile.nickname
    this.editBio = this.profile.bio
    this.editGoal = `${this.profile.monthlyGoalSessions}`
    this.darkMode = Theme.isDark()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    if (this.isLoggedIn()) {
      await AuthService.logout()
      this.onLogout()
    }
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回隐私同意，再次登录须重新勾选协议')
  }

  private async handleClearCache(): Promise<void> {
    if (!this.confirmClearCache) {
      this.confirmClearCache = true
      this.showToast('再点一次确认：将清除界面缓存与问卷草稿，运动记录与挑战保留')
      return
    }
    this.confirmClearCache = false
    await LocalCacheService.clearAll()
    this.reload()
    this.onDataChanged()
    this.showToast('已清除界面缓存，运动记录与挑战数据已保留')
  }

  private async handleExport(): Promise<void> {
    const ok = await ExportService.copy()
    this.showToast(ok ? '成长轨迹已复制到剪贴板' : '复制失败，请重试')
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
      this.showSettings = false
      this.onLogout()
      this.showToast('账号已注销')
      return
    }
    this.showToast('注销失败，请稍后重试')
  }

  private async saveProfile(): Promise<void> {
    const p = ProfileStore.get()
    p.nickname = this.editNickname.trim().length > 0 ? this.editNickname.trim() : '运动者'
    p.bio = this.editBio.trim()
    const goal = parseInt(this.editGoal, 10)
    p.monthlyGoalSessions = isNaN(goal) || goal < 1 ? 12 : goal
    await ProfileStore.save(p)
    this.reload()
    this.onDataChanged()
    this.showToast('档案已保存')
  }

  private toggleTheme(): void {
    this.darkMode = !this.darkMode
    ThemeAppearance.apply(this.darkMode ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
    AppStorage.setOrCreate('colorMode', this.darkMode ? 'dark' : 'light')
  }

  private closeSettings(): void {
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private openLegal(kind: LegalDocKind): void {
    this.legalKind = kind
    this.showLegal = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeLegal(): void {
    this.showLegal = false
    AppStorage.setOrCreate('tabBarHidden', this.showSettings)
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              this.ProfileHero()
              this.StatsGrid()
              AppButton({
                label: '训练配比问卷',
                onTap: (): void => {
                  SportDetailNav.openDiagnose()
                }
              })
              AppButton({
                label: '复制成长轨迹',
                variant: 'secondary',
                onTap: (): void => {
                  void this.handleExport()
                }
              })
              this.FavoritesEntry()
              this.TagTopicsSection()
              this.AchievementWall()
              Row({ space: Theme.space.s3 }) {
                Column({ space: 2 }) {
                  Text('设置与隐私')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                  Text('协议 · 撤回同意 · 注销')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick(() => {
                this.confirmDelete = false
                this.showSettings = true
                AppStorage.setOrCreate('tabBarHidden', true)
              })

              if (this.isLoggedIn()) {
                AppButton({
                  label: '退出登录',
                  variant: 'secondary',
                  onTap: (): void => {
                    void AuthService.logout()
                    this.onLogout()
                  }
                })
              } else {
                AppButton({
                  label: '登录 / 注册',
                  onTap: (): void => { this.onOpenLogin() }
                })
              }
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s6,
              bottom: Theme.space.s10 + 72
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
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
          onClose: (): void => {
            this.closeLegal()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  ProfileHero() {
    Column({ space: Theme.space.s4 }) {
      this.ProfileBanner()
      this.ProfileEditCard()
    }
    .width('100%')
  }

  @Builder
  ProfileBanner() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.hero_sport_bg'))
        .width('100%')
        .height(148)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.xl)
      Column()
        .width('100%')
        .height(148)
        .borderRadius(Theme.radius.xl)
        .linearGradient({
          angle: 180,
          colors: Theme.heroScrim()
        })
      Row({ space: Theme.space.s4 }) {
        Row() {
          AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)

        Column({ space: 4 }) {
          Text(this.isLoggedIn() ? this.currentUsername : this.profile.nickname)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandOnPrimary)
          Text(this.profile.bio.length > 0 ? this.profile.bio : '记录每一次竞技表现，见证成长')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textOnScrimMuted)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(Theme.space.s5)
    }
    .width('100%')
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeStrong })
  }

  @Builder
  ProfileEditCard() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text('昵称')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.editNickname, placeholder: '运动者' })
          .onChange((v: string) => { this.editNickname = v })
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)
          .border({ width: 1, color: Theme.colors().strokeHairline })
      }
      .width('100%')

      Column({ space: Theme.space.s2 }) {
        Text('简介')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        TextInput({ text: this.editBio, placeholder: '写一句运动宣言…' })
          .onChange((v: string) => { this.editBio = v })
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textSecondary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)
          .border({ width: 1, color: Theme.colors().strokeHairline })
      }
      .width('100%')

      Row({ space: Theme.space.s3 }) {
        Text('月度目标（次）')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Row({ space: Theme.space.s2 }) {
          Text('−')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
            .width(36)
            .height(36)
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick(() => {
              const n = parseInt(this.editGoal, 10)
              const next = isNaN(n) ? 11 : Math.max(1, n - 1)
              this.editGoal = `${next}`
            })
          Text(this.editGoal)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
            .width(40)
            .textAlign(TextAlign.Center)
          Text('+')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
            .width(36)
            .height(36)
            .textAlign(TextAlign.Center)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick(() => {
              const n = parseInt(this.editGoal, 10)
              const next = isNaN(n) ? 13 : Math.min(60, n + 1)
              this.editGoal = `${next}`
            })
        }
      }
      .width('100%')

      AppButton({
        label: '保存档案',
        onTap: (): void => { void this.saveProfile() }
      })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 14,
      color: Theme.isDark() ? 'rgba(0,0,0,0.28)' : 'rgba(26,35,50,0.08)',
      offsetY: 6
    })
  }

  @Builder
  StatsGrid() {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppStatCard({ label: '累计次数', value: `${this.summary.totalSessions}`, accent: true })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Column() {
        AppStatCard({ label: '累计时长', value: `${this.summary.totalDurationMin} 分` })
      }
      .layoutWeight(1)
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
    .width('100%')
  }

  @Builder
  FavoritesEntry() {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text('我的收藏')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(`${this.favoriteCount} 条训练已收藏`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      SportDetailNav.openFavorites()
    })
  }

  @Builder
  TagTopicsSection() {
    if (this.tagTopics.length === 0) {
      Column() {
      }
    } else {
      Column({ space: Theme.space.s3 }) {
        Text('我的标签')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.tagTopics.slice(0, 10), (tag: TagItem) => {
            Text(`#${tag.name} · ${tag.count}`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
          }, (tag: TagItem) => tag.name)
        }
        .width('100%')
        Text('在训练记录的「标签」字段输入 #关键词 即可自动汇总。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s5)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })
    }
  }

  @Builder
  AchievementWall() {
    Column({ space: Theme.space.s3 }) {
      Text(`成就墙 · 已解锁 ${AchievementEngine.unlockedCount()}/${this.achievements.length}`)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      if (this.nextBadgeHint.length > 0) {
        Text(this.nextBadgeHint)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
      }

      Grid() {
        ForEach(this.achievements, (a: AchievementItem) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(a.emoji)
                .fontSize(28)
                .opacity(a.unlocked ? 1 : 0.35)
              Text(a.title)
                .fontSize(Theme.type.caption)
                .fontWeight(FontWeight.Medium)
                .fontColor(a.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                .textAlign(TextAlign.Center)
              Text(a.description)
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textSecondary)
                .textAlign(TextAlign.Center)
                .maxLines(2)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({
              width: 1,
              color: a.unlocked ? Theme.colors().brandAccent : Theme.colors().strokeHairline
            })
          }
        }, (a: AchievementItem) => a.id)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      Row({ space: Theme.space.s2 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick(() => {
          this.closeSettings()
        })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('深色模式')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
              .onChange((v: boolean) => {
                this.darkMode = v
                ThemeAppearance.apply(v ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
                AppStorage.setOrCreate('colorMode', v ? 'dark' : 'light')
              })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          AppButton({
            label: '查看《用户协议》',
            variant: 'secondary',
            onTap: (): void => {
              this.openLegal('agreement')
            }
          })
          AppButton({
            label: '查看《隐私政策》',
            variant: 'secondary',
            onTap: (): void => {
              this.openLegal('privacy')
            }
          })
          AppButton({
            label: this.confirmClearCache ? '再点一次确认清除界面缓存' : '清除界面缓存',
            variant: 'secondary',
            onTap: (): void => { void this.handleClearCache() }
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
          bottom: Theme.space.s10 + 32
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }
}
