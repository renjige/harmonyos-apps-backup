import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ElementRecord } from '../data/ElementCatalog'
import { ExploreTopic, TopicBank } from '../data/TopicBank'
import { ElementService } from '../services/ElementService'
import { ElementNav } from '../services/ElementNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct FavoritePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onProgress') progressRev: number = 0
  @State tabIndex: number = 0
  @State elements: ElementRecord[] = []
  @State topics: ExploreTopic[] = []
  @State wishlist: ElementRecord[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onProgress(): void {
    this.reload()
  }

  private reload(): void {
    const snap = ProgressStore.snapshot()
    const els: ElementRecord[] = []
    for (const sym of snap.favoriteElements) {
      const el = ElementService.findBySymbol(sym)
      if (el !== undefined) {
        els.push(el)
      }
    }
    this.elements = els
    const tops: ExploreTopic[] = []
    for (const id of snap.favoriteTopics) {
      const t = TopicBank.find(id)
      if (t !== undefined) {
        tops.push(t)
      }
    }
    this.topics = tops
    const wish: ElementRecord[] = []
    for (const sym of snap.wishlist) {
      const el = ElementService.findBySymbol(sym)
      if (el !== undefined) {
        wish.push(el)
      }
    }
    this.wishlist = wish
  }

  build() {
    Column() {
      Text('我的收藏')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: Theme.space.s2 }) {
        this.TabChip('元素', 0)
        this.TabChip('专题', 1)
        this.TabChip('待探索', 2)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        if (this.tabIndex === 0) {
          if (this.elements.length === 0) {
            AppEmpty({
              title: '暂无收藏元素',
              description: '在元素详情页点击「收藏」即可加入'
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.elements, (el: ElementRecord) => {
                this.ListRow(`${el.symbol} ${el.nameCn}`, el.summary, (): void => {
                  ElementNav.openDetail(el.symbol)
                })
              }, (el: ElementRecord) => el.symbol)
            }
            .width('100%')
          }
        } else if (this.tabIndex === 1) {
          if (this.topics.length === 0) {
            AppEmpty({
              title: '暂无收藏专题',
              description: '浏览探索专题后可收藏感兴趣的主题'
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.topics, (topic: ExploreTopic) => {
                this.ListRow(topic.title, topic.summary, (): void => {
                  if (topic.elementSymbols.length > 0) {
                    ElementNav.openDetail(topic.elementSymbols[0])
                  }
                })
              }, (topic: ExploreTopic) => topic.id)
            }
            .width('100%')
          }
        } else {
          if (this.wishlist.length === 0) {
            AppEmpty({
              title: '待探索清单为空',
              description: '在周期表或详情页加入「待探索」'
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.wishlist, (el: ElementRecord) => {
                this.ListRow(`${el.symbol} ${el.nameCn}`, '点击开始探索', (): void => {
                  ElementNav.openDetail(el.symbol)
                })
              }, (el: ElementRecord) => el.symbol)
            }
            .width('100%')
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  TabChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(this.tabIndex === index ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.tabIndex === index ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .border({ width: 1, color: Theme.colors().strokeHairline })
      .onClick((): void => { this.tabIndex = index })
  }

  @Builder
  ListRow(title: string, subtitle: string, onTap: () => void) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick((): void => { onTap() })
  }
}
