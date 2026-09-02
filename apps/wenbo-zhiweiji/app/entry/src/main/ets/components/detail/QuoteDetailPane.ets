import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { DetailShell } from './DetailShell'
import { QuoteCard } from '../../models/ZhiweiModels'
import { QuoteCatalog } from '../../services/QuoteCatalog'
import { ZhiweiMedia } from '../../services/ZhiweiMedia'
import { ZhiweiNav } from '../../services/ZhiweiNav'
import { ZhiweiStore } from '../../services/ZhiweiStore'

@Component
export struct QuoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State item: QuoteCard = new QuoteCard()
  @State found: boolean = false
  @State favored: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.load()
  }

  onToken(): void {
    this.load()
  }

  private load(): void {
    const row = QuoteCatalog.findById(this.itemId)
    if (row === null) {
      this.found = false
      return
    }
    this.item = row
    this.found = true
    this.favored = ZhiweiStore.isFavorite(row.id)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    const ok = await ZhiweiStore.toggleFavorite(this.item.id)
    if (ok) {
      this.favored = ZhiweiStore.isFavorite(this.item.id)
      this.showToast(this.favored ? '已收藏' : '已取消收藏')
      return
    }
    this.showToast('操作失败，请重试')
  }

  private async collectQuote(): Promise<void> {
    const ok = await ZhiweiStore.captureFromQuote(this.item.theme, this.item.text, this.item.author)
    this.showToast(ok ? '已收进知微集，可在收录里跟进' : '收进失败，请重试')
  }

  private async shareQuote(): Promise<void> {
    const text = `「${this.item.text}」——${this.item.author}`
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('已复制金句，可粘贴到系统分享或聊天')
    } catch {
      this.showToast('复制失败，请长按文字自行复制')
    }
  }

  build() {
    Stack() {
      DetailShell({
        title: '金句',
        onClose: () => ZhiweiNav.closeQuote()
      }) {
        if (!this.found) {
          Column() {
            Text('这条金句暂时找不到')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .padding(Theme.space.s6)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack() {
                Image(ZhiweiMedia.coverOf(this.item.coverKey))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                Column()
                  .width('100%')
                  .height(200)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(26,26,46,0.16)', 0], ['rgba(26,26,46,0.82)', 1]]
                  })
                Text(this.item.theme)
                  .fontSize(Theme.type.caption)
                  .fontColor('#F5F7FA')
                  .padding({ left: 16, right: 16, bottom: 16 })
                  .width('100%')
              }
              .width('100%')
              .height(200)
              .borderRadius(Theme.radius.md)
              .clip(true)

              Column({ space: 10 }) {
                Text(this.item.text)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(this.item.author)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              AppButton({
                label: '收进知微集',
                variant: 'primary',
                onTap: (): void => { void this.collectQuote() }
              })
              AppButton({
                label: this.favored ? '取消收藏' : '收藏这句',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFav() }
              })
              AppButton({
                label: '分享金句',
                variant: 'secondary',
                onTap: (): void => { void this.shareQuote() }
              })
              Blank().height(Theme.space.s10)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: 48 })
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
