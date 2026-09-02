import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { ZhaConfirmDialog } from '../components/zha/ZhaConfirmDialog'
import { LegalDocs } from '../models/LegalDocs'
import { ZhaAppStats } from '../models/ZhaModels'
import { PrivacyService } from '../services/PrivacyService'
import { ZhaLocalStore } from '../services/ZhaLocalStore'

@Component
export struct SettingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State stats: ZhaAppStats = new ZhaAppStats()
  @State showDoc: boolean = false
  @State docKind: LegalDocKind = 'privacy'
  @State toast: string = ''
  @State darkMode: boolean = false
  @State confirmClear: boolean = false
  @State confirmRevoke: boolean = false
  @State showAbout: boolean = false
  onRevokePrivacy: () => void = () => {}
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    this.darkMode = Theme.isDark()
    void this.loadStats()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.loadStats()
    }
  }

  private async loadStats(): Promise<void> {
    this.stats = await ZhaLocalStore.loadStats()
    this.darkMode = await ZhaLocalStore.isDarkMode()
  }

  private async toggleDark(): Promise<void> {
    this.darkMode = !this.darkMode
    await ZhaLocalStore.setDarkMode(this.darkMode)
    const tick = AppStorage.get<number>('zhaThemeTick')
    const next = tick === undefined ? 1 : tick + 1
    AppStorage.setOrCreate('zhaThemeTick', next)
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2800)
  }

  private async clearAllData(): Promise<void> {
    await ZhaLocalStore.clearAllData()
    await this.loadStats()
    this.onDataChanged()
    this.showToast('已清除本机笔记、待办与札记')
  }

  @Builder
  MenuRow(icon: AppIconName, title: string, subtitle: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        AppIcon({ name: icon, iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().textPrimary)
        if (subtitle.length > 0) {
          Text(subtitle)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
      }
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 4 }) {
            Text('设置')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
            Text('松岚札 · 智慧生活记录')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ top: Theme.space.pageY })

          Row({ space: Theme.space.s4 }) {
            Column({ space: 4 }) {
              Text(`${this.stats.noteCount}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().brandPrimary)
              Text('笔记')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
            Column({ space: 4 }) {
              Text(`${this.stats.todoActive}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().brandAccent)
              Text('待办')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
            Column({ space: 4 }) {
              Text(`${this.stats.journalDays}`)
                .fontSize(Theme.type.title2)
                .fontColor(Theme.colors().brandPrimary)
              Text('札记天')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }.layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          this.MenuRow('biz', '关于松岚札', '版本、运营者与数据说明', () => {
            this.showAbout = true
          })
          this.MenuRow('biz', '隐私政策', '查看全文', () => {
            this.docKind = 'privacy'
            this.showDoc = true
          })
          this.MenuRow('biz', '用户协议', '查看全文', () => {
            this.docKind = 'agreement'
            this.showDoc = true
          })
          this.MenuRow('gear', '深色模式', this.darkMode ? '已开启' : '浅色模式', () => {
            void this.toggleDark()
          })
          this.MenuRow('alert', '清除本机数据', '删除笔记、待办与札记', () => {
            this.confirmClear = true
          })

          AppButton({
            label: '撤回隐私同意',
            variant: 'secondary',
            onTap: (): void => { this.confirmRevoke = true }
          })

          Text('版本 1.0.0 · 运营者：承德锐泓科技有限公司\n完全免费 · 无广告 · 无内购 · 数据默认本机存储')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .lineHeight(18)
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .scrollBar(BarState.Off)

      if (this.showAbout) {
        Column() {
          Row() {
            Text('关于')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            Text('关闭')
              .fontColor(Theme.colors().brandPrimary)
              .onClick(() => { this.showAbout = false })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          Scroll() {
            Text('松岚札是一款智慧生活记录与轻量笔记工具。\n\n' +
              '核心功能：智慧笔记、待办清单、每日札记。\n\n' +
              LegalDocs.privacySummaryLine() + '\n\n' +
              '运营者：承德锐泓科技有限公司 · 版本 1.0.0')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .lineHeight(22)
              .padding(Theme.space.pageX)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }

      if (this.showDoc) {
        Column() {
          LegalDocOverlay({
            kind: this.docKind,
            onClose: () => { this.showDoc = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(20)
      }

      if (this.confirmClear) {
        ZhaConfirmDialog({
          title: '清除本机数据',
          message: '将永久删除本机所有笔记、待办与札记，此操作不可恢复。是否继续？',
          confirmLabel: '确认清除',
          danger: true,
          onConfirm: () => {
            this.confirmClear = false
            void this.clearAllData()
          },
          onCancel: () => { this.confirmClear = false }
        })
      }

      if (this.confirmRevoke) {
        ZhaConfirmDialog({
          title: '撤回隐私同意',
          message: '撤回后将退出应用数据访问授权，再次进入须重新同意隐私政策。是否继续？',
          confirmLabel: '确认撤回',
          onConfirm: (): void => { void this.handleRevoke() },
          onCancel: () => { this.confirmRevoke = false }
        })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  private async handleRevoke(): Promise<void> {
    this.confirmRevoke = false
    await PrivacyService.revoke()
    this.onRevokePrivacy()
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }
}
