import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EssayListCard } from './EssayListCard'
import { MicroEssay } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { GrowthStore } from '../../services/GrowthStore'

@Component
export struct YearRecapPane {
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop year: number = 2026
  onClose: () => void = () => {}
  onWrite: () => void = () => {}
  onOpen: (id: string) => void = () => {}

  @State items: MicroEssay[] = []
  @State words: number = 0
  @State favCount: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const all = await EssayStore.loadAll()
    const list = GrowthStore.loadYearEssays(all, this.year)
    this.items = list
    let w = 0
    let fav = 0
    for (const it of list) {
      w += it.wordCount
      if (it.favorite) {
        fav++
      }
    }
    this.words = w
    this.favCount = fav
  }

  build() {
    Column() {
      Row() {
        Text(`${this.year} 年观察回顾`)
          .fontSize(Theme.type.title3 * this.fontScale)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      Text(`${this.items.length} 篇 · ${this.words} 字 · 珍藏 ${this.favCount}`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '这一年还没有观察',
          description: '从第一张五感卡开始，建立你的观察档案',
          actionLabel: '现在写',
          onAction: (): void => { this.onWrite() }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: MicroEssay) => {
              EssayListCard({
                essay: item,
                fontScale: this.fontScale,
                onTap: (): void => { this.onOpen(item.id) }
              })
            }, (item: MicroEssay) => item.id)
            Blank().height(Theme.space.s8)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(40)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
