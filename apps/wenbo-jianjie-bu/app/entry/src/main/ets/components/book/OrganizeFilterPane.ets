import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { EntryListCard } from './EntryListCard'
import { InsightEntry } from '../../models/InsightModels'

@Component
export struct OrganizeFilterPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop items: InsightEntry[] = []
  @Prop bottomInset: number = 76
  onBack: () => void = () => {}
  onOpen: (id: string) => void = (_id: string) => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onBack() })
        Text(this.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Column().width(40)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.items.length === 0) {
        AppEmpty({ title: '此分类暂无见解', description: '换一个标签或笔记本看看' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (it: InsightEntry) => {
            ListItem() {
              EntryListCard({
                item: it,
                starredFlag: it.starred,
                stamp: it.updatedAt,
                onOpen: (): void => { this.onOpen(it.id) }
              })
              .margin({ bottom: 10 })
            }
          }, (it: InsightEntry) => `${it.id}_${it.starred ? 's' : 'n'}_${it.updatedAt}`)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: this.bottomInset })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}
