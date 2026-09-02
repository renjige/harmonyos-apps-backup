import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppTextField } from '../components/design-system/AppTextField'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import {
  CreateCustomTagRequest,
  InspirationItem,
  NoteItem,
  QuoteItem,
  ReviewItem,
  TagPresetItem
} from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

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
  @State customTags: TagPresetItem[] = []
  @State formTagTitle: string = ''
  @State searched: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await ReadingBizService.loadTagPresets()
    if (AuthService.isLoggedIn()) {
      this.customTags = await ReadingBizService.loadCustomTags()
    } else {
      this.customTags = []
    }
  }

  private async createCustomTag(): Promise<void> {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    const title = this.formTagTitle.trim()
    if (title.length === 0) {
      return
    }
    const req = new CreateCustomTagRequest()
    req.title = title
    const created = await ReadingBizService.createCustomTag(req)
    if (created !== undefined) {
      this.formTagTitle = ''
      await this.loadTags()
    }
  }

  private async removeCustomTag(id: string): Promise<void> {
    const ok = await ReadingBizService.deleteCustomTag(id)
    if (ok) {
      await this.loadTags()
    }
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

  private reviewToResult(item: ReviewItem): OrganizeResultItem {
    const r = new OrganizeResultItem()
    r.kind = 'review'
    r.id = item.id
    r.title = item.title
    r.summary = item.summary.length > 0 ? item.summary : item.body
    r.meta = `${item.rating} 星`
    return r
  }

  private inspirationToResult(item: InspirationItem): OrganizeResultItem {
    const r = new OrganizeResultItem()
    r.kind = 'inspiration'
    r.id = item.id
    r.title = item.title
    r.summary = item.content
    r.meta = '灵感'
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
      if (res.reviews !== undefined) {
        for (const w of res.reviews) {
          this.results.push(this.reviewToResult(ReviewItem.fromWire(w)))
        }
      }
      if (res.inspirations !== undefined) {
        for (const w of res.inspirations) {
          this.results.push(this.inspirationToResult(InspirationItem.fromWire(w)))
        }
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
      const reviews = await ReadingBizService.loadReviews('')
      for (const rv of reviews) {
        this.results.push(this.reviewToResult(rv))
      }
      const insps = await ReadingBizService.loadInspirations('')
      for (const ins of insps) {
        this.results.push(this.inspirationToResult(ins))
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
    } else if (item.kind === 'review') {
      ReadingDetailNav.openReview(item.id)
    } else if (item.kind === 'inspiration') {
      ReadingDetailNav.openInspiration(item.id)
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
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagPresets, (tag: TagPresetItem) => {
                Text(tag.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag === tag.title ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.filterTag === tag.title ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.filterTag = this.filterTag === tag.title ? '' : tag.title
                  })
              }, (tag: TagPresetItem) => tag.id)
              ForEach(this.customTags, (tag: TagPresetItem) => {
                Text(tag.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag === tag.title ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
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

          Column({ space: 8 }) {
            Text('自定义标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppTextField({
              text: this.formTagTitle,
              placeholder: '如：成长、灵感',
              onChange: (v: string): void => { this.formTagTitle = v }
            })
              .width('100%')
            Row() {
              Blank().layoutWeight(1)
              AppButton({
                label: '添加',
                fullWidth: false,
                onTap: (): void => { void this.createCustomTag() }
              })
            }
            .width('100%')
            if (this.customTags.length > 0) {
              ForEach(this.customTags, (tag: TagPresetItem) => {
                Row() {
                  Text(tag.title)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().danger)
                    .onClick((): void => { void this.removeCustomTag(tag.id) })
                }
                .width('100%')
                .padding({ top: 6, bottom: 6 })
              }, (tag: TagPresetItem) => `del_${tag.id}`)
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('关键词搜索')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            AppTextField({
              text: this.searchQuery,
              placeholder: '搜索笔记与札语…',
              onChange: (v: string): void => { this.searchQuery = v }
            })
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
