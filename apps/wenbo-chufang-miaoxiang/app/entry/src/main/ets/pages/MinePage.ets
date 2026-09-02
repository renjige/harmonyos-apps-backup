import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { RecipeCard } from '../components/kitchen/RecipeCard'
import { KitchenStats, Recipe } from '../models/KitchenModels'
import { KitchenStore } from '../services/KitchenStore'
import { PrivacyService } from '../services/PrivacyService'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '厨房妙想'
  @State showSettings: boolean = false
  @State showHistory: boolean = false
  @State showAbout: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State showLegal: boolean = false
  @State toastText: string = ''
  @State preference: string = '清爽家常'
  onOpenFavorites: () => void = () => {}
  onOpenRecipe: (id: string) => void = (_id: string) => {}

  private stats(): KitchenStats {
    return KitchenStore.stats()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await PrivacyService.revoke()
    this.showSettings = false
    this.showToast('已撤回隐私同意')
  }

  build() {
    Stack() {
      Column() {
        if (this.showSettings) {
          this.SettingsPanel()
        } else if (this.showHistory) {
          this.HistoryPanel()
        } else if (this.showAbout) {
          this.AboutPanel()
        } else {
          this.MainPanel()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
          .zIndex(20)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
          .width('100%')
          .height('100%')
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MainPanel() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('我的厨房')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('不登录也能记录今天的厨房灵感。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Row({ space: Theme.space.s3 }) {
          this.StatCard(`${this.stats().favoriteCount}`, '收藏菜谱')
          this.StatCard(`${this.stats().completedCount}`, '完成菜品')
          this.StatCard(`${this.stats().listCount}`, '清单数量')
        }
        .width('100%')

        Column({ space: 0 }) {
          this.MenuRow('我的收藏', '快速查看喜欢的菜谱', (): void => this.onOpenFavorites())
          this.MenuRow('浏览记录', '找回刚刚看过的做法', (): void => { this.showHistory = true })
          this.MenuRow('使用偏好', this.preference, (): void => { this.showSettings = true })
          this.MenuRow('隐私政策', '查看本地数据与权限说明', (): void => {
            this.legalKind = 'privacy'
            this.showLegal = true
          })
          this.MenuRow('用户协议', '了解使用规则', (): void => {
            this.legalKind = 'agreement'
            this.showLegal = true
          })
          this.MenuRow('关于厨房妙想', '版本与产品说明', (): void => { this.showAbout = true })
        }
        .width('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.card)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  SettingsPanel() {
    Column({ space: Theme.space.s4 }) {
      this.PanelHeader('使用偏好', (): void => { this.showSettings = false })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          this.PreferenceRow('清爽家常')
          this.PreferenceRow('10 分钟快手')
          this.PreferenceRow('汤羹优先')
          this.PreferenceRow('轻食优先')
          this.MenuRow('查看《用户协议》', '完整服务规则', (): void => {
            this.legalKind = 'agreement'
            this.showLegal = true
          })
          this.MenuRow('查看《隐私政策》', '本地数据与用户权利', (): void => {
            this.legalKind = 'privacy'
            this.showLegal = true
          })
          this.MenuRow('撤回隐私同意', '撤回后再次使用账号能力须重新同意', (): void => {
            void this.handleRevokePrivacy()
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  HistoryPanel() {
    Column({ space: Theme.space.s4 }) {
      this.PanelHeader('浏览记录', (): void => { this.showHistory = false })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (KitchenStore.historyRecipes().length === 0) {
            Text('还没有浏览记录')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(Theme.space.s7)
          } else {
            ForEach(KitchenStore.historyRecipes(), (item: Recipe) => {
              RecipeCard({
                recipe: item,
                compact: true,
                onTap: (): void => this.onOpenRecipe(item.id)
              })
            }, (item: Recipe) => item.id)
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AboutPanel() {
    Column({ space: Theme.space.s4 }) {
      this.PanelHeader('关于厨房妙想', (): void => { this.showAbout = false })
      Column({ space: Theme.space.s4 }) {
        Image($r('app.media.app_icon'))
          .width(88)
          .height(88)
          .borderRadius(24)
        Text('厨房妙想')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text('发现简单好吃的厨房灵感，让每天做饭变得更轻松。')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(24)
          .textAlign(TextAlign.Center)
        Text('版本 1.0.0')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
      }
      .width('100%')
      .padding(Theme.space.s7)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.card)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PanelHeader(title: string, onBack: () => void) {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .rotate({ angle: 180 })
      .onClick(() => onBack())
      Text(title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s4 })
  }

  @Builder
  StatCard(value: string, label: string) {
    Column({ space: Theme.space.s1 }) {
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  @Builder
  MenuRow(title: string, subtitle: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 2 }) {
        Text(title)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .border({ width: { bottom: 1 }, color: Theme.colors().strokeHairline })
    .onClick(() => onTap())
  }

  @Builder
  PreferenceRow(text: string) {
    Row() {
      Text(text)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .layoutWeight(1)
      if (this.preference === text) {
        AppIcon({ name: 'check', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.preference === text ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(() => {
      this.preference = text
      this.showToast(`已切换为${text}`)
    })
  }
}
