import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { MemoryListCard } from '../components/memory/MemoryListCard'
import { MemoryRecord } from '../models/MemoryModels'
import { MemoryStore } from '../services/MemoryStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State items: MemoryRecord[] = []
  @State showSearch: boolean = false
  @State query: string = ''
  @State filter: string = 'all'
  onOpenWrite: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    if (this.query.trim().length > 0) {
      this.items = await MemoryStore.search(this.query)
      return
    }
    if (this.filter === 'fav') {
      this.items = await MemoryStore.loadFavorites()
      return
    }
    if (this.filter === 'pin') {
      this.items = await MemoryStore.loadPinned()
      return
    }
    if (this.filter === 'due') {
      this.items = await MemoryStore.loadDueReview()
      return
    }
    if (this.filter === 'arch') {
      this.items = await MemoryStore.loadArchived()
      return
    }
    this.items = await MemoryStore.loadActive()
  }

  private setFilter(key: string): void {
    this.filter = key
    void this.load()
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('慧忆册')
            .fontSize(Theme.type.titleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'search', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.showSearch = !this.showSearch })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s3,
          bottom: Theme.space.s2
        })

        if (this.showSearch) {
          TextInput({ text: this.query, placeholder: '搜索记忆内容或标签' })
            .width('100%')
            .height(44)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
            .padding({ left: 14, right: 14 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.pill)
            .onChange((v: string): void => {
              this.query = v
              void this.load()
            })
        }

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.FilterChip('全部', 'all')
            this.FilterChip('收藏', 'fav')
            this.FilterChip('置顶', 'pin')
            this.FilterChip('待温习', 'due')
            this.FilterChip('归档', 'arch')
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(44)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_notebook'))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Text('智慧记忆管家')
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                  Text('记下此刻，收入册子，按日温习')
                    .fontSize(Theme.type.bodyS)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(11,42,92,0.78)', 1]]
                })
              }
              .width('100%')
              .height(168)
            }
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.md)
            .clip(true)

            if (this.items.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Image($r('app.media.empty_desk'))
                  .width('100%')
                  .height(140)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
                AppEmpty({
                  title: this.emptyTitle(),
                  description: this.emptyDesc(),
                  actionLabel: '新建记忆',
                  onAction: (): void => { this.onOpenWrite() }
                })
              }
              .width('100%')
            } else {
              ForEach(this.items, (it: MemoryRecord) => {
                MemoryListCard({
                  item: it,
                  onOpen: (): void => { this.onOpenDetail(it.id) }
                })
              }, (it: MemoryRecord) => it.id)
            }
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.xl, color: '#FFFFFF' })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .borderRadius(Theme.radius.pill)
      .backgroundColor(Theme.colors().brandPrimary)
      .shadow({ radius: 16, color: 'rgba(26,109,245,0.35)', offsetX: 0, offsetY: 6 })
      .position({ x: '78%', y: '82%' })
      .onClick((): void => { this.onOpenWrite() })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FilterChip(label: string, key: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.filter === key ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .constraintSize({ minHeight: 36 })
      .backgroundColor(this.filter === key ?
        Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.setFilter(key) })
  }

  private emptyTitle(): string {
    if (this.filter === 'fav') {
      return '还没有收藏'
    }
    if (this.filter === 'pin') {
      return '还没有置顶'
    }
    if (this.filter === 'due') {
      return '暂无待温习'
    }
    if (this.filter === 'arch') {
      return '归档是空的'
    }
    return '还没有记忆'
  }

  private emptyDesc(): string {
    if (this.filter === 'all') {
      return '点右下角 ＋，或用模板写下第一条'
    }
    return '换一个筛选，或去详情页做收藏 / 置顶 / 温习'
  }
}
