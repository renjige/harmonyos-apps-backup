import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ExcerptItem } from '../models/FolioModels'
import { FolioStore } from '../services/FolioStore'
import { FolioMedia } from '../services/FolioMedia'
import { ExcerptListCard } from '../components/read/ListCards'

@Component
export struct ExcerptListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onReload') reloadToken: number = 0
  @StorageLink('folioEpoch') @Watch('onEpoch') folioEpoch: number = 0
  @State items: ExcerptItem[] = []
  @State query: string = ''
  onOpenDetail: (id: string) => void = (_id: string) => {}
  onWrite: () => void = () => {}
  onRandom: () => void = () => {}

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
    this.items = await FolioStore.searchExcerpts(this.query)
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Column({ space: 2 }) {
          Text('摘录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('从文稿沉淀下来的句子')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Row() {
          AppIcon({ name: 'sparkle', iconSize: 20, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimaryContainer)
        .borderRadius(22)
        .onClick((): void => { this.onRandom() })
        Row() {
          AppIcon({ name: 'add', iconSize: 20, color: Theme.colors().brandOnPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(22)
        .onClick((): void => { this.onWrite() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

      Row({ space: 8 }) {
        AppIcon({ name: 'search', iconSize: 18, color: Theme.colors().textTertiary })
        TextInput({ text: this.query, placeholder: '搜索摘录或感想' })
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

      Image(FolioMedia.cover('banner_progress'))
        .width('100%')
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .onClick((): void => { this.onRandom() })

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有摘录',
          description: '阅读时复制原文，再点右上角写入摘录',
          actionLabel: '手动写一条',
          onAction: (): void => { this.onWrite() }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (it: ExcerptItem) => {
            ListItem() {
              ExcerptListCard({
                quote: it.text,
                meta: `${it.tagLine()} · ${FolioStore.timeLabel(it.createdAt)}`,
                favorite: it.isFavorite,
                onTap: (): void => { this.onOpenDetail(it.id) }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 10 })
          }, (it: ExcerptItem) => `${it.id}-${it.isFavorite ? '1' : '0'}`)
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
