import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { MineSettingsPane } from '../components/moment/MineSettingsPane'
import { UserProfile, TagStat, WeekSummary, DayActivity, MilestoneBadge } from '../models/MomentModels'
import { ActivityStrip } from '../components/moment/ActivityStrip'
import { MomentStore } from '../services/MomentStore'
import { DateHelper } from '../services/DateHelper'
import { PrivacyService } from '../services/PrivacyService'
import { MomentNav } from '../services/MomentNav'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State noteCount: number = 0
  @State usageDays: number = 1
  @State tags: TagStat[] = []
  @State themeMode: string = 'system'
  @State digest: WeekSummary = new WeekSummary()
  @State activityDays: DayActivity[] = []
  @State milestones: MilestoneBadge[] = []
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State showTags: boolean = false
  @State showSettings: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = await MomentStore.loadProfile()
    this.nicknameInput = this.profile.nickname
    const notes = await MomentStore.loadNotes()
    this.noteCount = notes.length
    this.usageDays = DateHelper.usageDays(this.profile.firstUseAt, Date.now())
    this.tags = await MomentStore.tagStats()
    this.digest = await MomentStore.todayDigest()
    this.activityDays = await MomentStore.last7DayActivity()
    this.milestones = await MomentStore.milestones()
    const mode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.themeMode = mode
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2600)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '记小事的人'
    await MomentStore.saveProfile(this.profile)
    this.showToast('昵称已保存')
  }

  private persistTheme(mode: string): void {
    this.themeMode = mode
    this.profile.themeMode = mode
    ThemeAppearance.apply(mode)
    void MomentStore.saveProfile(this.profile)
    this.showToast(mode === 'system' ? '已跟随系统外观' : (mode === 'dark' ? '已切换深色' : '已切换浅色'))
  }

  private async exportData(): Promise<void> {
    const text = await MomentStore.exportText()
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('已复制为文本，可粘贴到备忘录保存')
    } catch {
      this.showToast('导出失败')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回应用内同意记录。首次声明由应用市场托管，本机记录仍保留')
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? '#FFFFFF' : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.persistTheme(mode) })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
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
            Column({ space: Theme.space.s2 }) {
              TextInput({ text: this.nicknameInput, placeholder: '昵称' })
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .placeholderColor(Theme.colors().textTertiary)
                .caretColor(Theme.colors().brandPrimary)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .onChange((v: string): void => { this.nicknameInput = v })
              AppButton({
                label: '保存昵称',
                variant: 'secondary',
                onTap: (): void => { void this.saveNickname() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          Column({ space: 6 }) {
            Text('今日回顾')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Text(this.digest.line)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          ActivityStrip({ days: this.activityDays })

          Column({ space: Theme.space.s2 }) {
            Text('记录成就')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.milestones, (m: MilestoneBadge) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({
                    name: m.unlocked ? 'check' : 'empty',
                    iconSize: Theme.icon.md,
                    color: m.unlocked ? Theme.colors().success : Theme.colors().textTertiary
                  })
                }
                .width(32)
                .height(32)
                .justifyContent(FlexAlign.Center)
                Column({ space: 2 }) {
                  Text(m.title)
                    .fontSize(Theme.type.body)
                    .fontColor(m.unlocked ? Theme.colors().textPrimary : Theme.colors().textSecondary)
                  Text(m.detail)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
            }, (m: MilestoneBadge) => m.id)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          Row() {
            Column({ space: 4 }) {
              Text(`${this.noteCount}`)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('总记录')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            Column({ space: 4 }) {
              Text(`${this.usageDays}`)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandAccent)
              Text('使用天数')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          Text('外观（即时生效）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('跟随系统', 'system')
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
          }

          AppListRow({
            title: '全局搜索',
            subtitle: '搜索小事、待办与生活计划',
            onTap: (): void => { MomentNav.openSearch() }
          })
          AppListRow({
            title: '标签管理',
            subtitle: this.tags.length > 0 ? `${this.tags.length} 个标签在用` : '写下事后这里会出现统计',
            onTap: (): void => { this.showTags = true }
          })
          AppListRow({ title: '导出为文本', onTap: (): void => { void this.exportData() } })
          AppListRow({ title: '设置与隐私', subtitle: '协议 · 撤回 · 清除缓存', onTap: (): void => {
            this.showSettings = true
            AppStorage.setOrCreate('tabBarHidden', true)
          } })

          Column({ space: 4 }) {
            Text('关于小事记')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('版本 1.1.1 · 运营者承德锐泓科技有限公司\n个人生活记录与回忆管理 · 数据仅存本机')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(20)
          }
          .width('100%')
          .padding(Theme.space.cardPadding)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(16)

          Row().height(this.bottomInset)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5 })
      }
      .width('100%')
      .height('100%')

      if (this.showSettings) {
        MineSettingsPane({
          onClose: (): void => {
            this.showSettings = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onOpenAgreement: (): void => { this.showAgreementDoc = true },
          onOpenPrivacy: (): void => { this.showPrivacyDoc = true },
          onClearCache: (): void => this.showToast('界面缓存已清理（记录未删除）'),
          onRevoke: (): void => { void this.handleRevokePrivacy() }
        })
      }

      if (this.showTags) {
        Column() {
          Row() {
            Text('标签使用次数')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('关闭')
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { this.showTags = false })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s3 })
          if (this.tags.length === 0) {
            AppEmpty({ title: '还没有标签', description: '给小事打上标签后会出现次数' })
          } else {
            ForEach(this.tags, (s: TagStat) => {
              Row() {
                Text(s.label)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                Blank()
                Text(`${s.count} 次`)
                  .fontSize(Theme.type.body)
                  .fontColor(s.color)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(12)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            }, (s: TagStat) => s.label)
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
          .zIndex(20)
      }
      if (this.showPrivacyDoc) {
        LegalDocOverlay({ kind: 'privacy', onClose: (): void => { this.showPrivacyDoc = false } })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({ kind: 'agreement', onClose: (): void => { this.showAgreementDoc = false } })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
