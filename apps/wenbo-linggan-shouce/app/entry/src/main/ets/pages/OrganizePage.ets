import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import {
  InspirationItem,
  SearchResultData,
  TagPresetItem
} from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State filterDate: string = ''
  @State filterTag: string = ''
  @State searchQuery: string = ''
  @State searchTab: string = 'inspirations'
  @State filterResults: InspirationItem[] = []
  @State searchData: SearchResultData = new SearchResultData()
  @State tagPresets: TagPresetItem[] = []
  @State searched: boolean = false
  @State searchMode: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await InspirationBizService.loadTagPresets()
  }


  private async runFilter(): Promise<void> {
    this.searched = true
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      this.searchMode = true
      const res = await InspirationBizService.search(q, this.currentUsername)
      this.searchData = res
      this.searchTab = 'inspirations'
      return
    }
    this.searchMode = false
    let items = await InspirationBizService.loadInspirations(this.currentUsername)
    if (this.filterDate.length > 0) {
      const filtered: InspirationItem[] = []
      for (const item of items) {
        if (item.recordDate === this.filterDate) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    if (this.filterTag.length > 0) {
      const filtered: InspirationItem[] = []
      for (const item of items) {
        let matched = false
        for (const t of item.tags) {
          if (t === this.filterTag) {
            matched = true
          }
        }
        if (matched) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    this.filterResults = items
  }

  private currentSearchList(): InspirationItem[] {
    const out: InspirationItem[] = []
    if (this.searchTab === 'inspirations') {
      for (const w of this.searchData.inspirations) {
        out.push(InspirationItem.fromWire(w))
      }
    } else if (this.searchTab === 'boards') {
      for (const w of this.searchData.boards) {
        out.push(InspirationItem.fromWire(w))
      }
    } else if (this.searchTab === 'plans') {
      for (const w of this.searchData.plans) {
        out.push(InspirationItem.fromWire(w))
      }
    } else if (this.searchTab === 'favorites') {
      for (const w of this.searchData.favorites) {
        out.push(InspirationItem.fromWire(w))
      }
    } else if (this.searchTab === 'topics') {
      for (const w of this.searchData.topics) {
        out.push(InspirationItem.fromWire(w))
      }
    }
    return out
  }

  private openItem(item: InspirationItem): void {
    if (this.searchTab === 'boards') {
      InspirationDetailNav.openBoard(item.id)
    } else if (this.searchTab === 'plans') {
      InspirationDetailNav.openPlan(item.id)
    } else if (this.searchTab === 'topics') {
      InspirationDetailNav.openTopic(item.id)
    } else {
      InspirationDetailNav.openInspiration(item.id)
    }
  }

  @Builder
  SearchTabChip(label: string, key: string, count: number) {
    Text(`${label}(${count})`)
      .fontSize(Theme.type.caption)
      .fontColor(this.searchTab === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.searchTab === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .margin({ right: 8, bottom: 8 })
      .onClick((): void => { this.searchTab = key })
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
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          AppDatePickerField({
            label: '按日期筛选',
            value: this.filterDate,
            placeholder: '不限日期',
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.filterDate = v }
          })

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
            Text('全局搜索（灵感 / 画板 / 计划 / 收藏 / 专题）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.searchQuery, placeholder: '标题或正文关键词…' })
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.searchQuery = v })
          }
          .width('100%')

          AppButton({
            label: '开始整理',
            onTap: (): void => { void this.runFilter() }
          })

          if (this.searched && this.searchMode) {
            Flex({ wrap: FlexWrap.Wrap }) {
              this.SearchTabChip('灵感', 'inspirations', this.searchData.inspirations.length)
              this.SearchTabChip('画板', 'boards', this.searchData.boards.length)
              this.SearchTabChip('计划', 'plans', this.searchData.plans.length)
              this.SearchTabChip('收藏', 'favorites', this.searchData.favorites.length)
              this.SearchTabChip('专题', 'topics', this.searchData.topics.length)
            }
            .width('100%')

            if (this.currentSearchList().length === 0) {
              AppEmpty({
                title: '该分类暂无匹配',
                description: '试试其他分类或调整关键词'
              })
            } else {
              ForEach(this.currentSearchList(), (item: InspirationItem) => {
                InspirationListCard({
                  item: item,
                  onTap: (): void => { this.openItem(item) }
                })
              }, (item: InspirationItem) => `${this.searchTab}_${item.id}`)
            }
          } else if (this.searched) {
            if (this.filterResults.length === 0) {
              AppEmpty({
                title: '暂无匹配结果',
                description: '试试调整日期、标签或输入关键词搜索'
              })
            } else {
              ForEach(this.filterResults, (item: InspirationItem) => {
                InspirationListCard({
                  item: item,
                  onTap: (): void => { InspirationDetailNav.openInspiration(item.id) }
                })
              }, (item: InspirationItem) => item.id)
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
    .backgroundColor(Theme.colors().surfacePage)
  }
}
