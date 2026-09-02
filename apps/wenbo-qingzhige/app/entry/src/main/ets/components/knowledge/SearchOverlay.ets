import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { KnowledgeListCard } from './KnowledgeListCard'
import { KnowledgeItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('knowledgeRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State query: string = ''
  @State results: KnowledgeItem[] = []
  @State history: string[] = []
  @State searched: boolean = false

  aboutToAppear(): void {
    this.history = KnowledgeStore.searchHistory()
  }

  onRefresh(): void {
    if (this.searched) {
      this.results = KnowledgeStore.search(this.query)
    }
  }

  private async runSearch(): Promise<void> {
    const q = this.query.trim()
    this.searched = true
    if (q.length === 0) {
      this.results = []
      return
    }
    await KnowledgeStore.pushHistory(q)
    this.history = KnowledgeStore.searchHistory()
    this.results = KnowledgeStore.search(q)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { KnowledgeNav.closeSearch() })
        TextInput({ text: this.query, placeholder: '搜索标题、正文、标签或分类' })
          .layoutWeight(1)
          .onChange((v: string) => { this.query = v })
          .onSubmit(() => { void this.runSearch() })
        if (this.query.length > 0) {
          Text('清除')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick((): void => {
              this.query = ''
              this.results = []
              this.searched = false
            })
        }
      }
      .width('100%')
      .padding({ left: 8, right: Theme.space.pageX, top: 8 })

      if (!this.searched) {
        Column({ space: Theme.space.s3 }) {
          Row() {
            Text('搜索历史')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            Blank()
            if (this.history.length > 0) {
              Text('清空')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .onClick((): void => { void KnowledgeStore.clearHistory().then(() => { this.history = [] }) })
            }
          }
          .width('100%')
          if (this.history.length === 0) {
            Text('还没有搜索过。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }
          ForEach(this.history, (h: string) => {
            Text(h)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .onClick((): void => {
                this.query = h
                void this.runSearch()
              })
          }, (h: string) => h)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      } else if (this.results.length === 0) {
        AppEmpty({
          title: '还没有找到相关轻知',
          description: '换个关键词试试',
          actionLabel: '换个关键词试试',
          onAction: (): void => {
            this.query = ''
            this.searched = false
          }
        })
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.results, (item: KnowledgeItem) => {
            ListItem() {
              KnowledgeListCard({
                itemId: item.id,
                title: item.title,
                summary: item.summaryLine(),
                category: item.category,
                tags: item.tags,
                coverKey: item.coverKey,
                updatedAt: item.updatedAt,
                favorited: item.favorited,
                onOpen: (): void => { KnowledgeNav.openDetail(item.id) }
              })
            }
          }, (item: KnowledgeItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
