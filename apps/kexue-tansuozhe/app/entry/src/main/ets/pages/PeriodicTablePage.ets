import { Theme } from '../components/design-system/Theme'
import { ElementRecord } from '../data/ElementCatalog'
import { ElementService } from '../services/ElementService'
import { ElementNav } from '../services/ElementNav'
import { ProgressStore } from '../services/ProgressStore'
import { ElementTile } from '../components/element/ElementTile'

class FilterChip {
  key: string = ''
  label: string = ''

  static all(): FilterChip[] {
    const list: FilterChip[] = []
    const defs: string[][] = [
      ['all', '全部'],
      ['metal', '金属'],
      ['nonmetal', '非金属'],
      ['halogen', '卤素'],
      ['noble_gas', '稀有气体'],
      ['other', '其他']
    ]
    for (const d of defs) {
      const c = new FilterChip()
      c.key = d[0]
      c.label = d[1]
      list.push(c)
    }
    return list
  }
}

@Component
export struct PeriodicTablePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') progressRev: number = 0
  @State filterKey: string = 'all'
  @State elements: ElementRecord[] = []
  private chips: FilterChip[] = FilterChip.all()

  aboutToAppear(): void {
    this.applyFilter('all')
  }

  private applyFilter(key: string): void {
    this.filterKey = key
    this.elements = ElementService.filterByGroup(key === 'all' ? '' : key)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Image($r('app.media.ambient_lab'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.12)

      Column() {
        Text('元素周期表')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.chips, (chip: FilterChip) => {
              Text(chip.label)
                .fontSize(Theme.type.subhead)
                .fontColor(this.filterKey === chip.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor(this.filterKey === chip.key ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => { this.applyFilter(chip.key) })
            }, (chip: FilterChip) => chip.key)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .margin({ bottom: Theme.space.s3 })

        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.elements, (el: ElementRecord) => {
              Column() {
                ElementTile({
                  element: el,
                  explored: ProgressStore.isExplored(el.symbol),
                  onTap: (): void => { ElementNav.openDetail(el.symbol) }
                })
              }
              .width('23%')
              .margin({ bottom: Theme.space.s2 })
            }, (el: ElementRecord) => `${el.symbol}_${this.progressRev}`)
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
