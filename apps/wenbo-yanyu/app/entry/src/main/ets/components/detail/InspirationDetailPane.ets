import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { InspirationItem } from '../../models/LanguageCraftModels'
import { LanguageCraftBizService } from '../../services/LanguageCraftBizService'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'
import { FavoriteStore } from '../../services/FavoriteStore'
import { HubStore } from '../../services/HubStore'
import { ClipboardService } from '../../services/ClipboardService'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: InspirationItem = new InspirationItem()
  @State missing: boolean = false
  @State favorited: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await LanguageCraftBizService.findInspiration(this.itemId)
    if (found === undefined) {
      this.missing = true
      return
    }
    this.missing = false
    this.item = found
    this.favorited = await FavoriteStore.isFavorited(found.id)
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => {
      this.toastText = ''
    }, 2200)
  }

  private async copyExample(): Promise<void> {
    const text = this.item.example.length > 0 ? this.item.example : this.item.summary
    const ok = await ClipboardService.copyText(text)
    this.showToast(ok ? '已复制范例到剪贴板' : '复制失败')
  }

  private applyToPolish(): void {
    const text = this.item.example.length > 0 ? this.item.example : this.item.body
    if (text.length === 0) {
      this.showToast('这条灵感没有可套用的正文')
      return
    }
    LanguageCraftNav.applyToPolish(text)
  }

  private async toggleFavorite(): Promise<void> {
    const was = this.favorited
    this.favorited = await FavoriteStore.toggle(this.item)
    if (this.favorited && !was) {
      await HubStore.recordFavorite(this.item.title, this.item.id)
    }
    this.showToast(this.favorited ? '已加入收藏' : '已取消收藏')
  }

  build() {
    Stack() {
      if (this.missing) {
        Column() {
          AppEmpty({ title: '这条灵感暂不可用', description: '请检查网络后重试。' })
          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: (): void => { LanguageCraftNav.closeDetail() }
          })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
      } else {
        DetailShell({ title: '表达灵感', onClose: (): void => { LanguageCraftNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s5 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(LanguageCraftMedia.cover(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.78)', 1]]
                  })
                Column({ space: 4 }) {
                  Text(this.item.category)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).brandAccent)
                  Text(this.item.title)
                    .fontSize(Theme.type.title2)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#F5F7FA')
                    .maxLines(2)
                }
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .width('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)

              Column({ space: 8 }) {
                Text('要点')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textTertiary)
                  .width('100%')
                Text(this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)

              Column({ space: 8 }) {
                Text('说明')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).textTertiary)
                  .width('100%')
                Text(this.item.body)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .lineHeight(26)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.lg)

              if (this.item.example.length > 0) {
                Column({ space: 8 }) {
                  Text('范例')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textTertiary)
                    .width('100%')
                  Text(this.item.example)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .lineHeight(26)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
              }

              AppButton({
                label: '套用到润色台',
                onTap: (): void => { this.applyToPolish() }
              })
              AppButton({
                label: '复制范例',
                variant: 'secondary',
                onTap: (): void => { void this.copyExample() }
              })
              AppButton({
                label: this.favorited ? '取消收藏' : '收藏这条灵感',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFavorite() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
