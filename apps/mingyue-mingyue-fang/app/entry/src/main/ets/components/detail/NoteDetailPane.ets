import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { SymbolHero } from '../design-system/SymbolVisual'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { CreateQuoteRequest, NoteItem } from '../../models/ReadingModels'
import { ReadingBizService } from '../../services/ReadingBizService'
import { ReadingDetailNav } from '../../services/ReadingDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State item: NoteItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''

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
    this.item = await ReadingBizService.findNote(this.itemId)
    this.loading = false
  }

  private async handleAddQuote(): Promise<void> {
    if (!AuthService.requireAuth('add_quote')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    const req = new CreateQuoteRequest()
    req.title = this.item.title
    req.content = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.bookId = this.item.bookId
    req.tags = this.item.tags
    const created = await ReadingBizService.createQuote(req)
    if (created !== undefined) {
      this.showToast('已收藏至明悟')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载笔记…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '笔记不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '读书笔记',
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
      this.NoteBody(this.item)
    }
  }

  @Builder
  NoteBody(note: NoteItem) {
    Column({ space: Theme.space.s4 }) {
        Column() {
          SymbolHero({
            category: note.tags.length > 0 ? note.tags[0] : '',
            coverKey: 'cover_note',
            bannerHeight: 180,
            overline: note.recordDate,
            title: note.title
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (note.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(note.tags, (tag: string) => {
              Text(CategoryEmojiUtil.chipLabel(tag))
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '摘要', variant: 'plain' }) {
            Text(note.summary.length > 0 ? note.summary : '暂无摘要')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(note.body.length > 0 ? note.body : '暂无正文')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column() {
          AppButton({
            label: '收藏至明悟',
            onTap: (): void => { void this.handleAddQuote() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
  }
}
