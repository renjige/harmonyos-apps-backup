import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppListRow } from '../components/design-system/AppListRow'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MinePanelHost } from '../components/mine/MinePanelHost'
import { AppSettings } from '../models/ShiyiModels'
import { PrivacyService } from '../services/PrivacyService'
import { ShiyiNav } from '../services/ShiyiNav'
import { ShiyiStore } from '../services/ShiyiStore'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '手账拾意'
  onToast: (text: string) => void = (text: string) => {}
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State showSettings: boolean = false
  @State showProfile: boolean = false
  @State showJournalSet: boolean = false
  @State showRemind: boolean = false
  @State showData: boolean = false
  @State showAbout: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State displayName: string = ''
  @State reminderGentle: boolean = true
  @State showRitual: boolean = true
  @State journalCount: number = 0
  @State pickupCount: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    const s = ShiyiStore.settings()
    this.displayName = s.displayName
    this.reminderGentle = s.reminderGentle
    this.showRitual = s.showRitual
    this.journalCount = ShiyiStore.journals().length
    this.pickupCount = ShiyiStore.pickups().length
  }

  private nameText(): string {
    if (this.displayName.trim().length > 0) {
      return this.displayName.trim()
    }
    return '拾意的人'
  }

  private openPanel(name: string): void {
    this.showSettings = name === 'settings'
    this.showProfile = name === 'profile'
    this.showJournalSet = name === 'journal'
    this.showRemind = name === 'remind'
    this.showData = name === 'data'
    this.showAbout = name === 'about'
    const anyOpen = this.showSettings || this.showProfile || this.showJournalSet || this.showRemind || this.showData || this.showAbout
    AppStorage.setOrCreate('shiyiMinePanel', anyOpen)
    AppStorage.setOrCreate('tabBarHidden', anyOpen)
  }

  private closePanels(): void {
    this.openPanel('')
    ShiyiNav.restoreBar()
  }

  private async persistSettings(): Promise<void> {
    const s = new AppSettings()
    s.displayName = this.displayName.trim()
    s.reminderGentle = this.reminderGentle
    s.showRitual = this.showRitual
    const ok = await ShiyiStore.saveSettings(s)
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.closePanels()
    this.onToast('已撤回隐私同意，可在设置中再次阅读协议')
  }

  private async handleClear(): Promise<void> {
    const ok = await ShiyiStore.clearAll()
    if (!ok) {
      this.onToast('暂时无法保存，请稍后再试。')
      return
    }
    this.reload()
    this.closePanels()
    this.onToast('本机手账已清空')
  }

  private panelKind(): string {
    if (this.showSettings) {
      return 'settings'
    }
    if (this.showProfile) {
      return 'profile'
    }
    if (this.showJournalSet) {
      return 'journal'
    }
    if (this.showRemind) {
      return 'remind'
    }
    if (this.showData) {
      return 'data'
    }
    if (this.showAbout) {
      return 'about'
    }
    return ''
  }

  build() {
    Stack() {
      Column() {
        if (this.panelKind().length > 0) {
          MinePanelHost({
            kind: this.panelKind(),
            displayName: this.displayName,
            showRitual: this.showRitual,
            reminderGentle: this.reminderGentle,
            onBack: (): void => { this.closePanels() },
            onOpenAgreement: (): void => { this.legalKind = 'agreement'; this.showLegal = true },
            onOpenPrivacy: (): void => { this.legalKind = 'privacy'; this.showLegal = true },
            onRevoke: (): void => { void this.handleRevokePrivacy() },
            onNameChange: (v: string) => { this.displayName = v },
            onSaveProfile: (): void => {
              void this.persistSettings()
              this.closePanels()
              this.onToast('资料已保存在本机')
            },
            onRitualChange: (v: boolean) => {
              this.showRitual = v
              void this.persistSettings()
            },
            onRemindChange: (v: boolean) => {
              this.reminderGentle = v
              void this.persistSettings()
            },
            onClear: (): void => { void this.handleClear() }
          })
        } else {
          AppHeader({ title: '我的', subtitle: this.appName })
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Column({ space: 8 }) {
                Text(this.nameText())
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text(`${this.journalCount} 篇手账  ·  ${this.pickupCount} 句拾意  ·  保存在本机`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s5)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              Column() {
                AppListRow({ title: '我的资料', subtitle: '昵称只留在这台设备', onTap: (): void => { this.openPanel('profile') } })
                AppListRow({ title: '手账设置', subtitle: '今日三问是否出现在首页', onTap: (): void => { this.openPanel('journal') } })
                AppListRow({ title: '提醒设置', subtitle: '打开时轻轻提一句', onTap: (): void => { this.openPanel('remind') } })
                AppListRow({ title: '标签管理', subtitle: '生活、阅读，以及你自己的标签', onTap: (): void => { ShiyiNav.openTags() } })
                AppListRow({ title: '收藏', subtitle: '进入我的拾意', onTap: (): void => { ShiyiNav.openPickup() } })
                AppListRow({ title: '数据管理', subtitle: '清空本机手账', onTap: (): void => { this.openPanel('data') } })
                AppListRow({
                  title: '设置与隐私',
                  subtitle: '协议 · 撤回同意',
                  onTap: (): void => { this.openPanel('settings') }
                })
                AppListRow({ title: '关于手账拾意', subtitle: '版本 1.0.0', showDivider: false, onTap: (): void => { this.openPanel('about') } })
              }
              .width('100%')
              .padding({ left: Theme.space.s4, right: Theme.space.s4 })
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: (): void => {
            this.showLegal = false
          }
        })
          .width('100%')
          .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
