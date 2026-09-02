import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AchievementDef, FeedItem, SilanStats } from '../models/SilanModels'
import { SilanQuery } from '../services/SilanQuery'
import { SilanStore } from '../services/SilanStore'
import { SilanNav } from '../services/SilanNav'
import { PrivacyService } from '../services/PrivacyService'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('silanDataRev') @Watch('onDataRevChange') silanDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  onPrivacyRevoked: () => void = () => {}
  onDataChanged: () => void = () => {}
  @State stats: SilanStats = new SilanStats()
  @State achievements: AchievementDef[] = []
  @State unlocked: string[] = []
  @State favorites: FeedItem[] = []
  @State nickname: string = ''
  @State themeMode: string = 'system'
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State confirmRevoke: boolean = false
  @State confirmClear: boolean = false
  @State toastText: string = ''
  @State showFav: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.unlocked = await SilanQuery.unlockAchievements()
    this.stats = await SilanQuery.stats()
    this.achievements = AchievementDef.catalog()
    this.favorites = await SilanQuery.favorites()
    const p = await SilanStore.loadProfile()
    this.nickname = p.nickname
    this.themeMode = p.themeMode.length > 0 ? p.themeMode : 'system'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private isOn(id: string): boolean {
    return this.unlocked.includes(id)
  }

  private async exportJson(): Promise<void> {
    const json = await SilanStore.exportJson()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, json)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('档案摘要已复制到剪贴板')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async persistTheme(mode: string): Promise<void> {
    this.themeMode = mode
    const p = await SilanStore.loadProfile()
    p.themeMode = mode
    await SilanStore.saveProfile(p)
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.confirmRevoke = false
    this.showSettings = false
    this.onPrivacyRevoked()
    this.showToast('已撤回隐私同意，再次进入须重新勾选协议')
  }

  private async handleClearCache(): Promise<void> {
    this.confirmClear = false
    this.showToast('缓存已清理（档案仍保留在本机）')
  }

  private async saveNick(): Promise<void> {
    const p = await SilanStore.loadProfile()
    p.nickname = this.nickname
    await SilanStore.saveProfile(p)
    this.showToast('已保存称呼')
  }

  private openFav(it: FeedItem): void {
    if (it.kind === 'reading') {
      SilanNav.openReading(it.id)
      return
    }
    if (it.kind === 'card') {
      SilanNav.openCard(it.id)
      return
    }
    if (it.kind === 'spark') {
      SilanNav.openSpark(it.id)
      return
    }
    SilanNav.openThought(it.id)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppIcon({ name: 'user', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
            }
            .width(56)
            .height(56)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(28)
            Column({ space: 4 }) {
              Text(this.nickname.length > 0 ? this.nickname : '思览人')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
              Text(`连续记录 ${this.stats.streakDays} 天`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')

          Text('成就墙')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.achievements, (a: AchievementDef) => {
              Column({ space: 4 }) {
                Text(this.isOn(a.id) ? '已点亮' : '未点亮')
                  .fontSize(10)
                  .fontColor(this.isOn(a.id) ? Theme.colors().brandAccent : Theme.colors().textSecondary)
                Text(a.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textPrimary)
                  .maxLines(1)
                Text(a.hint)
                  .fontSize(10)
                  .fontColor(Theme.colors().textSecondary)
                  .maxLines(2)
              }
              .width('47%')
              .padding(Theme.space.s3)
              .margin({ right: '3%', bottom: 10 })
              .backgroundColor(this.isOn(a.id) ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (a: AchievementDef) => a.id)
          }
          .width('100%')

          this.MenuRow('bookmark', '观点收藏', `${this.favorites.length} 条`, (): void => { this.showFav = true })
          this.MenuRow('search', '搜索档案', '标题 / 正文 / 标签', (): void => { SilanNav.openSearch() })
          this.MenuRow('gear', '设置与隐私', '协议 · 撤回 · 主题', (): void => { this.showSettings = true })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: this.bottomInset + 24 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)

      if (this.showFav) {
        Column() {
          Row() {
            Text('观点收藏').fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary).layoutWeight(1)
            Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { this.showFav = false })
          }
          .padding(Theme.space.s4)
          .width('100%')
          if (this.favorites.length === 0) {
            Text('还没有收藏。在详情页可以把重要观点收入观点库。')
              .fontColor(Theme.colors().textSecondary)
              .padding(Theme.space.s4)
          } else {
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.favorites, (it: FeedItem) => {
                  Text(it.title)
                    .fontColor(Theme.colors().textPrimary)
                    .padding(Theme.space.s3)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.sm)
                    .width('100%')
                    .onClick((): void => { this.showFav = false; this.openFav(it) })
                }, (it: FeedItem) => it.id)
              }
              .padding(Theme.space.s4)
            }
            .layoutWeight(1)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().surfacePage)
      }

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .margin({ top: 12 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  MenuRow(icon: string, title: string, sub: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      AppIcon({ name: icon === 'bookmark' ? 'bookmark' : (icon === 'search' ? 'search' : 'gear'), iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      Column({ space: 2 }) {
        Text(title).fontSize(Theme.type.subtitleS).fontColor(Theme.colors().textPrimary)
        Text(sub).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私').fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary).layoutWeight(1)
        Text('关闭').fontColor(Theme.colors().brandPrimary).onClick((): void => { this.showSettings = false })
      }
      .padding(Theme.space.s4)
      .width('100%')

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.nickname, placeholder: '本机称呼（可选）' })
            .onChange((v: string) => { this.nickname = v })
          AppButton({ label: '保存称呼', variant: 'secondary', onTap: (): void => { void this.saveNick() } })

          Text('外观').fontColor(Theme.colors().textSecondary).width('100%')
          Row({ space: 8 }) {
            this.ThemeChip('system', '跟随系统')
            this.ThemeChip('light', '浅色')
            this.ThemeChip('dark', '深色')
          }

          AppButton({ label: '查看《用户协议》', variant: 'ghost', onTap: (): void => { this.showAgreementDoc = true } })
          AppButton({ label: '查看《隐私政策》', variant: 'ghost', onTap: (): void => { this.showPrivacyDoc = true } })
          AppButton({ label: '导出档案摘要', variant: 'secondary', onTap: (): void => { void this.exportJson() } })
          AppButton({ label: '清除缓存', variant: 'secondary', onTap: (): void => { this.confirmClear = true } })

          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { this.confirmRevoke = true }
            })
          }
          .width('100%')
          .onClick((): void => { this.confirmRevoke = true })

          if (this.confirmRevoke) {
            Text('撤回后需重新勾选协议才能继续使用。确定？')
              .fontColor(Theme.colors().textPrimary)
            AppButton({ label: '确定撤回', variant: 'danger', onTap: (): void => { void this.handleRevokePrivacy() } })
            AppButton({ label: '取消', variant: 'ghost', onTap: (): void => { this.confirmRevoke = false } })
          }
          if (this.confirmClear) {
            AppButton({ label: '确认清除缓存', variant: 'danger', onTap: (): void => { void this.handleClearCache() } })
            AppButton({ label: '取消', variant: 'ghost', onTap: (): void => { this.confirmClear = false } })
          }

          Text('思览叙 1.0.0 · 数据仅保存在本机 · 运营者薛茂新')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  ThemeChip(mode: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.persistTheme(mode) })
  }
}
