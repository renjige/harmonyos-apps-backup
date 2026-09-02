import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ExcerptItem, KnowledgeFolio } from '../models/FolioModels'
import { FolioStore } from '../services/FolioStore'
import { FolioGridCard } from '../components/read/ListCards'

@Component
export struct FolioListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReload') reloadToken: number = 0
  @StorageLink('folioEpoch') @Watch('onEpoch') folioEpoch: number = 0
  @State items: KnowledgeFolio[] = []
  @State query: string = ''
  @State counts: string[] = []
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onCreate: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onReload(): void {
    void this.load()
  }

  onEpoch(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await FolioStore.searchFolios(this.query)
    this.items = list
    const labels: string[] = []
    for (const it of list) {
      const ex: ExcerptItem[] = await FolioStore.excerptsOfFolio(it.id)
      labels.push(`${ex.length} 条摘录`)
    }
    this.counts = labels
  }

  private countAt(index: number): string {
    if (index >= 0 && index < this.counts.length) {
      return this.counts[index]
    }
    return ''
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Column({ space: 2 }) {
          Text('知识册')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('按主题整理摘录')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Row() {
          AppIcon({ name: 'add', iconSize: 20, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(22)
        .onClick((): void => { this.onCreate() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Row({ space: 8 }) {
        AppIcon({ name: 'search', iconSize: 18, color: Theme.colors().textTertiary })
        TextInput({ text: this.query, placeholder: '搜索知识册' })
          .onChange((v: string) => {
            this.query = v
            void this.load()
          })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .height(48)
      .padding({ left: 12, right: 12 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 8 })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.pill)

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有知识册',
          description: '先建一本主题册，再把摘录收入其中',
          actionLabel: '新建知识册',
          onAction: (): void => { this.onCreate() }
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.items, (it: KnowledgeFolio, idx: number) => {
              Column() {
                FolioGridCard({
                  title: it.title,
                  summary: it.summary,
                  coverKey: it.coverKey,
                  countLabel: this.countAt(idx),
                  onTap: (): void => { this.onOpenDetail(it.id) }
                })
              }
              .width('48%')
              .margin({ bottom: 10, right: '2%' })
            }, (it: KnowledgeFolio) => it.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
