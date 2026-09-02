import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { KnowledgeListCard } from '../components/gewu/KnowledgeListCard'
import { KnowledgeObject } from '../models/KnowledgeModels'
import { KnowledgeCatalog } from '../services/KnowledgeCatalog'
import { GewuStore } from '../services/GewuStore'
import { FieldStore } from '../services/FieldStore'
import { GewuDetailNav } from '../services/GewuDetailNav'
import { GewuMedia } from '../services/GewuMedia'
import { AlbumKind, AtlasKind } from '../models/FieldModels'

class FolioFilterChip {
  key: string = 'all'
  label: string = '全部'

  constructor(key: string, label: string) {
    this.key = key
    this.label = label
  }
}

@Component
export struct FolioPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State listMode: string = 'all'
  @State categoryFilter: string = 'all'
  @State atlasFilter: string = 'all'
  @State albumFilter: string = ''
  @State keyword: string = ''
  @State items: KnowledgeObject[] = []
  @StorageLink('folioListMode') @Watch('onFolioModeChange') folioListMode: string = 'all'
  @StorageLink('folioAtlasFilter') @Watch('onAtlasLink') folioAtlasFilter: string = 'all'
  @StorageLink('themeRevision') themeRevision: number = 0
  @State favoriteIds: string[] = []
  @State readToday: boolean = false
  private chips: FolioFilterChip[] = [
    new FolioFilterChip('all', '全部'),
    new FolioFilterChip('历史', '历史'),
    new FolioFilterChip('科学', '科学'),
    new FolioFilterChip('文化', '文化'),
    new FolioFilterChip('哲学', '哲学'),
    new FolioFilterChip('艺术', '艺术')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onFolioModeChange(): void {
    if (this.folioListMode.length > 0) {
      this.listMode = this.folioListMode
    }
    void this.reload()
  }

  onAtlasLink(): void {
    if (this.folioAtlasFilter.length > 0) {
      this.atlasFilter = this.folioAtlasFilter
    }
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.favoriteIds = await GewuStore.favoriteIds()
    this.readToday = await GewuStore.isReadToday()
    let pool = KnowledgeCatalog.search(this.keyword)
    const out: KnowledgeObject[] = []

    if (this.listMode === 'all') {
      for (const item of pool) {
        if (this.categoryFilter === 'all' || item.category === this.categoryFilter) {
          out.push(item)
        }
      }
    } else if (this.listMode === 'favorite') {
      for (const id of this.favoriteIds) {
        const obj = KnowledgeCatalog.resolveById(id)
        if (obj !== undefined) {
          if (this.categoryFilter === 'all' || obj.category === this.categoryFilter) {
            if (this.keyword.length === 0 || obj.title.indexOf(this.keyword) >= 0) {
              out.push(obj)
            }
          }
        }
      }
    } else if (this.listMode === 'recent') {
      const ids = await FieldStore.browseIds()
      for (const id of ids) {
        const obj = KnowledgeCatalog.resolveById(id)
        if (obj !== undefined) {
          if (this.categoryFilter === 'all' || obj.category === this.categoryFilter) {
            if (this.keyword.length === 0 || obj.title.indexOf(this.keyword) >= 0 ||
              obj.summary.indexOf(this.keyword) >= 0) {
              out.push(obj)
            }
          }
        }
      }
    } else if (this.listMode === 'notes') {
      const noteIds = await GewuStore.journalObjectIds()
      for (const id of noteIds) {
        const obj = KnowledgeCatalog.resolveById(id)
        if (obj !== undefined) {
          if (this.categoryFilter === 'all' || obj.category === this.categoryFilter) {
            if (this.keyword.length === 0 || obj.title.indexOf(this.keyword) >= 0 ||
              obj.summary.indexOf(this.keyword) >= 0) {
              out.push(obj)
            }
          }
        }
      }
    } else if (this.listMode === 'album') {
      const kinds = AlbumKind.all()
      const ids: string[] = []
      for (const k of kinds) {
        if (this.albumFilter.length > 0 && k !== this.albumFilter) {
          continue
        }
        const part = await FieldStore.objectsInAlbum(k)
        for (const id of part) {
          if (ids.indexOf(id) < 0) {
            ids.push(id)
          }
        }
      }
      for (const id of ids) {
        const obj = KnowledgeCatalog.resolveById(id)
        if (obj !== undefined) {
          if (this.categoryFilter === 'all' || obj.category === this.categoryFilter) {
            if (this.keyword.length === 0 || obj.title.indexOf(this.keyword) >= 0 ||
              obj.summary.indexOf(this.keyword) >= 0) {
              out.push(obj)
            }
          }
        }
      }
    } else {
      const deepenIds = await GewuStore.deepenIds()
      for (const id of deepenIds) {
        const obj = KnowledgeCatalog.resolveById(id)
        if (obj !== undefined) {
          if (this.categoryFilter === 'all' || obj.category === this.categoryFilter) {
            if (this.keyword.length === 0 || obj.title.indexOf(this.keyword) >= 0 ||
              obj.summary.indexOf(this.keyword) >= 0) {
              out.push(obj)
            }
          }
        }
      }
    }
    const atlasOut: KnowledgeObject[] = []
    for (const item of out) {
      if (this.atlasFilter === 'all' || item.atlasKind === this.atlasFilter) {
        atlasOut.push(item)
      }
    }
    this.items = atlasOut
  }

  private setMode(mode: string): void {
    this.listMode = mode
    AppStorage.setOrCreate('folioListMode', mode)
    void this.reload()
  }

  private setKeyword(v: string): void {
    this.keyword = v
    void this.reload()
  }

  private setCategory(cat: string): void {
    this.categoryFilter = cat
    void this.reload()
  }

  private setAtlas(kind: string): void {
    this.atlasFilter = kind
    AppStorage.setOrCreate('folioAtlasFilter', kind)
    void this.reload()
  }

  private setAlbum(album: string): void {
    this.albumFilter = this.albumFilter === album ? '' : album
    void this.reload()
  }

  private emptyTitle(): string {
    if (this.listMode === 'recent') {
      return '还没有浏览记录'
    }
    if (this.listMode === 'favorite') {
      return '还没有收藏'
    }
    if (this.listMode === 'deepen') {
      return '还没有想深究'
    }
    if (this.listMode === 'notes') {
      return '还没有札记'
    }
    if (this.listMode === 'album') {
      return '收藏夹还是空的'
    }
    return '没有匹配的知识物'
  }

  private emptyDesc(): string {
    if (this.listMode === 'recent') {
      return '打开任意图鉴详情后，最近看过的条目会出现在这里'
    }
    if (this.listMode === 'favorite') {
      return '在每日一格或详情页点击收藏，条目会出现在这里'
    }
    if (this.listMode === 'deepen') {
      return '在详情页标记「想深究」，可在此集中复习'
    }
    if (this.listMode === 'notes') {
      return '打开详情写下札记或格物三问后，会出现在这里'
    }
    if (this.listMode === 'album') {
      return '在详情页把条目放入古物/自然/生活/艺术/科普收藏夹'
    }
    return '试试更换门类、图鉴或清空搜索词'
  }

  @Builder
  ModeChip(label: string, mode: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.listMode === mode ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
      .backgroundColor(this.listMode === mode ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setMode(mode) })
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: Theme.space.s1 }) {
            Text('格物图鉴')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('五类知识物 · 格物学习起点（非空白记事本）')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          Image(GewuMedia.coverResource('banner_scroll'))
            .width('100%')
            .height(88)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)

          TextInput({ text: this.keyword, placeholder: '按名称、门类、图鉴或标签搜索' })
            .width('100%')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .placeholderColor(Theme.colors().textTertiary)
            .caretColor(Theme.colors().brandPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.md)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .onChange((v: string) => { this.setKeyword(v) })

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              this.ModeChip('全部', 'all')
              this.ModeChip('最近看过', 'recent')
              this.ModeChip('收藏', 'favorite')
              this.ModeChip('收藏夹', 'album')
              this.ModeChip('想深究', 'deepen')
              this.ModeChip('札记', 'notes')
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.chips, (c: FolioFilterChip) => {
                Text(c.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.categoryFilter === c.key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.categoryFilter === c.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.setCategory(c.key) })
              }, (c: FolioFilterChip) => c.key)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              Text('全部图鉴')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.atlasFilter === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.atlasFilter === 'all' ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.setAtlas('all') })
              ForEach(AtlasKind.all(), (k: string) => {
                Text(k)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.atlasFilter === k ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.atlasFilter === k ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.setAtlas(k) })
              }, (k: string) => k)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.listMode === 'album') {
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(AlbumKind.all(), (a: string) => {
                  Text(a)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.albumFilter === a ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.albumFilter === a ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => { this.setAlbum(a) })
                }, (a: string) => a)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          if (this.items.length === 0) {
            AppEmpty({
              title: this.emptyTitle(),
              description: this.emptyDesc(),
              actionLabel: '',
              onAction: (): void => {}
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (item: KnowledgeObject) => {
                KnowledgeListCard({
                  item: item,
                  readBadge: this.readToday && item.id === KnowledgeCatalog.todayObject().id ? '已读' : '',
                  onTap: (): void => { GewuDetailNav.open(item.id) }
                })
              }, (item: KnowledgeObject) => item.id)
            }
            .width('100%')
          }

          Row().height(this.bottomInset)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.folioBg())
  }

  private folioBg(): string {
    if (this.themeRevision < 0) {
      return Theme.colors().surfacePage
    }
    return Theme.colors().surfacePage
  }
}
