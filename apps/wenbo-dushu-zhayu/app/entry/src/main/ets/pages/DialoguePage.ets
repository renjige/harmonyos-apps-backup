import { Theme } from '../components/design-system/Theme'
import { PhotoHeroStack } from '../components/design-system/PhotoHeroStack'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateInspirationRequest, QuoteItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { AuthService } from '../services/AuthService'

/** 对读札：选两句金句对照，写它们为何对话 — 不是普通摘抄列表 */
@Component
export struct DialoguePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State quotes: QuoteItem[] = []
  @State quoteAId: string = ''
  @State quoteBId: string = ''
  @State quoteAText: string = ''
  @State quoteBText: string = ''
  @State formBody: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      this.quotes = await ReadingBizService.loadQuotes(this.currentUsername, '')
    } else {
      this.quotes = []
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private pickQuote(item: QuoteItem): void {
    if (this.quoteAId === item.id) {
      this.quoteAId = ''
      this.quoteAText = ''
      return
    }
    if (this.quoteBId === item.id) {
      this.quoteBId = ''
      this.quoteBText = ''
      return
    }
    if (this.quoteAId.length === 0) {
      this.quoteAId = item.id
      this.quoteAText = item.content
      return
    }
    if (this.quoteBId.length === 0) {
      this.quoteBId = item.id
      this.quoteBText = item.content
    }
  }

  private selected(id: string): boolean {
    return this.quoteAId === id || this.quoteBId === id
  }

  private async submitDialogue(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.quoteAId.length === 0 || this.quoteBId.length === 0) {
      this.errorText = '请先选出两句要对照的札语'
      return
    }
    if (this.formBody.trim().length === 0) {
      this.errorText = '请写下这两句为什么能互相发明'
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    this.errorText = ''
    const req = new CreateInspirationRequest()
    req.title = '对读札'
    req.content = `【句一】${this.quoteAText}\n\n【句二】${this.quoteBText}\n\n【对照】${this.formBody.trim()}`
    req.bookId = ''
    const tags: string[] = []
    tags.push('对读札')
    req.tags = tags
    const created = await ReadingBizService.createInspiration(req)
    this.submitting = false
    if (created === undefined) {
      this.errorText = '保存失败，请稍后重试'
      return
    }
    this.onChanged()
    this.showToast('对读札已收进灵感收藏')
    setTimeout((): void => { this.onClose() }, 900)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Text('对读札')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            PhotoHeroStack({
              coverKey: 'dialogue_pair',
              heroHeight: 148,
              title: '让两句话彼此发明',
              subtitle: '选两句已有札语，写下它们为何对话。这不是再摘一句，而是对照思考。'
            })

            if (this.quotes.length < 2) {
              AppEmpty({
                title: '还需要两句札语',
                description: '先去金句摘录收藏至少两句，再回来写对读札',
                actionLabel: '返回',
                onAction: (): void => { this.onClose() }
              })
            } else {
              this.DialogueForm()
            }
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
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

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
  DialogueForm() {
    Column({ space: Theme.space.s3 }) {
      Text(`句一 ${this.quoteAId.length > 0 ? '已选' : '未选'} · 句二 ${this.quoteBId.length > 0 ? '已选' : '未选'}`)
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      ForEach(this.quotes, (item: QuoteItem) => {
        Column({ space: 4 }) {
          Text(item.content)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .fontStyle(FontStyle.Italic)
            .width('100%')
          if (item.source.length > 0) {
            Text(item.source)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.selected(item.id) ?
          Theme.colors().surfaceSubtle : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .border({
          width: this.selected(item.id) ? 2 : 1,
          color: this.selected(item.id) ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
        })
        .onClick((): void => { this.pickQuote(item) })
      }, (item: QuoteItem) => item.id)

      TextArea({ text: this.formBody, placeholder: '这两句为什么能互相发明？写下对照思考…' })
        .width('100%')
        .height(120)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .caretColor(Theme.colors().brandPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => { this.formBody = v })
      if (this.errorText.length > 0) {
        Text(this.errorText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
      }
      AppButton({
        label: this.submitting ? '保存中…' : '保存对读札',
        disabled: this.submitting,
        onTap: (): void => { void this.submitDialogue() }
      })
    }
    .width('100%')
  }
}
