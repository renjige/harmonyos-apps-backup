import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { TeaItem, TeaTypeDef } from '../models/TeaModels'
import { TeaMedia } from '../services/TeaMedia'
import { TeaNav } from '../services/TeaNav'
import { TeaStore } from '../services/TeaStore'
import { TeaCabinetCard } from '../components/tea/TeaCabinetCard'

@Component
export struct CabinetPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('teaRev') @Watch('onTeaRevChange') teaRev: number = 0
  @State typeKey: string = ''
  @State statusKey: string = ''
  @State query: string = ''
  @State teas: TeaItem[] = []
  @State typeDefs: TeaTypeDef[] = []

  aboutToAppear(): void {
    this.typeDefs = TeaTypeDef.six()
    this.reload()
  }

  onTeaRevChange(): void {
    this.reload()
  }

  private reload(): void {
    let list = this.query.length > 0 ? TeaStore.search(this.query) : TeaStore.teas()
    const out: TeaItem[] = []
    for (const t of list) {
      let ok = true
      if (this.typeKey.length > 0 && t.typeKey !== this.typeKey) {
        ok = false
      }
      if (this.statusKey.length > 0 && t.stockStatus !== this.statusKey) {
        ok = false
      }
      if (ok) {
        out.push(t)
      }
    }
    this.teas = out
  }

  private selectType(key: string): void {
    this.typeKey = key
    this.reload()
  }

  private selectStatus(key: string): void {
    this.statusKey = key
    this.reload()
  }

  @Builder
  typeChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.typeKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.typeKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectType(key) })
  }

  @Builder
  statusChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.statusKey === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.statusKey === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.selectStatus(key) })
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(TeaMedia.cabinet())
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(28,46,38,0.15)', 0], ['rgba(28,46,38,0.72)', 1]]
          })
        Text('茶库')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
      }
      .width('100%')
      .clip(true)
      .borderRadius(Theme.radius.lg)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.query, placeholder: '搜索茶名、产地、标签…' })
          .layoutWeight(1)
          .onChange((v: string): void => {
            this.query = v
            this.reload()
          })
        Column() {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { TeaNav.openSearch() })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Row({ space: 8 }) {
          this.typeChip('全部', '')
          ForEach(this.typeDefs, (d: TeaTypeDef) => {
            this.typeChip(d.name, d.key)
          }, (d: TeaTypeDef) => d.key)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .padding({ left: Theme.space.pageX })

      Scroll() {
        Row({ space: 8 }) {
          this.statusChip('状态不限', '')
          this.statusChip('已收藏', 'collected')
          this.statusChip('正在品饮', 'sipping')
          this.statusChip('已饮完', 'finished')
          this.statusChip('想尝试', 'wishlist')
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .padding({ left: Theme.space.pageX })

      if (this.teas.length === 0) {
        AppEmpty({
          title: '茶柜还是空的',
          description: '新增一款茶，开始你的茶香档案。',
          actionLabel: '新增茶档案',
          onAction: (): void => { TeaNav.openTeaEditor('') }
        })
      } else {
        // 不用 ListItem：部分机型会裁切卡片高度，只露出标题一行
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.teas, (t: TeaItem) => {
              TeaCabinetCard({ tea: t, onOpen: (): void => { TeaNav.openTea(t.id) } })
            }, (t: TeaItem) => `${t.id}-${this.teaRev}`)
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
