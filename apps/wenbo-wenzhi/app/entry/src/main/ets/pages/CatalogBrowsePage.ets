import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { InsightItem } from '../models/AskModels'
import { LearnCatalog } from '../models/LearnModels'
import { AskBizService } from '../services/AskBizService'
import { AskMedia } from '../services/AskMedia'
import { AskNav } from '../services/AskNav'

@Component
export struct CatalogBrowsePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop mode: string = 'catalog'
  @State keyword: string = ''
  @State category: string = '全部'
  @State topic: string = '全部'
  @State items: InsightItem[] = []
  @State all: InsightItem[] = []
  private cats: string[] = LearnCatalog.categories()
  private topics: string[] = ['全部', '历史专题', '科学专题', '生活技巧专题', '文化专题']

  aboutToAppear(): void {
    const kw = AppStorage.get<string>('catalogKeyword') ?? ''
    if (kw.length > 0) {
      this.keyword = kw
      AppStorage.setOrCreate('catalogKeyword', '')
    }
    const cat = AppStorage.get<string>('catalogCategory') ?? ''
    if (cat.length > 0) {
      this.category = cat
      AppStorage.setOrCreate('catalogCategory', '')
    }
    const top = AppStorage.get<string>('catalogTopic') ?? ''
    if (top.length > 0) {
      this.topic = top
      AppStorage.setOrCreate('catalogTopic', '')
    }
    void this.load()
  }

  private async load(): Promise<void> {
    this.all = await AskBizService.loadInsights()
    this.applyFilter()
  }

  private applyFilter(): void {
    let list = AskBizService.filterCategory(this.all, this.category)
    if (this.mode === 'topics' || this.topic !== '全部') {
      list = AskBizService.filterTopic(list, this.topic === '全部' ? '' : this.topic)
    }
    const k = this.keyword.trim()
    if (k.length > 0) {
      list = AskBizService.rank(list, k)
    }
    this.items = list
  }

  build() {
    Column() {
      AppNavBar({
        title: this.mode === 'topics' ? '专题知识库' : '知识检索',
        onBack: (): void => { AskNav.closeLearn() }
      })
      TextInput({ text: this.keyword, placeholder: '搜索问题、关键词或分类' })
        .height(48)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .fontSize(Theme.type.body)
        .placeholderColor(Theme.colors().textTertiary)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.sm)
        .onChange((v: string) => {
          this.keyword = v
          this.applyFilter()
        })
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.mode === 'topics' ? this.topics : this.cats, (f: string) => {
            Text(f)
              .fontSize(Theme.type.footnote)
              .fontColor(this.chipOn(f) ? Theme.colors().brandOnPrimary :
                (this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary))
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .constraintSize({ minHeight: 40 })
              .backgroundColor(this.chipOn(f) ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                if (this.mode === 'topics') {
                  this.topic = f
                } else {
                  this.category = f
                }
                this.applyFilter()
              })
          }, (f: string) => f)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (this.items.length === 0) {
        AppEmpty({
          title: '没有匹配的知识',
          description: '换个关键词或分类再试',
          actionLabel: '重置',
          onAction: (): void => {
            this.keyword = ''
            this.category = '全部'
            this.topic = '全部'
            this.applyFilter()
          }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.items, (n: InsightItem) => {
            ListItem() {
              Row({ space: Theme.space.s3 }) {
                Image(AskMedia.resource(n.coverKey))
                  .width(72)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.sm)
                Column({ space: 4 }) {
                  Text(n.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                    .width('100%')
                  Text(`${n.category} · ${n.topic.length > 0 ? n.topic : '通识'}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  Text(n.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick(() => { AskNav.openDetail('insight', n.id) })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s3
            })
          }, (n: InsightItem) => n.id)
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private chipOn(f: string): boolean {
    if (this.mode === 'topics') {
      return this.topic === f
    }
    return this.category === f
  }
}
