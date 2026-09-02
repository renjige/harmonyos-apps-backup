import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { BookItem, CreateInspirationRequest } from '../models/ReadingModels'
import { AuthService } from '../services/AuthService'
import { ReadingBizService } from '../services/ReadingBizService'
import { PhotoHeroStack } from '../components/design-system/PhotoHeroStack'

/** 问书三札 — 结构化三问反思，区别于自由笔记/摘抄 */
@Component
export struct BookAskPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  onClose: () => void = () => {}
  @State books: BookItem[] = []
  @State selectedBookId: string = ''
  @State selectedBookTitle: string = ''
  @State answer1: string = ''
  @State answer2: string = ''
  @State answer3: string = ''
  @State submitting: boolean = false
  @State errorText: string = ''
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reloadBooks()
  }

  onRefreshTokenChange(): void {
    void this.reloadBooks()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async reloadBooks(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.books = []
      return
    }
    this.books = await ReadingBizService.loadBooks(this.currentUsername)
  }

  private pickBook(book: BookItem): void {
    this.selectedBookId = book.id
    this.selectedBookTitle = book.title
  }

  private async submitAsk(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    if (this.selectedBookId.length === 0) {
      this.errorText = '请先选择一本在读书籍'
      return
    }
    if (this.answer1.trim().length === 0 || this.answer2.trim().length === 0 ||
      this.answer3.trim().length === 0) {
      this.errorText = '三个追问都须填写，才能形成问书三札'
      return
    }
    if (this.submitting) {
      return
    }
    this.submitting = true
    this.errorText = ''
    const req = new CreateInspirationRequest()
    req.title = `问书三札 · ${this.selectedBookTitle}`
    req.bookId = this.selectedBookId
    req.content =
      `【书名】${this.selectedBookTitle}\n\n` +
      `【追问一·重新思考】${this.answer1.trim()}\n\n` +
      `【追问二·生活连接】${this.answer2.trim()}\n\n` +
      `【追问三·继续追问】${this.answer3.trim()}`
    const tags: string[] = []
    tags.push('问书三札')
    req.tags = tags
    const created = await ReadingBizService.createInspiration(req)
    this.submitting = false
    if (created === undefined) {
      this.errorText = '保存失败，请稍后重试'
      return
    }
    this.onChanged()
    this.showToast('问书三札已收进灵感收藏')
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
          Text('问书三札')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            PhotoHeroStack({
              coverKey: 'hero_dialogue_books',
              heroHeight: 132,
              title: '三个固定追问，不是自由摘抄',
              subtitle: '选书 → 依次回答 → 生成结构化反思札'
            })

            if (this.books.length === 0) {
              AppEmpty({
                title: AuthService.isLoggedIn() ? '书架还没有书' : '登录后选择书籍',
                description: '请先在书架添加一本书，再来写问书三札'
              })
            } else {
              Column({ space: 6 }) {
                Text('选择书籍')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.books, (book: BookItem) => {
                    Text(book.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.selectedBookId === book.id ?
                        Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .margin({ right: 8, bottom: 8 })
                      .backgroundColor(this.selectedBookId === book.id ?
                        Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                      .border({
                        width: this.selectedBookId === book.id ? 0 : 1,
                        color: Theme.colors().strokeStrong
                      })
                      .borderRadius(Theme.radius.pill)
                      .onClick((): void => { this.pickBook(book) })
                  }, (book: BookItem) => book.id)
                }
                .width('100%')
              }
              .width('100%')

              this.QuestionBlock('追问一 · 重新思考', '这本书/本章让你重新思考了什么？', this.answer1,
                (v: string): void => { this.answer1 = v })
              this.QuestionBlock('追问二 · 生活连接', '它与你的生活或工作有什么连接？', this.answer2,
                (v: string): void => { this.answer2 = v })
              this.QuestionBlock('追问三 · 继续追问', '你想带着什么问题继续读下去？', this.answer3,
                (v: string): void => { this.answer3 = v })

              if (this.errorText.length > 0) {
                Text(this.errorText)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.colors().danger)
                  .width('100%')
              }
              AppButton({
                label: this.submitting ? '保存中…' : '保存问书三札',
                disabled: this.submitting,
                onTap: (): void => { void this.submitAsk() }
              })
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
      .backgroundColor(Theme.colors().surfacePage)

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
  QuestionBlock(label: string, placeholder: string, value: string, onChange: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      TextArea({ text: value, placeholder: placeholder })
        .width('100%')
        .height(88)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .placeholderColor(Theme.colors().textSecondary)
        .caretColor(Theme.colors().brandPrimary)
        .backgroundColor(Theme.colors().surfaceInput)
        .borderRadius(Theme.radius.sm)
        .border({ width: 1, color: Theme.colors().strokeStrong })
        .padding({ left: 12, right: 12, top: 10, bottom: 10 })
        .onChange((v: string) => { onChange(v) })
    }
    .width('100%')
  }
}
