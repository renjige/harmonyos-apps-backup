import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { DetailMissingPane } from './DetailMissingPane'
import { PatchQuoteRequest, QuoteItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingMedia } from '../../services/ReadingMedia'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'

@Component
export struct QuoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onDeleted: () => void = () => {}
  onChanged: () => void = () => {}
  @State item: QuoteItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State formComment: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await ReadingBizService.findQuote(this.itemId)
    if (this.item !== undefined) {
      this.formComment = this.item.comment
    }
    this.loading = false
  }

  private async saveComment(): Promise<void> {
    if (this.item === undefined || this.saving) {
      return
    }
    this.saving = true
    const req = new PatchQuoteRequest()
    req.comment = this.formComment.trim().length > 0 ? this.formComment.trim() : ' '
    const updated = await ReadingBizService.patchQuote(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.item = updated
      this.formComment = updated.comment
      this.onChanged()
      this.showToast('点评已保存')
      return
    }
    this.showToast('保存失败，请稍后重试')
  }

  private async handleDelete(): Promise<void> {
    if (this.item === undefined) {
      ReadingDetailNav.close()
      return
    }
    const ok = await ReadingBizService.deleteQuote(this.item.id)
    if (ok) {
      this.onDeleted()
      ReadingDetailNav.close()
      return
    }
    this.showToast('删除失败，请稍后重试')
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载札语…' })
      } else if (this.item === undefined) {
        DetailMissingPane({
          title: '札语摘录',
          emptyTitle: '札语不存在',
          emptyDescription: '可能已被删除，请返回继续浏览'
        })
      } else {
        DetailShell({
          title: '札语摘录',
          onClose: (): void => { ReadingDetailNav.close() },
          body: (): void => { this.DetailBody() }
        })
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
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      this.QuoteBody(this.item)
    }
  }

  @Builder
  QuoteBody(quote: QuoteItem) {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(ReadingMedia.coverMedia('hero_reading_desk'))
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column()
          .width('100%')
          .height(160)
          .linearGradient({
            angle: 180,
            colors: Theme.heroScrimStops()
          })
          .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
        Column({ space: 4 }) {
          if (quote.source.length > 0) {
            Text(quote.source)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.heroSubtitleColor())
          }
          Text(quote.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.heroTitleColor())
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      if (quote.tags.length > 0) {
        Row({ space: 8 }) {
          ForEach(quote.tags, (tag: string) => {
            Text(tag)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.tagForeground())
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor(Theme.tagBackground())
              .border({
                width: Theme.isDark() ? 1 : 0,
                color: Theme.colors().strokeStrong
              })
              .borderRadius(Theme.radius.pill)
          }, (tag: string) => tag)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column() {
        AppCard({ title: '金句', variant: 'plain' }) {
          Text(quote.content)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(26)
            .fontStyle(FontStyle.Italic)
        }
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Column({ space: Theme.space.s3 }) {
        AppCard({ title: '个人点评', variant: 'plain' }) {
          TextArea({ text: this.formComment, placeholder: '写下这句话为什么打动你…' })
            .width('100%')
            .height(100)
            .fontColor(Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textSecondary)
            .caretColor(Theme.colors().brandPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formComment = v })
        }
        AppButton({
          label: this.saving ? '保存中…' : '保存点评',
          disabled: this.saving,
          onTap: (): void => { void this.saveComment() }
        })
        AppButton({
          label: '删除札语',
          variant: 'danger',
          onTap: (): void => { void this.handleDelete() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    }
  }
}
