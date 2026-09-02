import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EssayListCard } from './EssayListCard'
import { MicroEssay } from '../../models/EssayModels'
import { EssayStore } from '../../services/EssayStore'
import { GrowthStore } from '../../services/GrowthStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct MonthRecapPane {
  @StorageLink('essayFontScale') fontScale: number = 1
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop year: number = 2026
  @Prop month: number = 1
  onClose: () => void = () => {}
  onWrite: () => void = () => {}
  onOpen: (id: string) => void = () => {}

  @State items: MicroEssay[] = []
  @State words: number = 0

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const all = await EssayStore.loadAll()
    const list = GrowthStore.loadMonthEssays(all, this.year, this.month)
    this.items = list
    let w = 0
    for (const it of list) {
      w += it.wordCount
    }
    this.words = w
  }

  build() {
    Column() {
      Row() {
        Text('本月观察回顾')
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

      Text(`${DateHelper.monthTitle(this.year, this.month)} · ${this.items.length} 篇 · ${this.words} 字`)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '这个月还没有观察',
          description: '补记一篇，月历上会出现打点',
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
