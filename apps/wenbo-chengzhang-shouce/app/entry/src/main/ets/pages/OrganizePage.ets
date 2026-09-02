import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { GrowthListCard } from '../components/growth/GrowthListCard'
import { GrowthRecordItem, TagPresetItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'

@Component
export struct OrganizePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State filterDate: string = ''
  @State filterTag: string = ''
  @State searchQuery: string = ''
  @State results: GrowthRecordItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State searched: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await GrowthBizService.loadTagPresets()
  }

  private async runFilter(): Promise<void> {
    this.searched = true
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      const res = await GrowthBizService.search(q, this.currentUsername)
      this.results = []
      for (const w of res.records) {
        this.results.push(GrowthRecordItem.fromWire(w))
      }
      return
    }
    let items = await GrowthBizService.loadRecords(this.currentUsername)
    if (this.filterDate.length > 0) {
      const filtered: GrowthRecordItem[] = []
      for (const item of items) {
        if (item.recordDate === this.filterDate) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    if (this.filterTag.length > 0) {
      const filtered: GrowthRecordItem[] = []
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
    this.results = items
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
            Text('关键词搜索')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.searchQuery, placeholder: '标题或正文关键词…' })
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
                description: '试试调整日期、标签或关键词'
              })
            } else {
              ForEach(this.results, (item: GrowthRecordItem) => {
                GrowthListCard({
                  item: item,
                  onTap: (): void => { GrowthDetailNav.openInspiration(item.id) }
                })
              }, (item: GrowthRecordItem) => item.id)
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
