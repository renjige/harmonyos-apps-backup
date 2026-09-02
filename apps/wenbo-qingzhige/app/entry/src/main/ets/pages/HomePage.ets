import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { KnowledgeListCard } from '../components/knowledge/KnowledgeListCard'
import { CatalogItem, KnowledgeItem } from '../models/KnowledgeModels'
import { KnowledgeStore } from '../services/KnowledgeStore'
import { KnowledgeBizService } from '../services/KnowledgeBizService'
import { KnowledgeNav } from '../services/KnowledgeNav'
import { KnowledgeTime } from '../services/CategorySuggest'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '轻知阁'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State today: KnowledgeItem = new KnowledgeItem()
  @State favs: KnowledgeItem[] = []
  @State recents: KnowledgeItem[] = []
  @State reviewLeft: number = 0
  @State hasToday: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const featured = await KnowledgeBizService.loadFeatured()
    this.today = this.pickToday(featured)
    this.hasToday = this.today.id.length > 0
    this.favs = KnowledgeStore.recentFavorites(2)
    this.recents = KnowledgeStore.recentUser(2)
    this.reviewLeft = KnowledgeStore.reviewQueue().length
  }

  private pickToday(list: CatalogItem[]): KnowledgeItem {
    const local = KnowledgeStore.sorted()
    if (list.length > 0) {
      const idx = KnowledgeTime.dayOfYear() % list.length
      const cat = list[idx]
      const existing = KnowledgeStore.find(cat.id)
      if (existing !== undefined) {
        return existing
      }
      const n = new KnowledgeItem()
      n.id = cat.id
      n.title = cat.title
      n.body = cat.body
      n.category = cat.category
      n.tags = cat.tags
      n.coverKey = cat.coverKey
      n.source = 'featured'
      return n
    }
    if (local.length > 0) {
      const idx = KnowledgeTime.dayOfYear() % local.length
      return local[idx]
    }
    return new KnowledgeItem()
  }

  private async favoriteToday(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    let item = KnowledgeStore.find(this.today.id)
    if (item === undefined) {
      this.today.source = 'featured'
      this.today.createdAt = Date.now()
      this.today.updatedAt = Date.now()
      await KnowledgeStore.save(this.today)
    }
    await KnowledgeStore.toggleFavorite(this.today.id)
    void this.reload()
  }

  private async markRead(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    if (KnowledgeStore.find(this.today.id) === undefined) {
      this.today.createdAt = Date.now()
      this.today.updatedAt = Date.now()
      await KnowledgeStore.save(this.today)
    }
    await KnowledgeStore.markRead(this.today.id)
    void this.reload()
  }

  private openToday(): void {
    if (!this.hasToday) {
      return
    }
    if (KnowledgeStore.find(this.today.id) === undefined) {
      this.today.createdAt = Date.now()
      this.today.updatedAt = Date.now()
      void KnowledgeStore.save(this.today).then(() => {
        KnowledgeNav.openDetail(this.today.id)
      })
      return
    }
    KnowledgeNav.openDetail(this.today.id)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Row() {
          Text(this.appName)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { KnowledgeNav.openSearch() })
        }
        .width('100%')

        Text('今天，也学一点新的东西')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.hasToday) {
          Column({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_today_page'))
                .width('100%')
                .height(210)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(210)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(18,42,54,0)', 0.28], ['rgba(18,42,54,0.74)', 1]]
                })
              Column({ space: 6 }) {
                Text('今日轻知')
                  .fontSize(Theme.type.caption)
                  .fontColor('#F6F1EA')
                Text(this.today.category.length > 0 ? this.today.category : '生活小知')
                  .fontSize(Theme.type.caption)
                  .fontColor('#D4A574')
                Text(this.today.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F6F1EA')
                  .maxLines(2)
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .onClick((): void => { this.openToday() })

            Text(this.today.summaryLine())
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')

            Row({ space: Theme.space.s2 }) {
              this.MiniAction(this.today.favorited ? '已收藏' : '收藏', (): void => { void this.favoriteToday() })
              this.MiniAction('已读', (): void => { void this.markRead() })
              this.MiniAction('继续阅读', (): void => { this.openToday() })
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
        }

        this.SectionHead('最近收藏', (): void => { KnowledgeNav.openFavorites() })
        if (this.favs.length === 0) {
          AppEmpty({ title: '喜欢的轻知，会在这里留下。', description: '' })
        } else {
          ForEach(this.favs, (item: KnowledgeItem) => {
            KnowledgeListCard({
              itemId: item.id,
              title: item.title,
              summary: item.summaryLine(),
              category: item.category,
              tags: item.tags,
              coverKey: item.coverKey,
              updatedAt: item.updatedAt,
              favorited: item.favorited,
              onOpen: (): void => { KnowledgeNav.openDetail(item.id) }
            })
          }, (item: KnowledgeItem) => `f-${item.id}`)
        }

        this.SectionHead('最近记录', (): void => { KnowledgeNav.switchTab(1) })
        if (this.recents.length === 0) {
          AppEmpty({ title: '把刚想到的事情，轻轻记下来。', description: '' })
        } else {
          ForEach(this.recents, (item: KnowledgeItem) => {
            KnowledgeListCard({
              itemId: item.id,
              title: item.title,
              summary: item.summaryLine(),
              category: item.category,
              tags: item.tags,
              coverKey: item.coverKey,
              updatedAt: item.updatedAt,
              favorited: item.favorited,
              onOpen: (): void => { KnowledgeNav.openDetail(item.id) }
            })
          }, (item: KnowledgeItem) => `r-${item.id}`)
        }

        this.SectionHead('今日复习', (): void => { KnowledgeNav.switchTab(2) })
        Text(this.reviewLeft > 0 ? `今天还有 ${this.reviewLeft} 条值得再看` : '今天的轻知已经看完了。')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  SectionHead(title: string, onMore: () => void) {
    Row() {
      Text(title)
        .fontSize(Theme.type.subtitleL)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Blank()
      Text('查看')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .onClick((): void => { onMore() })
    }
    .width('100%')
  }

  @Builder
  MiniAction(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.sm)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => { onTap() })
  }
}
