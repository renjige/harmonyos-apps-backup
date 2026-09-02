import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { FeedCardFromItem } from '../components/archive/FeedCard'
import { FeedItem, LabelOption } from '../models/JianModels'
import { JianStore } from '../services/JianStore'
import { JianNav } from '../services/JianNav'
import { JianMedia } from '../services/JianMedia'

@Component
export struct ArchivePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('jianDataRev') @Watch('onDataRevChange') jianDataRev: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State tab: string = 'thought'
  @State items: FeedItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onDataRevChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const out: FeedItem[] = []
    if (this.tab === 'card') {
      const list = await JianStore.loadCards()
      for (const c of list) {
        out.push(this.toFeed('card', c.id, c.title, c.content, '观点卡片', c.updatedAt))
      }
    } else if (this.tab === 'spark') {
      const list = await JianStore.loadSparks()
      for (const s of list) {
        out.push(this.toFeed('spark', s.id, s.title, s.body, LabelOption.labelOf(LabelOption.sparkKinds(), s.kind), s.updatedAt))
      }
    } else {
      const list = await JianStore.loadThoughts()
      for (const t of list) {
        out.push(this.toFeed('thought', t.id, t.title, t.body, LabelOption.labelOf(LabelOption.statuses(), t.status), t.updatedAt))
      }
    }
    this.items = out
  }

  private toFeed(kind: string, id: string, title: string, summary: string, meta: string, ts: number): FeedItem {
    const f = new FeedItem()
    f.kind = kind
    f.id = id
    f.title = title
    f.summary = summary
    f.meta = meta
    f.ts = ts
    return f
  }

  private switchTab(key: string): void {
    this.tab = key
    void this.reload()
  }

  private openItem(it: FeedItem): void {
    if (it.kind === 'card') {
      JianNav.openCard(it.id)
      return
    }
    if (it.kind === 'spark') {
      JianNav.openSpark(it.id)
      return
    }
    JianNav.openThought(it.id)
  }

  private addNew(): void {
    JianNav.openEditor(this.tab === 'thought' ? 'thought' : this.tab, '')
  }

  build() {
    Column() {
      Row() {
        Text('思维档案')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.addNew() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      Image(JianMedia.bannerPaper())
        .width('100%')
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Row({ space: Theme.space.s2 }) {
        this.Seg('thought', '思考')
        this.Seg('spark', '灵感')
        this.Seg('card', '观点卡')
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '这一格还是空的',
          description: '点右上角新建，开始沉淀',
          actionLabel: '新建',
          onAction: (): void => { this.addNew() }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (it: FeedItem) => {
            ListItem() {
              FeedCardFromItem({ item: it, onTap: (): void => { this.openItem(it) } })
            }
            .padding({ bottom: Theme.space.s3 })
          }, (it: FeedItem) => it.id)
        }
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3, bottom: this.bottomInset })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  Seg(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.footnote)
      .fontColor(this.tab === key ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.tab === key ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.switchTab(key) })
  }
}
