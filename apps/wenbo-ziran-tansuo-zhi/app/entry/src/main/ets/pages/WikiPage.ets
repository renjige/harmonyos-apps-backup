import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { WikiGridCard } from '../components/nq/WikiGridCard'
import { TipItem, WikiItem } from '../models/NqModels'
import { NqBizService } from '../services/NqBizService'
import { NqDetailNav } from '../services/NqDetailNav'

class WikiCatChip {
  label: string = ''
  value: string = ''

  constructor(label: string, value: string) {
    this.label = label
    this.value = value
  }
}

@Component
export struct WikiPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshToken') refreshToken: number = 0
  @State category: string = ''
  @State query: string = ''
  @State articles: WikiItem[] = []
  @State tips: TipItem[] = []
  @State shownWiki: WikiItem[] = []
  @State shownTips: TipItem[] = []
  @State loading: boolean = true
  private categories: WikiCatChip[] = [
    new WikiCatChip('全部', ''),
    new WikiCatChip('植物', '植物'),
    new WikiCatChip('动物', '动物'),
    new WikiCatChip('地质', '地质'),
    new WikiCatChip('天文', '天文'),
    new WikiCatChip('户外技巧', 'skill')
  ]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshToken(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.articles = await NqBizService.loadArticles('')
    this.tips = await NqBizService.loadTips()
    this.applyFilter()
    this.loading = false
  }

  private applyFilter(): void {
    const key = this.query.trim()
    if (this.category === 'skill') {
      this.shownWiki = []
      let tipList = this.tips
      if (key.length > 0) {
        tipList = NqBizService.searchTips(this.tips, key)
      }
      this.shownTips = tipList
      return
    }
    this.shownTips = []
    const out: WikiItem[] = []
    let source = this.articles
    if (key.length > 0) {
      source = NqBizService.searchWiki(this.articles, key)
    }
    for (const w of source) {
      if (this.category.length > 0 && w.category !== this.category) {
        continue
      }
      out.push(w)
    }
    this.shownWiki = out
  }

  private setCategory(next: string): void {
    this.category = next
    this.applyFilter()
  }

  build() {
    Column() {
      AppHeader({ title: '自然百科', subtitle: '植物、地质与户外技巧' })

      Row({ space: Theme.space.s2 }) {
        AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
        TextInput({ text: this.query, placeholder: '搜索百科或技巧' })
          .layoutWeight(1)
          .onChange((v: string) => {
            this.query = v
            this.applyFilter()
          })
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.categories, (c: WikiCatChip) => {
            Text(c.label)
              .fontSize(Theme.type.footnote)
              .fontColor(this.category === c.value ?
                Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.category === c.value ?
                Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick(() => this.setCategory(c.value))
          }, (c: WikiCatChip) => c.value)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

      if (this.loading) {
        Scroll() {
          Column() {
            AppLoading({ label: '打开百科' })
          }
          .width('100%')
          .padding({ top: Theme.space.s6, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (this.category === 'skill' && this.shownTips.length === 0) {
        Scroll() {
          Column() {
            AppEmpty({
              title: '暂无户外技巧',
              description: '换一个标签或稍后刷新。',
              actionLabel: '重新加载',
              onAction: (): void => { void this.reload() }
            })
          }
          .width('100%')
          .padding({ top: Theme.space.s3, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else if (this.category !== 'skill' && this.shownWiki.length === 0) {
        Scroll() {
          Column() {
            AppEmpty({
              title: '这一类还没有条目',
              description: '换一个标签，或稍后刷新。',
              actionLabel: '重新加载',
              onAction: (): void => { void this.reload() }
            })
          }
          .width('100%')
          .padding({ top: Theme.space.s3, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      } else {
        Scroll() {
          if (this.category === 'skill') {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.shownTips, (t: TipItem) => {
                Row({ space: Theme.space.s3 }) {
                  Column({ space: 4 }) {
                    Text(t.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(t.summary)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .maxLines(2)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => NqDetailNav.openTip(t.id))
              }, (t: TipItem) => t.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          } else {
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.shownWiki, (w: WikiItem) => {
                WikiGridCard({
                  item: w,
                  onTap: (): void => NqDetailNav.openWiki(w.id)
                })
                  .width('48%')
                  .margin({ bottom: Theme.space.s3 })
              }, (w: WikiItem) => w.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s3,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
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
