import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateQuoteRequest, QuoteItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct QuotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State quotes: QuoteItem[] = []
  @State loading: boolean = true
  @State showAddForm: boolean = false
  @State formTitle: string = ''
  @State formContent: string = ''
  @State formSource: string = ''
  @State formTags: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.quotes = await ReadingBizService.loadQuotes(this.currentUsername, '')
    } else {
      this.quotes = []
    }
    this.loading = false
  }

  private openAddForm(): void {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formContent = ''
    this.formSource = ''
    this.formTags = ''
    this.formError = ''
    this.showAddForm = true
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async submitQuote(): Promise<void> {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    if (this.formContent.trim().length === 0) {
      this.formError = '请填写明悟内容'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateQuoteRequest()
    req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '明悟摘录'
    req.content = this.formContent.trim()
    req.source = this.formSource.trim()
    req.tags = this.parseTags(this.formTags)
    req.userId = this.currentUsername
    const created = await ReadingBizService.createQuote(req)
    this.submitting = false
    if (created !== undefined) {
      this.showAddForm = false
      await this.reload()
    } else {
      this.formError = '添加失败，请稍后重试'
    }
  }

  private async removeQuote(id: string): Promise<void> {
    const ok = await ReadingBizService.deleteQuote(id)
    if (ok) {
      await this.reload()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Text('明悟收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.openAddForm() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载明悟…' }).layoutWeight(1)
      } else if (this.quotes.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有收藏',
            description: AuthService.isLoggedIn()
              ? '收藏阅读中的精彩片段与感悟'
              : '登录后可添加明悟收藏',
            actionLabel: '添加收藏',
            onAction: (): void => { this.openAddForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.quotes, (item: QuoteItem) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { void this.removeQuote(item.id) })
                }
                .width('100%')
                if (item.source.length > 0) {
                  Text(item.source)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandDeep)
                    .width('100%')
                }
                Text(item.content)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                  .fontStyle(FontStyle.Italic)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
              .onClick((): void => { ReadingDetailNav.openQuote(item.id) })
            }, (item: QuoteItem) => item.id)
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
      }

      if (this.showAddForm) {
        this.AddFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  AddFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.showAddForm = false })
        Text('添加明悟')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.formTitle, placeholder: '标题（可选）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formTitle = v })
        TextInput({ text: this.formSource, placeholder: '来源（书名/作者）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formSource = v })
        TextArea({ text: this.formContent, placeholder: '写下想收藏的明悟…' })
          .width('100%')
          .height(140)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formContent = v })
        TextInput({ text: this.formTags, placeholder: '标签（逗号分隔）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formTags = v })
        AppButton({
          label: this.submitting ? '保存中…' : '保存明悟',
          disabled: this.submitting,
          onTap: (): void => { void this.submitQuote() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(30)
  }
}
