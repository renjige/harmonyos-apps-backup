import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { WorkListCard } from '../components/handcraft/WorkListCard'
import { HandcraftWork, HandcraftCategory } from '../models/HandcraftModels'
import { HandcraftBizService } from '../services/HandcraftBizService'
import { CraftDetailNav } from '../services/CraftDetailNav'
import { CraftLocalStore } from '../services/CraftLocalStore'

@Component
export struct ClassroomPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State guides: HandcraftWork[] = []
  @State categories: HandcraftCategory[] = []
  @State loading: boolean = true
  @State searchQ: string = ''
  @State filterCat: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.categories = await HandcraftBizService.loadCategories()
    this.guides = await HandcraftBizService.loadGuides()
    this.loading = false
  }

  private filtered(): HandcraftWork[] {
    const q = this.searchQ.trim().toLowerCase()
    const out: HandcraftWork[] = []
    for (const g of this.guides) {
      if (this.filterCat.length > 0 && g.category !== this.filterCat) {
        continue
      }
      if (q.length > 0 &&
        !g.title.toLowerCase().includes(q) &&
        !g.summary.toLowerCase().includes(q) &&
        !g.category.toLowerCase().includes(q)) {
        continue
      }
      out.push(g)
    }
    return out
  }

  private openGuide(g: HandcraftWork): void {
    void CraftLocalStore.setLastGuide(g.id, g.title)
    CraftDetailNav.openGuide(g.id)
  }

  build() {
    Column() {
      AppHeader({ title: '课堂', subtitle: '官方教程 · 分类浏览 · 跟做实践' })
      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textTertiary })
        TextInput({ text: this.searchQ, placeholder: '搜索教程名称或分类…' })
          .layoutWeight(1)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .padding({ left: 12, right: 12 })
          .onChange((v: string) => { this.searchQ = v })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.categories.length > 0) {
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            Text('全部')
              .fontSize(Theme.type.caption)
              .fontColor(this.filterCat.length === 0 ?
                Theme.colors().textOnInverse : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.filterCat.length === 0 ?
                Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick(() => { this.filterCat = '' })
            ForEach(this.categories, (cat: HandcraftCategory) => {
              Text(cat.title)
                .fontSize(Theme.type.caption)
                .fontColor(this.filterCat === cat.title ?
                  Theme.colors().textOnInverse : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.filterCat === cat.title ?
                  Theme.colors().brandDeep : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.filterCat = cat.title })
            }, (cat: HandcraftCategory) => cat.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })
      }

      if (this.loading) {
        AppLoading({ label: '加载课堂…' })
      } else if (this.filtered().length === 0) {
        AppEmpty({ title: '未找到教程', description: '试试更换分类或关键词' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.filtered(), (g: HandcraftWork) => {
              WorkListCard({
                work: g,
                onTap: (): void => { this.openGuide(g) }
              })
            }, (g: HandcraftWork) => g.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
