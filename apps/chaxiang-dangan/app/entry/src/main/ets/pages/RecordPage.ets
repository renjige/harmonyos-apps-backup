import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TastingRecord } from '../models/TeaModels'
import { TeaMedia } from '../services/TeaMedia'
import { TeaNav } from '../services/TeaNav'
import { TeaStore } from '../services/TeaStore'
import { TastingCard } from '../components/tea/TastingCard'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('teaRev') @Watch('onTeaRevChange') teaRev: number = 0
  @State items: TastingRecord[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onTeaRevChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = TeaStore.tastings()
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(TeaMedia.tasting())
          .width('100%')
          .height(128)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(128)
          .linearGradient({
            angle: 180,
            colors: [['rgba(28,46,38,0.1)', 0], ['rgba(28,46,38,0.7)', 1]]
          })
        Column({ space: 4 }) {
          Text('品饮记录')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          Text('每一次香气，都值得留下')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textOnInverse)
        }
        .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
      }
      .clip(true)
      .borderRadius(Theme.radius.lg)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有品饮记录',
          description: '选一款茶，记下今天的感受。',
          actionLabel: '记录品饮',
          onAction: (): void => { TeaNav.openTastingEditor('', '') }
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (r: TastingRecord) => {
              TastingCard({ rec: r, onOpen: (): void => { TeaNav.openTasting(r.id) } })
            }, (r: TastingRecord) => `${r.id}-${this.teaRev}`)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 96 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.teaRev >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear((): void => { this.reload() })
  }
}
