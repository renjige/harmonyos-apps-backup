import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AchievementItem, UserProfile } from '../models/TrainingModels'
import { AchievementEngine } from '../services/AchievementEngine'
import { TrainingAnalytics } from '../services/TrainingAnalytics'
import { ProfileStore } from '../services/ProfileStore'
import { DateHelper } from '../services/DateHelper'
import { PrivacyService } from '../services/PrivacyService'
import { AppContextService } from '../services/AppContextService'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { ExportService } from '../services/ExportService'
import { PracticeHubStore } from '../services/PracticeHubStore'
import { FunQuestStore } from '../services/FunQuestStore'
import { VitalityStore } from '../services/VitalityStore'
import { VitalityService } from '../services/VitalityService'
import { PracticeNav } from '../services/PracticeNav'
import { PracticeService } from '../services/PracticeService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('dataEpoch') @Watch('onDataEpoch') dataEpoch: number = 0
  @Prop refreshToken: number = 0
  @State profile: UserProfile = new UserProfile()
  @State nicknameInput: string = ''
  @State badges: AchievementItem[] = []
  @State totalCount: number = 0
  @State totalHours: number = 0
  @State streakDays: number = 0
  @State usageDays: number = 1
  @State moveCount: number = 0
  @State checkDone: number = 0
  @State noteCount: number = 0
  @State goalCount: number = 0
  @State questCount: number = 0
  @State points: number = 0
  @State skinId: string = 'dawn'
  @State showSettings: boolean = false
  @State showPrivacyDoc: boolean = false
  @State showAgreementDoc: boolean = false
  @State themeMode: string = 'system'
  @State toast: string = ''
  onDataChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onDataEpoch(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.profile = ProfileStore.get()
    this.nicknameInput = this.profile.nickname
    this.usageDays = DateHelper.usageDays(this.profile.firstUseAt, Date.now())
    const summary = TrainingAnalytics.summarize()
    this.totalCount = summary.totalCount
    this.totalHours = TrainingAnalytics.totalHours()
    this.streakDays = summary.streakDays
    this.badges = AchievementEngine.evaluate()
    this.themeMode = this.profile.themeMode.length > 0 ? this.profile.themeMode : 'system'
    this.moveCount = PracticeHubStore.listMoves().length
    this.noteCount = PracticeHubStore.listCards().length
    this.goalCount = PracticeHubStore.listGoals().length
    this.checkDone = MinePage.countCheckDone()
    this.questCount = FunQuestStore.list().length
    this.points = VitalityStore.get().points
    this.skinId = VitalityStore.get().skinId
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2800)
  }

  private async saveNickname(): Promise<void> {
    this.profile.nickname = this.nicknameInput.trim().length > 0 ? this.nicknameInput.trim() : '训练者'
    await ProfileStore.save(this.profile)
    this.showToast('昵称已保存')
    this.onDataChanged()
  }

  private persistTheme(mode: string): void {
    this.themeMode = mode
    this.profile.themeMode = mode
    const ctx = AppContextService.getContext()
    if (ctx !== null) {
      ThemeAppearance.apply(mode, ctx)
    } else {
      ThemeAppearance.apply(mode)
    }
    void ProfileStore.save(this.profile).then((): void => {
      ThemeAppearance.bumpEpoch()
    })
    this.showToast(mode === 'system' ? '已跟随系统外观' : (mode === 'dark' ? '已切换深色' : '已切换浅色'))
  }

  private static countCheckDone(): number {
    const c = PracticeHubStore.getChecks()
    let n = 0
    const before = PracticeService.unpackLines(c.beforePacked)
    const after = PracticeService.unpackLines(c.afterPacked)
    for (const line of before) {
      if (line.done) {
        n += 1
      }
    }
    for (const line of after) {
      if (line.done) {
        n += 1
      }
    }
    return n
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
    this.showToast('已撤回本机协议记录。隐私声明由华为应用市场托管，首次打开不再弹出应用内声明。')
  }

  private async handleClearCache(): Promise<void> {
    this.showToast('已清除界面缓存，训练数据仍保留在本机')
  }

  private async handleExport(): Promise<void> {
    const ok = await ExportService.copyToClipboard()
    this.showToast(ok ? '已复制成长轨迹到剪贴板' : '复制失败，请稍后重试')
  }

  private async pickSkin(id: string): Promise<void> {
    const ok = await VitalityService.setSkin(id)
    if (ok) {
      this.skinId = id
      ThemeAppearance.bumpEpoch()
      this.showToast('主题皮肤已切换')
    } else {
      this.showToast('积分还不够，完成跟练或挑战可解锁')
    }
    await this.reload()
    this.onDataChanged()
  }

  private openLegal(kind: string): void {
    if (kind === 'agreement') {
      this.showAgreementDoc = true
      this.showPrivacyDoc = false
    } else {
      this.showPrivacyDoc = true
      this.showAgreementDoc = false
    }
  }

  @Builder
  SkinChip(label: string, id: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.skinId === id ? '#FFFFFF' : Theme.colors().textSecondary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.skinId === id ? Theme.primaryButtonFill() : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { void this.pickSkin(id) })
  }

  @Builder
  ThemeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.themeMode === mode ? '#FFFFFF' :
        (this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary))
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.themeMode === mode ? Theme.primaryButtonFill() :
        (this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle))
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.persistTheme(mode) })
  }

  @Builder
  BadgeTile(item: AchievementItem) {
    Column({ space: 6 }) {
      Text(item.emoji)
        .fontSize(28)
        .opacity(item.unlocked ? 1 : 0.35)
      Text(item.title)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(item.unlocked ? Theme.colors().textPrimary : Theme.colors().textTertiary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: item.unlocked ? 'rgba(0,122,255,0.25)' : Theme.colors().strokeHairline })
  }

  @Builder
  ArchiveCell(label: string, value: string, hub: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => {
      if (hub === 'weekbook') {
        PracticeNav.openWeekPlaybook()
      } else if (hub.length > 0) {
        PracticeNav.openHub(hub)
      } else {
        AppStorage.setOrCreate('mainTabIndex', 2)
      }
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s4 }) {
              Column() {
                AppIcon({ name: 'user', iconSize: Theme.icon.xl, color: Theme.colors().brandPrimary })
              }
              .width(64)
              .height(64)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)

              Column({ space: 4 }) {
                TextInput({ text: this.nicknameInput, placeholder: '输入昵称' })
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Theme.colors().textPrimary)
                  .backgroundColor(Color.Transparent)
                  .onChange((v: string): void => { this.nicknameInput = v })
                Text(`已加入 ${this.usageDays} 天`)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')

            AppButton({
              label: '保存昵称',
              variant: 'secondary',
              onTap: (): void => { void this.saveNickname() }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Column({ space: Theme.space.s3 }) {
            Text(`活力积分 ${this.points} · 本地计算，用于解锁主题`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              this.SkinChip('晨光', 'dawn')
              this.SkinChip('林间·40', 'grove')
              this.SkinChip('暮色·100', 'dusk')
            }
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })

          Row({ space: Theme.space.s3 }) {
            Column({ space: 4 }) {
              Text(`${this.totalCount}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().brandPrimary)
              Text('总训练次数')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.totalHours}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.accentOnSurface())
              Text('总时长(小时)')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .alignItems(HorizontalAlign.Center)

            Column({ space: 4 }) {
              Text(`${this.streakDays}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              Text('最长连续天')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')

          Text('运动档案')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.ArchiveCell('挑战', `${this.questCount}`, '')
            this.ArchiveCell('动作', `${this.moveCount}`, 'move')
            this.ArchiveCell('周剧本', '7天', 'weekbook')
          }
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.ArchiveCell('清单', `${this.checkDone}`, 'check')
            this.ArchiveCell('笔记', `${this.noteCount}`, 'card')
            this.ArchiveCell('目标', `${this.goalCount}`, 'goal')
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('成就徽章')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Grid() {
              ForEach(this.badges, (b: AchievementItem) => {
                GridItem() {
                  this.BadgeTile(b)
                }
              }, (b: AchievementItem) => b.id)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .columnsGap(Theme.space.s3)
            .rowsGap(Theme.space.s3)
            .width('100%')
          }
          .width('100%')

          AppListRow({
            title: '导出成长轨迹',
            subtitle: '复制运动数据与挑战到剪贴板',
            onTap: (): void => { void this.handleExport() }
          })

          AppListRow({
            title: '设置与隐私',
            subtitle: '协议 · 外观 · 撤回同意',
            onTap: (): void => {
              this.showSettings = true
              AppStorage.setOrCreate('tabBarHidden', true)
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s10 + 88 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.pageBg(this.themeEpoch))
      .edgeEffect(EdgeEffect.Spring)

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.showPrivacyDoc) {
        LegalDocOverlay({
          kind: 'privacy',
          onClose: (): void => { this.showPrivacyDoc = false }
        })
      }
      if (this.showAgreementDoc) {
        LegalDocOverlay({
          kind: 'agreement',
          onClose: (): void => { this.showAgreementDoc = false }
        })
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(15,23,42,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(40)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => {
          this.showSettings = false
          AppStorage.setOrCreate('tabBarHidden', false)
        })
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Blank().width(44)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('外观模式')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            this.ThemeChip('跟随系统', 'system')
            this.ThemeChip('浅色', 'light')
            this.ThemeChip('深色', 'dark')
          }

          AppListRow({
            title: '全功能导览',
            subtitle: '查看跟练、图鉴、挑战、清单等模块说明',
            onTap: (): void => {
              this.showSettings = false
              AppStorage.setOrCreate('tabBarHidden', false)
              AppStorage.setOrCreate('showFeatureTour', true)
            }
          })

          AppListRow({
            title: '用户协议',
            subtitle: '点击查看全文',
            onTap: (): void => { this.openLegal('agreement') }
          })
          AppListRow({
            title: '隐私政策',
            subtitle: '点击查看全文',
            onTap: (): void => { this.openLegal('privacy') }
          })

          Row() {
            AppButton({
              label: '清除缓存',
              variant: 'secondary',
              onTap: (): void => { void this.handleClearCache() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleClearCache() })

          Row() {
            AppButton({
              label: '撤回隐私同意',
              variant: 'secondary',
              onTap: (): void => { void this.handleRevokePrivacy() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.handleRevokePrivacy() })

          Text('训练数据保存在本机。隐私声明由华为应用市场托管，应用内不再弹出声明窗。撤回仅清除本机勾选记录，不会删除训练数据。')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .lineHeight(18)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch))
    .zIndex(20)
  }
}
