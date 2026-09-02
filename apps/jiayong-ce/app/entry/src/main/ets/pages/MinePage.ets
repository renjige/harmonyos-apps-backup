import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppListRow } from '../components/design-system/AppListRow'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { AppSettings } from '../models/AlbumModels'
import { PrivacyService } from '../services/PrivacyService'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

class ModeChip {
  id: string = ''
  label: string = ''

  static all(): ModeChip[] {
    const items: ModeChip[] = []
    const a = new ModeChip()
    a.id = 'system'
    a.label = '跟随系统'
    items.push(a)
    const b = new ModeChip()
    b.id = 'light'
    b.label = '浅色'
    items.push(b)
    const c = new ModeChip()
    c.id = 'dark'
    c.label = '深色'
    items.push(c)
    return items
  }
}

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('albumRev') @Watch('onAlbumRev') storeRev: number = 0
  @Prop appName: string = '家用册'
  onToast: (text: string) => void = (text: string) => {}
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State showSettings: boolean = false
  @State showLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State displayName: string = ''
  @State familyName: string = ''
  @State colorMode: string = 'system'
  @State photoCount: number = 0
  @State favoriteCount: number = 0
  @State usedText: string = ''
  @State quotaText: string = ''
  @State usagePercent: number = 0
  private modeChips: ModeChip[] = ModeChip.all()

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  onAlbumRev(): void {
    this.reload()
  }

  private reload(): void {
    const s = AlbumStore.settings()
    this.displayName = s.displayName
    this.colorMode = s.colorMode
    this.familyName = AlbumStore.profile().name
    const stats = AlbumStore.storageStats()
    this.photoCount = stats.photoCount
    this.favoriteCount = stats.favoriteCount
    this.usedText = AlbumStore.formatBytes(stats.usedBytes)
    this.quotaText = AlbumStore.formatBytes(stats.quotaBytes)
    this.usagePercent = stats.quotaBytes > 0 ? Math.min(100, Math.round(stats.usedBytes / stats.quotaBytes * 100)) : 0
  }

  private nameText(): string {
    if (this.displayName.trim().length > 0) {
      return this.displayName.trim()
    }
    return '家庭管理员'
  }

  private openSettings(): void {
    this.showSettings = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeSettings(): void {
    this.showSettings = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private async persistSettings(): Promise<boolean> {
    const s = new AppSettings()
    s.displayName = this.displayName.trim()
    s.colorMode = this.colorMode
    s.darkFollowSystem = this.colorMode === 'system'
    s.autoBackup = AlbumStore.settings().autoBackup
    s.notifyFamily = AlbumStore.settings().notifyFamily
    const ok = await AlbumStore.saveSettings(s)
    const host = this.getUIContext().getHostContext()
    if (host !== undefined) {
      ThemeAppearance.apply(this.colorMode, host as common.UIAbilityContext)
    } else {
      ThemeAppearance.apply(this.colorMode)
    }
    return ok
  }

  private async saveFamilyName(): Promise<void> {
    const ok = await AlbumStore.updateProfile(this.familyName)
    if (!ok) {
      this.onToast('家庭名称保存失败')
      return
    }
    this.reload()
    this.onToast('家庭名称已更新')
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.closeSettings()
    this.onToast('已清除应用内隐私记录。系统隐私声明以华为应用市场托管为准，应用可继续使用')
  }

  @Builder
  SettingsPanel() {
    Column() {
      Row() {
        Text('设置与隐私')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .width(48)
          .height(48)
          .textAlign(TextAlign.Center)
          .onClick((): void => { this.closeSettings() })
      }
      .width('100%')
      .padding({ bottom: Theme.space.s4 })

      Scroll() {
        Column() {
          Text('外观模式')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.modeChips, (chip: ModeChip) => {
              Text(chip.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.colorMode === chip.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .height(48)
                .padding({ left: 14, right: 14 })
                .textAlign(TextAlign.Center)
                .backgroundColor(this.colorMode === chip.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.colorMode = chip.id
                  void this.persistSettings()
                })
            }, (chip: ModeChip) => chip.id)
          }
          .width('100%')
          .margin({ top: Theme.space.s2, bottom: Theme.space.s5 })

          Text('点击后立即切换浅色/深色，无需离开本页')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .margin({ bottom: Theme.space.s5 })

          Text('显示名称')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.displayName, placeholder: '家庭管理员昵称' })
            .onChange((v: string) => { this.displayName = v })
            .margin({ top: Theme.space.s2, bottom: Theme.space.s3 })
          AppButton({ label: '保存昵称', variant: 'secondary', onTap: (): void => { void this.persistSettings() } })
            .margin({ bottom: Theme.space.s5 })

          Text('家庭名称')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.familyName, placeholder: '首页顶部显示的家庭名' })
            .onChange((v: string) => { this.familyName = v })
            .margin({ top: Theme.space.s2, bottom: Theme.space.s3 })
          AppButton({ label: '保存家庭名称', variant: 'secondary', onTap: (): void => { void this.saveFamilyName() } })
            .margin({ bottom: Theme.space.s6 })

          AppButton({ label: '查看《用户协议》', variant: 'secondary', onTap: (): void => {
            this.legalKind = 'agreement'
            this.showLegal = true
          } })
          AppButton({ label: '查看《隐私政策》', variant: 'secondary', onTap: (): void => {
            this.legalKind = 'privacy'
            this.showLegal = true
          } })
            .margin({ top: Theme.space.s3 })

          Row() {
            AppButton({ label: '撤回隐私同意', variant: 'secondary', onTap: (): void => { void this.handleRevokePrivacy() } })
          }
          .width('100%')
          .margin({ top: Theme.space.s4 })
          .onClick((): void => { void this.handleRevokePrivacy() })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(Theme.space.pageX)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          Row() {
            Column() {
              Text(this.nameText().substring(0, 1))
                .fontSize(Theme.type.title2)
                .fontColor('#FFFFFF')
            }
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor(Theme.colors().brandPrimary)
            .justifyContent(FlexAlign.Center)
            Column() {
              Text(this.nameText())
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Text(`${this.familyName} · ${this.photoCount} 张 · ${this.favoriteCount} 珍藏`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: Theme.space.s4 })
            .layoutWeight(1)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .margin({ top: Theme.space.s4 })

          Column() {
            Row() {
              Text('存储空间')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`${this.usedText} / ${this.quotaText}`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .width('100%')
            Progress({ value: this.usagePercent, total: 100, type: ProgressType.Linear })
              .color(Theme.colors().brandPrimary)
              .margin({ top: Theme.space.s3 })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
          .margin({ top: Theme.space.s4 })

          AppListRow({
            title: '家庭年册',
            subtitle: '按月份回顾、珍藏与地点统计',
            onTap: (): void => { AlbumNav.openRecap() }
          })
            .margin({ top: Theme.space.s4 })
          AppListRow({
            title: '搜索照片',
            subtitle: '按描述、地点、上传人查找',
            onTap: (): void => { AlbumNav.openSearch() }
          })
            .margin({ top: Theme.space.s2 })
          AppListRow({
            title: '我的珍藏',
            subtitle: '详情页可把照片加入珍藏册',
            onTap: (): void => { AlbumNav.openFilter('favorite', '') }
          })
            .margin({ top: Theme.space.s2 })
          AppListRow({
            title: '设置与隐私',
            subtitle: '协议 · 外观 · 家庭名称',
            onTap: (): void => { this.openSettings() }
          })
            .margin({ top: Theme.space.s2 })

          Text(`${this.appName} v1.0.0 · 照片默认保存在本机`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textTertiary : Theme.colors().textTertiary)
            .margin({ top: Theme.space.s8 })
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')

      if (this.showSettings) {
        Column() {
          this.SettingsPanel()
        }
        .width('100%')
        .height('100%')
        .zIndex(20)
      }

      if (this.showLegal) {
        Column() {
          LegalDocOverlay({
            kind: this.legalKind,
            onClose: (): void => { this.showLegal = false }
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
