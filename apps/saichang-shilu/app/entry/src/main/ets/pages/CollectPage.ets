import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'
import { CollectKindTile } from '../components/sport/SportCards'
import { SectionHeader } from '../components/sport/SportVisual'
import { CollectItem, CollectKindMeta } from '../models/CollectModels'
import { CollectStore } from '../services/CollectStore'
import { MemoryStats } from '../services/MemoryStats'
import { CollectEditPage } from './CollectEditPage'

class AlbumPreset {
  title: string = ''
  sub: string = ''
  tags: string = ''

  static list(): AlbumPreset[] {
    const a = new AlbumPreset()
    a.title = '经典之战'
    a.sub = '收录你认为最难忘的对决'
    a.tags = '经典,逆转'
    const b = new AlbumPreset()
    b.title = '决赛专题'
    b.sub = '冠军争夺战与关键节点'
    b.tags = '决赛,冠军'
    const c = new AlbumPreset()
    c.title = '逆转时刻'
    c.sub = '落后翻盘、读秒绝杀合集'
    c.tags = '逆转,绝杀'
    return [a, b, c]
  }
}

@Component
export struct CollectPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State kind: string = 'team'
  @State items: CollectItem[] = []
  @State kindCounts: number[] = [0, 0, 0, 0]
  @State query: string = ''
  @State showEdit: boolean = false
  @State editSeed: string = ''
  @State presetTitle: string = ''
  @State presetSub: string = ''
  @State presetTags: string = ''
  @State detail: CollectItem | undefined = undefined
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private kindMetas: CollectKindMeta[] = CollectKindMeta.all()
  private albumPresets: AlbumPreset[] = AlbumPreset.list()

  aboutToAppear(): void {
    void this.reload()
  }

  private countFor(id: string): number {
    if (id === 'team') {
      return this.kindCounts[0]
    }
    if (id === 'player') {
      return this.kindCounts[1]
    }
    if (id === 'album') {
      return this.kindCounts[2]
    }
    return this.kindCounts[3]
  }

  private async reload(): Promise<void> {
    const all = await CollectStore.loadAll()
    let tc = 0
    let pc = 0
    let ac = 0
    let fc = 0
    for (const it of all) {
      if (it.kind === 'team') {
        tc++
      } else if (it.kind === 'player') {
        pc++
      } else if (it.kind === 'album') {
        ac++
      } else if (it.kind === 'perf') {
        fc++
      }
    }
    this.kindCounts = [tc, pc, ac, fc]
    const filtered: CollectItem[] = []
    for (const it of all) {
      if (it.kind === this.kind) {
        filtered.push(it)
      }
    }
    this.items = MemoryStats.searchItems(filtered, this.query)
  }

  private openNew(): void {
    this.editSeed = ''
    this.presetTitle = ''
    this.presetSub = ''
    this.presetTags = ''
    this.showEdit = true
  }

  private openAlbumPreset(p: AlbumPreset): void {
    this.kind = 'album'
    this.editSeed = ''
    this.presetTitle = p.title
    this.presetSub = p.sub
    this.presetTags = p.tags
    this.showEdit = true
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('收藏')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('新建')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.openNew() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_monthly'))
            .width('100%')
            .height(96)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column() {
            Blank()
            Text('球队 · 球员 · 专题 · 表现卡')
              .fontSize(Theme.type.bodyS)
              .fontColor('#FFFFFF')
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.85)', 1]]
              })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(96)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

        TextInput({ text: this.query, placeholder: '搜索球队 / 球员 / 标签' })
          .onChange((v: string) => {
            this.query = v
            void this.reload()
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)

        Scroll() {
          Row() {
            ForEach(this.kindMetas, (meta: CollectKindMeta) => {
              CollectKindTile({
                meta: meta,
                count: this.countFor(meta.id),
                active: this.kind === meta.id,
                onTap: (): void => {
                  this.kind = meta.id
                  void this.reload()
                }
              })
            }, (meta: CollectKindMeta) => meta.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s3 })

        if (this.kind === 'album') {
          Column({ space: Theme.space.s2 }) {
            SectionHeader({ title: '专题模板', action: '' })
            Row({ space: Theme.space.s2 }) {
              ForEach(this.albumPresets, (p: AlbumPreset) => {
                Column({ space: 4 }) {
                  Text(p.title)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(p.sub)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(1)
                }
                .layoutWeight(1)
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.openAlbumPreset(p) })
              }, (p: AlbumPreset) => p.title)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text(CollectKindMeta.of(this.kind).hint)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            if (this.items.length === 0) {
              AppEmpty({
                title: '收藏夹还是空的',
                description: '建立球队、球员或专题，把喜欢的比赛收成自己的档案',
                actionLabel: '新建',
                onAction: (): void => { this.openNew() }
              })
            } else {
              ForEach(this.items, (it: CollectItem) => {
                this.CollectRow(it)
              }, (it: CollectItem) => it.id)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detail !== undefined) {
        CollectDetailPane({
          item: this.detail,
          onClose: (): void => { this.detail = undefined },
          onDeleted: (): void => { this.detail = undefined; void this.reload() },
          onEdit: (): void => {
            this.editSeed = (this.detail as CollectItem).id
            this.kind = (this.detail as CollectItem).kind
            this.detail = undefined
            this.showEdit = true
          }
        })
      }
      if (this.showEdit) {
        CollectEditPage({
          editKind: this.kind,
          seedId: this.editSeed,
          presetTitle: this.presetTitle,
          presetSub: this.presetSub,
          presetTags: this.presetTags,
          onClose: (): void => { this.showEdit = false },
          onSaved: (): void => { void this.reload() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }

  @Builder
  CollectRow(it: CollectItem) {
    Row({ space: Theme.space.s3 }) {
      Column() {
        Text(it.kind === 'team' ? '队' : (it.kind === 'player' ? '员' : (it.kind === 'album' ? '专' : '卡')))
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(44)
      .height(44)
      .borderRadius(Theme.radius.md)
      .backgroundColor(CollectKindMeta.of(it.kind).accent)
      .justifyContent(FlexAlign.Center)

      Column({ space: 4 }) {
        Text(it.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(it.sub.length > 0 ? it.sub : (it.body.length > 0 ? it.body : it.extra))
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
        if (it.tags.length > 0) {
          Text(it.tags.replace(/,/g, ' · '))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .onClick((): void => { this.detail = it })
  }
}
