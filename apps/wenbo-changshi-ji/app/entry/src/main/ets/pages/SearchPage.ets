import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { CategoryChip, FactItem } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State facts: FactItem[] = []
  @State filtered: FactItem[] = []
  @State keyword: string = ''
  @State category: string = 'all'
  private chips: CategoryChip[] = CategoryChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.facts = await CommonSenseBizService.loadFacts()
    this.apply()
  }

  private apply(): void {
    let rows = CommonSenseBizService.filterByCategory(this.facts, this.category)
    rows = CommonSenseBizService.search(rows, this.keyword)
    this.filtered = rows
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
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('常识搜索')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      TextInput({ text: this.keyword, placeholder: '输入关键词，快速定位常识' })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        .onChange((v: string): void => {
          this.keyword = v
          this.apply()
        })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (chip: CategoryChip) => {
            Text(chip.label)
              .fontSize(12)
              .fontColor(this.category === chip.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.category === chip.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.category = chip.key
                this.apply()
              })
          }, (chip: CategoryChip) => chip.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)

      Text(`共 ${this.filtered.length} 条`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, top: 8 })

      if (this.filtered.length === 0) {
        AppEmpty({ title: '没有匹配结果', description: '换个词，或把分类切回全部。' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.filtered, (row: FactItem) => {
              ContentCard({
                item: row,
                compact: false,
                onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
              })
            }, (row: FactItem) => row.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
