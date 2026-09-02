import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { NoteListCard } from '../components/note/NoteListCard'
import { NoteItem, TagStat } from '../models/NoteModels'
import { NoteNav } from '../services/NoteNav'
import { NoteStore } from '../services/NoteStore'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State searchQuery: string = ''
  @State results: NoteItem[] = []
  @State tagStats: TagStat[] = []
  @State similarTags: string[] = []
  @State activeTag: string = ''
  @State searched: boolean = false

  aboutToAppear(): void {
    this.reloadMeta()
  }

  onRefresh(): void {
    this.reloadMeta()
    if (this.activeTag.length > 0) {
      this.results = NoteStore.byTag(this.activeTag)
    } else if (this.searchQuery.trim().length > 0) {
      this.results = NoteStore.search(this.searchQuery.trim())
    }
  }

  private reloadMeta(): void {
    this.tagStats = NoteStore.tagStats()
    this.similarTags = NoteStore.similarTags()
  }

  private tagFontSize(count: number): number {
    if (count >= 5) {
      return Theme.type.title3
    }
    if (count >= 3) {
      return Theme.type.subhead
    }
    return Theme.type.caption
  }

  private runSearch(): void {
    this.searched = true
    this.activeTag = ''
    const q = this.searchQuery.trim()
    if (q.length === 0) {
      this.results = []
      return
    }
    this.results = NoteStore.search(q)
  }

  private filterTag(tag: string): void {
    this.activeTag = tag
    this.searchQuery = ''
    this.searched = true
    this.results = NoteStore.byTag(tag)
  }

  build() {
    Column() {
      Column({ space: 4 }) {
        Text('智慧整理')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('智能标签 · 关键词检索 · 相似主题聚合')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      .alignItems(HorizontalAlign.Start)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Search({ value: this.searchQuery, placeholder: '按日期/标签/关键词检索…' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .onChange((v: string) => { this.searchQuery = v })
            .onSubmit((): void => { this.runSearch() })

          if (this.tagStats.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('标签云')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tagStats, (t: TagStat) => {
                  Text(`${t.name} (${t.count})`)
                    .fontSize(this.tagFontSize(t.count))
                    .fontColor(this.activeTag === t.name ?
                      Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                    .backgroundColor(this.activeTag === t.name ?
                      Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.filterTag(t.name) })
                }, (t: TagStat) => t.name)
              }
              .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }

          if (this.similarTags.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('相似主题聚合')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.similarTags, (tag: string) => {
                Row() {
                  Text(tag)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('查看')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .onClick((): void => { this.filterTag(tag) })
              }, (tag: string) => tag)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }

          if (this.searched) {
            if (this.results.length === 0) {
              AppEmpty({
                title: '未找到相关记录',
                description: '换个关键词或选择标签试试',
                actionLabel: '清空筛选',
                onAction: (): void => {
                  this.searched = false
                  this.activeTag = ''
                  this.searchQuery = ''
                  this.results = []
                }
              })
            } else {
              ForEach(this.results, (item: NoteItem) => {
                NoteListCard({
                  item: item,
                  onTap: (): void => { NoteNav.openDetail(item.id) }
                })
              }, (item: NoteItem) => item.id)
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
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
