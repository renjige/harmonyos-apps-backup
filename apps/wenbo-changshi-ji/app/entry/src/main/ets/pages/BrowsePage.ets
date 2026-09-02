import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { CategoryChip, FactItem } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseMedia } from '../services/CommonSenseMedia'

@Component
export struct BrowsePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State facts: FactItem[] = []
  @State filtered: FactItem[] = []
  @State keyword: string = ''
  @State category: string = 'all'
  @State gridMode: boolean = true
  @State hotTags: string[] = []
  @State loading: boolean = true
  private chips: CategoryChip[] = CategoryChip.all()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      const local = await CommonSenseBizService.loadLocalFacts()
      if (local.length > 0) {
        this.facts = local
        this.hotTags = CommonSenseBizService.hotTags(local, 8)
        this.applyFilter()
        this.loading = false
      }
      const list = await CommonSenseBizService.loadFacts()
      this.facts = list
      this.hotTags = CommonSenseBizService.hotTags(list, 8)
      this.applyFilter()
    } catch {
    } finally {
      this.loading = false
    }
  }

  private applyFilter(): void {
    let rows = CommonSenseBizService.filterByCategory(this.facts, this.category)
    rows = CommonSenseBizService.search(rows, this.keyword)
    this.filtered = rows
  }

  private selectCategory(key: string): void {
    this.category = key
    this.applyFilter()
  }

  private selectTag(tag: string): void {
    this.keyword = tag
    this.applyFilter()
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        TextInput({ text: this.keyword, placeholder: '搜索标题、摘要或标签' })
          .layoutWeight(1)
          .height(40)
          .fontSize(Theme.type.subhead)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 16, right: 16 })
          .onChange((v: string): void => {
            this.keyword = v
            this.applyFilter()
          })
        Column() {
          AppIcon({
            name: this.gridMode ? 'list' : 'grid',
            iconSize: Theme.icon.md,
            color: Theme.colors().brandPrimary
          })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.gridMode = !this.gridMode })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.chips, (chip: CategoryChip) => {
            Text(chip.label)
              .fontSize(12)
              .fontColor(this.category === chip.key ?
                Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.category === chip.key ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.selectCategory(chip.key) })
          }, (chip: CategoryChip) => chip.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')

      if (this.hotTags.length > 0) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.hotTags, (tag: string) => {
              Text(`#${tag}`)
                .fontSize(11)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.selectTag(tag) })
            }, (tag: string) => tag)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      Image(CommonSenseMedia.resource('banner_explore'))
        .width('100%')
        .height(88)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.card)
        .margin({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2
        })

      if (this.loading) {
        Text('加载中…')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .padding(Theme.space.pageX)
      } else if (this.filtered.length === 0) {
        AppEmpty({
          title: '没有匹配的常识',
          description: '换个关键词或分类试试。',
          actionLabel: '查看全部',
          onAction: (): void => {
            this.keyword = ''
            this.category = 'all'
            this.applyFilter()
          }
        })
      } else if (this.gridMode) {
        Scroll() {
          GridRow({ columns: 2, gutter: 12 }) {
            ForEach(this.filtered, (row: FactItem) => {
              GridCol() {
                ContentCard({
                  item: row,
                  compact: true,
                  onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
                })
              }
            }, (row: FactItem) => row.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10,
            top: Theme.space.s2
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.filtered, (row: FactItem) => {
              ContentCard({
                item: row,
                compact: false,
                onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
              })
            }, (row: FactItem) => row.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10,
            top: Theme.space.s2
          })
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
