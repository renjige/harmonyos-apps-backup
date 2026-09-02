import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ArchiveCategory, ArchiveStats, MonthlyBar, ReviewSummary } from '../models/ArchiveModels'
import { AchievementDef } from '../models/LifeModels'
import { ArchiveStore } from '../services/ArchiveStore'
import { ArchiveStatsService } from '../services/ArchiveStatsService'
import { AchievementService } from '../services/AchievementService'
import { PrivacyService } from '../services/PrivacyService'
import { LifeStore } from '../services/LifeStore'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  onDataChanged: () => void = () => {}
  onSwitchTab: (index: number) => void = () => {}
  @State stats: ArchiveStats = new ArchiveStats()
  @State review: ReviewSummary = new ReviewSummary()
  @State achievements: AchievementDef[] = []
  @State unlockedIds: string[] = []
  @State categories: ArchiveCategory[] = []
  @State tags: string[] = []
  @State nickname: string = ''
  @State themeMode: string = 'system'
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State toastText: string = ''
  @State newTagInput: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    await AchievementService.checkAndUnlock()
    this.stats = await ArchiveStatsService.computeStats()
    this.review = await ArchiveStatsService.buildReview()
    this.achievements = AchievementDef.catalog()
    this.unlockedIds = await LifeStore.loadUnlockedAchievements()
    this.categories = await ArchiveStore.loadCategories()
    this.tags = await ArchiveStore.loadTags()
    const profile = await ArchiveStore.loadProfile()
    this.nickname = profile.nickname
    this.themeMode = profile.themeMode.length > 0 ? profile.themeMode : 'system'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async exportJson(): Promise<void> {
    const json = await ArchiveStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('JSON 已复制到剪贴板')
    } catch {
      this.showToast('复制失败，请稍后重试')
    }
  }

  private async clearAllData(): Promise<void> {
    await ArchiveStore.clearAll()
    this.confirmClear = false
    this.onDataChanged()
    await this.reload()
    this.showToast('全部档案数据已清除')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次进入须重新勾选协议')
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    const profile = await ArchiveStore.loadProfile()
    profile.themeMode = mode
    await ArchiveStore.saveProfile(profile)
    const ctx = AppContextService.getContext()
    ThemeAppearance.apply(mode, ctx !== null ? ctx : undefined)
    this.showToast('主题已切换')
  }

  private async addTag(): Promise<void> {
    const t = this.newTagInput.trim()
    if (t.length === 0) {
      return
    }
    await ArchiveStore.addTag(t)
    this.newTagInput = ''
    this.tags = await ArchiveStore.loadTags()
    this.showToast('标签已添加')
  }

  private async removeTag(tag: string): Promise<void> {
    await ArchiveStore.removeTag(tag)
    this.tags = await ArchiveStore.loadTags()
    this.showToast('标签已删除')
  }

  private async persistNickname(): Promise<void> {
    const profile = await ArchiveStore.loadProfile()
    profile.nickname = this.nickname.trim().length > 0 ? this.nickname.trim() : '档案守护者'
    await ArchiveStore.saveProfile(profile)
    this.nickname = profile.nickname
    this.showToast('昵称已保存')
  }

  private isAchievementUnlocked(id: string): boolean {
    for (const uid of this.unlockedIds) {
      if (uid === id) {
        return true
      }
    }
    return false
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s4 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            Column({ space: Theme.space.s1 }) {
              TextInput({ text: this.nickname, placeholder: '昵称' })
                .fontSize(Theme.type.title3)
                .fontColor(Theme.colors().textPrimary)
                .backgroundColor('transparent')
                .onChange((v: string): void => { this.nickname = v })
                .onSubmit((): void => { void this.persistNickname() })
              Text('本地档案 · 点击昵称可编辑')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '档案', value: `${this.stats.totalArchives}` }).layoutWeight(1)
            AppStatCard({ label: '节点', value: `${this.stats.totalNodes}` }).layoutWeight(1)
          }
          .width('100%')

          Row() {
            Text(`成就 · ${this.unlockedIds.length}/${this.achievements.length}`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            Text('查看统计')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.onSwitchTab(3) })
          }
          .width('100%')

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.achievements, (a: AchievementDef) => {
              Column({ space: 4 }) {
                Text(a.emoji)
                  .fontSize(24)
                  .opacity(this.isAchievementUnlocked(a.id) ? 1 : 0.35)
                Text(a.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.isAchievementUnlocked(a.id) ?
                    Theme.colors().textPrimary : Theme.colors().textTertiary)
                  .maxLines(1)
              }
              .width('48%')
              .padding(Theme.space.s3)
              .margin({ bottom: Theme.space.s2 })
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
              .alignItems(HorizontalAlign.Center)
            }, (a: AchievementDef) => a.id)
          }
          .width('100%')

          Text('时光回顾')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text(this.review.title)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandAccent)
            Text(this.review.body)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(22)
            ForEach(this.review.highlights, (h: string) => {
              Text(`· ${h}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textPrimary)
            }, (h: string) => h)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .alignItems(HorizontalAlign.Start)

          if (this.stats.monthlyBars.length > 0) {
            Text('近 6 月节点')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              ForEach(this.stats.monthlyBars, (bar: MonthlyBar) => {
                Column({ space: 4 }) {
                  Column()
                    .width(20)
                    .height(bar.count * 12 + 8)
                    .backgroundColor(Theme.colors().brandAccent)
                    .borderRadius(Theme.radius.xs)
                  Text(bar.monthLabel)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().textTertiary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }, (bar: MonthlyBar) => bar.monthLabel)
            }
            .width('100%')
            .height(80)
            .alignItems(VerticalAlign.Bottom)
          }

          Text('分类')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          ForEach(this.categories, (c: ArchiveCategory) => {
            Text(c.label)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
              .padding({ top: 8, bottom: 8 })
          }, (c: ArchiveCategory) => c.key)

          Text('标签管理')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            TextInput({ text: this.newTagInput, placeholder: '新标签' })
              .fontSize(Theme.type.body)
              .layoutWeight(1)
              .onChange((v: string): void => { this.newTagInput = v })
            AppButton({
              label: '添加',
              variant: 'secondary',
              onTap: (): void => { void this.addTag() }
            })
          }
          .width('100%')
          ForEach(this.tags, (tag: string) => {
            Row() {
              Text(tag)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .layoutWeight(1)
              Text('删除')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().danger)
                .onClick((): void => { void this.removeTag(tag) })
            }
            .width('100%')
            .padding({ top: 6, bottom: 6 })
          }, (tag: string) => tag)

          Text('数据管理')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          this.Phase3EntryRow('主题册', (): void => {
            AppStorage.setOrCreate('themeAlbumListOpen', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          })
          this.Phase3EntryRow('人生清单', (): void => {
            AppStorage.setOrCreate('checklistSheetOpen', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          })
          this.Phase3EntryRow('经验库', (): void => {
            AppStorage.setOrCreate('experienceLibraryOpen', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          })
          this.Phase3EntryRow('收藏中心', (): void => {
            AppStorage.setOrCreate('favoritesCenterOpen', true)
            AppStorage.setOrCreate('tabBarHidden', true)
          })

          AppButton({
            label: '导出 JSON 到剪贴板',
            variant: 'secondary',
            onTap: (): void => { void this.exportJson() }
          })
          AppButton({
            label: '清除全部档案数据',
            variant: 'secondary',
            onTap: (): void => { this.confirmClear = true }
          })

          Row() {
            Text('设置与隐私')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
            Blank()
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { this.showSettings = true })

          Text('时光档案 v1.0.0')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: this.bottomInset + Theme.space.s6
        })
      }
      .width('100%')
      .height('100%')

      if (this.showSettings) {
        this.SettingsPanel()
      }
      if (this.confirmRevoke) {
        this.ConfirmRevokeDialog()
      }
      if (this.confirmClear) {
        this.ConfirmClearDialog()
      }
      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(60)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  Phase3EntryRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { onTap() })
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }

  @Builder
  SettingsPanel() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showSettings = false })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('设置与隐私')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)

          Text('主题')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
            this.ThemeChip('跟随系统', 'system')
          }

          Row() {
            Text('《用户协议》')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .onClick((): void => { this.showAgreementDoc = true })

          Row() {
            Text('《隐私政策》')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .onClick((): void => { this.showPrivacyDoc = true })

          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { this.confirmRevoke = true }
            })
          }
          .width('100%')
          .onClick((): void => { this.confirmRevoke = true })

          AppButton({
            label: '关闭',
            variant: 'primary',
            onTap: (): void => { this.showSettings = false }
          })
        }
        .padding(Theme.space.s6)
      }
      .width('92%')
      .height('70%')
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
  }

  @Builder
  ConfirmClearDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.confirmClear = false })
      Column({ space: Theme.space.s4 }) {
        Text('确认清除全部数据？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text('将删除本机全部档案与节点，不可恢复。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmClear = false }
          }).layoutWeight(1)
          AppButton({
            label: '清除',
            variant: 'primary',
            onTap: (): void => { void this.clearAllData() }
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(55)
  }

  @Builder
  ConfirmRevokeDialog() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.confirmRevoke = false })
      Column({ space: Theme.space.s4 }) {
        Text('确认撤回隐私同意？')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text('撤回后须重新同意协议方可继续使用。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmRevoke = false }
          }).layoutWeight(1)
          AppButton({
            label: '撤回',
            variant: 'primary',
            onTap: (): void => { void this.handleRevokePrivacy() }
          }).layoutWeight(1)
        }
        .width('100%')
      }
      .width('84%')
      .padding(Theme.space.s6)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(60)
  }
}
