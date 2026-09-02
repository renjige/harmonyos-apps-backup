import { common } from '@kit.AbilityKit'
import { Theme } from '../components/design-system/Theme'
import { ThemeAppearance } from '../services/ThemeAppearance'
import { common } from '@kit.AbilityKit'
import { AppButton } from '../components/design-system/AppButton'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { JianEntry } from '../models/JianModels'
import { JianDetailPane } from '../components/jian/JianDetailPane'
import { ExportService } from '../services/ExportService'
import { JianStatsService } from '../services/JianStatsService'
import { JianStore } from '../services/JianStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State totalCount: number = 0
  @State streak: number = 0
  @State favoriteCount: number = 0
  @State favorites: JianEntry[] = []
  @State detailEntry: JianEntry | undefined = undefined
  @State toastText: string = ''
  @State showSettings: boolean = false
  @State showPrivacy: boolean = false
  @State showAgreement: boolean = false
  @State darkMode: boolean = false
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private uiContext: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const ov = await JianStatsService.overview()
    this.totalCount = ov.totalCount
    this.streak = ov.streakDays
    this.favoriteCount = ov.favoriteCount
    this.favorites = await JianStore.loadFavorites()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async exportData(): Promise<void> {
    if (this.uiContext === null) {
      return
    }
    try {
      const path = await ExportService.exportToFile(this.uiContext)
      this.showToast(`已导出：${path}`)
    } catch {
      this.showToast('导出失败，请稍后重试')
    }
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.showToast('已撤回隐私同意，再次进入须重新同意')
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('我的空间')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)

          Row({ space: Theme.space.s3 }) {
            this.StatTile(`${this.totalCount}`, '累计笺数')
            this.StatTile(`${this.streak}`, '连续记录')
            this.StatTile(`${this.favoriteCount}`, '收藏')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('收藏的笺页')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            if (this.favorites.length === 0) {
              Text('收藏重要笺页或笺语后，会显示在这里')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
            } else {
              ForEach(this.favorites.slice(0, 5), (item: JianEntry) => {
                Row() {
                  Text(item.previewLine())
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.detailEntry = item })
              }, (item: JianEntry) => item.id)
            }
          }
          .width('100%')

          this.MenuRow('设置与隐私', (): void => { this.showSettings = true })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        this.SettingsPanel()
      }

      if (this.detailEntry !== undefined) {
        JianDetailPane({
          entry: this.detailEntry,
          onClose: (): void => { this.detailEntry = undefined },
          onChanged: (): void => {
            this.detailEntry = undefined
            void this.load()
          }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      const host = this.getUIContext().getHostContext()
      if (host !== undefined) {
        this.uiContext = host as common.UIAbilityContext
      }
      this.darkMode = Theme.isDark()
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.load()
      }
    })
  }

  @Builder
  StatTile(value: string, label: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  MenuRow(label: string, onTap: () => void) {
    Row() {
      Text(label)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
      Blank()
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .onClick(onTap)
  }

  @Builder
  SettingsPanel() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showSettings = false })

      Column({ space: Theme.space.s2 }) {
        Row() {
          Text('设置与隐私')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
            .onClick((): void => { this.showSettings = false })
        }
        .width('100%')
        .margin({ bottom: Theme.space.s2 })

        this.MenuRow('导出笺页（纯文本）', (): void => { void this.exportData() })
        this.MenuRow('隐私政策', (): void => { this.showPrivacy = true })
        this.MenuRow('用户协议', (): void => { this.showAgreement = true })
        this.MenuRow('关于静时笺', (): void => {
          this.showToast('静时笺 v1.0 — 纸间光阴，静时成笺')
        })

        Row({ space: Theme.space.s3 }) {
          Text('深色模式')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
            .selectedColor(Theme.colors().brandPrimary)
            .onChange((v: boolean) => {
              this.darkMode = v
              ThemeAppearance.apply(v ? 'dark' : 'light', this.getUIContext().getHostContext() as common.UIAbilityContext)
            })
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)

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
      .width('92%')
      .padding(Theme.space.s5)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius(Theme.radius.xl)
      .position({ x: '4%', y: '10%' })

      if (this.showPrivacy) {
        LegalDocOverlay({
          kind: 'privacy',
          onClose: (): void => { this.showPrivacy = false }
        })
      }
      if (this.showAgreement) {
        LegalDocOverlay({
          kind: 'agreement',
          onClose: (): void => { this.showAgreement = false }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
