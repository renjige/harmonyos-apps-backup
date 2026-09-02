import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadListCard } from '../components/wisdom/ReadListCard'
import { WisdomItem } from '../models/WisdomHallModels'
import { WisdomHallBizService } from '../services/WisdomHallBizService'
import { WisdomHallNav } from '../services/WisdomHallNav'

class CategoryChip {
  label: string = ''

  static all(): CategoryChip[] {
    const labels = ['全部', '人生智慧', '处世哲学', '职场心法', '生活美学', '经典品读']
    const chips: CategoryChip[] = []
    for (const label of labels) {
      const chip = new CategoryChip()
      chip.label = label
      chips.push(chip)
    }
    return chips
  }
}

@Component
export struct WenCuiPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State activeCategory: string = '全部'
  @State searchText: string = ''
  @State reads: WisdomItem[] = []
  @State quotes: WisdomItem[] = []
  @State filtered: WisdomItem[] = []
  private categories: CategoryChip[] = CategoryChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.reads = await WisdomHallBizService.loadReads()
    this.quotes = await WisdomHallBizService.loadQuotes()
    this.applyFilter()
  }

  private mapCategory(item: WisdomItem): string {
    const cat = item.category
    if (cat.length > 0) {
      if (cat === '人生' || cat === '情感') {
        return '人生智慧'
      }
      if (cat === '职场') {
        return '职场心法'
      }
      if (cat === '阅读') {
        return '经典品读'
      }
      if (cat === '灵感') {
        return '生活美学'
      }
    }
    const author = item.authorName
    if (author.indexOf('老子') >= 0 || author.indexOf('庄子') >= 0 || author.indexOf('孟子') >= 0) {
      return '处世哲学'
    }
    return '人生智慧'
  }

  private isReadItem(item: WisdomItem): boolean {
    if (item.readMinutes > 0) {
      return true
    }
    return item.body.length > 80
  }

  private applyFilter(): void {
    const merged: WisdomItem[] = []
    for (const q of this.quotes) {
      merged.push(q)
    }
    for (const r of this.reads) {
      merged.push(r)
    }
    const keyword = this.searchText.trim()
    const next: WisdomItem[] = []
    for (const item of merged) {
      const uiCat = this.mapCategory(item)
      if (this.activeCategory !== '全部' && uiCat !== this.activeCategory) {
        continue
      }
      if (keyword.length > 0) {
        const hay = `${item.title}${item.summaryLine()}${item.authorName}`
        if (hay.indexOf(keyword) < 0) {
          continue
        }
      }
      next.push(item)
    }
    this.filtered = next
  }

  build() {
    Column() {
      Row() {
        Text('文萃')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.searchText, placeholder: '搜索标题或作者' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 16, right: 16 })
          .onChange((v: string) => {
            this.searchText = v
            this.applyFilter()
          })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.categories, (chip: CategoryChip) => {
            Text(chip.label)
              .fontSize(Theme.type.caption)
              .fontColor(this.activeCategory === chip.label ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor(this.activeCategory === chip.label ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.activeCategory = chip.label
                this.applyFilter()
              })
          }, (chip: CategoryChip) => chip.label)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.filtered.length === 0) {
        AppEmpty({ title: '暂无内容', description: '换个分类或关键词试试' })
          .layoutWeight(1)
      } else {
        List({ space: Theme.space.s3 }) {
          ForEach(this.filtered, (item: WisdomItem) => {
            ListItem() {
              ReadListCard({
                title: item.title,
                summary: item.summaryLine(),
                category: this.mapCategory(item),
                readMinutes: item.readMinutes > 0 ? item.readMinutes : 1,
                coverKey: item.coverKey.length > 0 ? item.coverKey : 'cover_wisdom_ink',
                onOpen: (): void => {
                  const kind = this.isReadItem(item) ? 'read' : 'quote'
                  WisdomHallNav.openDetail(kind, item.id)
                }
              })
            }
          }, (item: WisdomItem) => item.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
