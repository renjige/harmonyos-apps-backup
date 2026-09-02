import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { LegalDocKind, LegalDocOverlay } from '../components/legal/LegalDocOverlay'
import { GalleryStore } from '../services/GalleryStore'

@Component
export struct MinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0
  @State showSettings: boolean = false
  @State showLegal: boolean = false
  @State legalKind: LegalDocKind = 'privacy'
  @State toastText: string = ''
  @State artworkCount: number = 0
  @State totalStars: number = 0
  @State soundOn: boolean = true

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    const snap = GalleryStore.snapshot()
    this.artworkCount = snap.artworks.length
    this.totalStars = snap.totalStars
    this.soundOn = snap.settings.soundOn
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2800)
  }

  private async handleRevokePrivacy(): Promise<void> {
    await GalleryStore.revokePrivacy()
    this.showSettings = false
    this.showToast('已撤回隐私同意，保存作品时须重新同意')
  }

  @Builder
  menuRow(label: string, sub: string, onTap: () => void) {
    Row() {
      Column({ space: Theme.space.s1 }) {
        Text(label)
          .fontSize(Theme.type.bodyL)
          .fontColor(Theme.colors().textPrimary)
        Text(sub)
          .fontSize(Theme.type.bodyM)
          .fontColor(Theme.colors().textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      AppIcon({ name: 'chevron', iconSize: 20, color: Theme.colors().textSecondary })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick(onTap)
  }

  build() {
    Stack() {
      Column() {
        Text('我的')
          .fontSize(Theme.type.titleL)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: Theme.space.s2 }) {
              Text('儿童绘坊')
                .fontSize(Theme.type.titleM)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              Text(`画廊 ${this.artworkCount} 幅 · 累计星星 ${this.totalStars}`)
                .fontSize(Theme.type.bodyM)
                .fontColor(Theme.colors().textSecondary)
            }
            .width('100%')
            .padding(Theme.space.s5)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)

            this.menuRow('设置与隐私', '协议 · 撤回 · 清除缓存', () => { this.showSettings = true })
            this.menuRow('关于儿童绘坊', '完全免费 · 无广告 · 本机保存', () => {
              this.showToast('孩子的第一间数字画室')
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showSettings) {
        Column() {
          Row() {
            Button('返回').height(40).onClick(() => { this.showSettings = false })
            Text('设置与隐私')
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }
          .padding(Theme.space.s4)

          Column({ space: Theme.space.s3 }) {
            this.menuRow('用户协议', '查看全文', () => { this.legalKind = 'agreement'; this.showLegal = true })
            this.menuRow('隐私政策', '查看全文', () => { this.legalKind = 'privacy'; this.showLegal = true })
            Row() {
              Text('音效反馈')
                .fontSize(Theme.type.bodyL)
                .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.soundOn })
                .onChange((v: boolean) => { this.soundOn = v })
            }
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)

            Button('清除缓存')
              .height(44)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .onClick((): void => {
                void GalleryStore.clearCacheOnly().then(() => { this.showToast('缓存偏好已重置') })
              })

            Button('撤回隐私同意')
              .height(44)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .onClick((): void => { void this.handleRevokePrivacy() })
          }
          .padding(Theme.space.s4)
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .zIndex(10)
      }

      if (this.showLegal) {
        LegalDocOverlay({
          kind: this.legalKind,
          onClose: () => { this.showLegal = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
    }
  }
}
