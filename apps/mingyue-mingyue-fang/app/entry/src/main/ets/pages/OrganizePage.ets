import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { NoteItem, QuoteItem, TagPresetItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'

class OrganizeResultItem {
  kind: string = ''
  id: string = ''
  title: string = ''
  summary: string = ''
  meta: string = ''
  tags: string[] = []
}

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State filterTag: string = ''
  @State searchQuery: string = ''
  @State results: OrganizeResultItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State searched: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await ReadingBizService.loadTagPresets()
  }

  private noteToResult(item: NoteItem): OrganizeResultItem {
    const r = new OrganizeResultItem()
    r.kind = 'note'
    r.id = item.id
    r.title = item.title
    r.summary = item.summary.length > 0 ? item.summary : item.body
    r.meta = item.recordDate
    r.tags = item.tags
    return r
  }

  private quoteToResult(item: QuoteItem): OrganizeResultItem {
    const r = new OrganizeResultItem()
    r.kind = 'quote'
    r.id = item.id
    r.title = item.title
    r.summary = item.content
    r.meta = item.source
    r.tags = item.tags
    return r
  }

  private async runFilter(): Promise<void> {
    this.searched = true
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      const res = await ReadingBizService.search(q, this.currentUsername)
      this.results = []
      for (const w of res.notes) {
        this.results.push(this.noteToResult(NoteItem.fromWire(w)))
      }
      for (const w of res.quotes) {
        this.results.push(this.quoteToResult(QuoteItem.fromWire(w)))
      }
      return
    }
    let notes = await ReadingBizService.loadNotes(this.currentUsername, this.filterTag, '')
    let quotes = await ReadingBizService.loadQuotes(this.currentUsername, '')
    this.results = []
    for (const n of notes) {
      this.results.push(this.noteToResult(n))
    }
    if (this.filterTag.length === 0) {
      for (const qItem of quotes) {
        this.results.push(this.quoteToResult(qItem))
      }
    } else {
      for (const qItem of quotes) {
        let matched = false
        for (const t of qItem.tags) {
          if (t === this.filterTag) {
            matched = true
          }
        }
        if (matched) {
          this.results.push(this.quoteToResult(qItem))
        }
      }
    }
  }

  private openResult(item: OrganizeResultItem): void {
    if (item.kind === 'note') {
      ReadingDetailNav.openNote(item.id)
    } else if (item.kind === 'quote') {
      ReadingDetailNav.openQuote(item.id)
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
        Text('智慧整理')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 8 }) {
            Text('按标签筛选')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagPresets, (tag: TagPresetItem) => {
                Text(tag.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag === tag.title ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.filterTag === tag.title ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.filterTag = this.filterTag === tag.title ? '' : tag.title
                  })
              }, (tag: TagPresetItem) => tag.id)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('关键词搜索')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.searchQuery, placeholder: '搜索笔记与明悟…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.searchQuery = v })
          }
          .width('100%')

          AppButton({
            label: '开始整理',
            onTap: (): void => { void this.runFilter() }
          })

          if (this.searched) {
            if (this.results.length === 0) {
              AppEmpty({
                title: '暂无匹配结果',
                description: '试试调整标签或关键词'
              })
            } else {
              ForEach(this.results, (item: OrganizeResultItem) => {
                ReadingListCard({
                  title: item.title,
                  summary: item.summary,
                  meta: item.meta,
                  tags: item.tags,
                  showCover: false,
                  compact: true,
                  onTap: (): void => { this.openResult(item) }
                })
              }, (item: OrganizeResultItem) => `${item.kind}_${item.id}`)
            }
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
