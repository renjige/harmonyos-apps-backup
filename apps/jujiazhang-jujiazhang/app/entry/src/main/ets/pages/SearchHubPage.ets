import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FormSheetHeader } from '../components/design-system/FormSheetHeader'
import { ChoiceChip } from '../components/family/ChoiceChip'
import { SearchHit } from '../models/JujiaModels'
import { SearchService } from '../services/SearchService'

@Component
export struct SearchHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State keyword: string = ''
  @State filter: string = 'all'
  @State hits: SearchHit[] = []
  onClose: () => void = () => {}
  onOpenHit: (hit: SearchHit) => void = (_h: SearchHit) => {}

  private runSearch(): void {
    this.hits = SearchService.match(this.keyword, this.filter)
  }

  build() {
    Column() {
      FormSheetHeader({ title: '搜索家庭内容', onClose: () => this.onClose() })
      Row({ space: 8 }) {
        TextInput({ text: this.keyword, placeholder: '搜索计划、物品、备忘…' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .onChange((v: string) => {
            this.keyword = v
            this.runSearch()
          })
        Column() {
          AppIcon({ name: 'search', iconSize: 20, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick(() => this.runSearch())
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      Scroll() {
        Row({ space: 8 }) {
          ChoiceChip({ label: '全部', active: this.filter === 'all', onPick: () => { this.filter = 'all'; this.runSearch() } })
          ChoiceChip({ label: '计划', active: this.filter === 'task', onPick: () => { this.filter = 'task'; this.runSearch() } })
          ChoiceChip({ label: '物品', active: this.filter === 'item', onPick: () => { this.filter = 'item'; this.runSearch() } })
          ChoiceChip({ label: '备忘', active: this.filter === 'memo', onPick: () => { this.filter = 'memo'; this.runSearch() } })
          ChoiceChip({ label: '清单', active: this.filter === 'checklist', onPick: () => { this.filter = 'checklist'; this.runSearch() } })
          ChoiceChip({ label: '日记', active: this.filter === 'diary', onPick: () => { this.filter = 'diary'; this.runSearch() } })
        }
        .padding({ left: 16, right: 16, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      Scroll() {
        Column({ space: 8 }) {
          if (this.keyword.trim().length === 0) {
            AppEmpty({ title: '输入关键词', description: '可搜索计划标题、物品名称、备忘正文等。', actionLabel: '', onAction: () => {} })
          } else if (this.hits.length === 0) {
            AppEmpty({ title: '未找到结果', description: '换个关键词或切换分类试试。', actionLabel: '', onAction: () => {} })
          } else {
            ForEach(this.hits, (hit: SearchHit) => {
              Row({ space: 10 }) {
                Column({ space: 2 }) {
                  Text(hit.title)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(hit.subtitle)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text(hit.tag)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
                AppIcon({ name: 'chevron', iconSize: 14, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.lg)
              .onClick(() => this.onOpenHit(hit))
            }, (hit: SearchHit) => `${hit.entityType}_${hit.entityId}`)
          }
        }
        .padding({ left: 16, right: 16, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
