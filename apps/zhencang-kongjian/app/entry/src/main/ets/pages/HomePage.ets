import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppIcon } from '../components/design-system/AppIcon'
import { TreasureListCard } from '../components/treasure/TreasureListCard'
import { TreasureEmpty } from '../components/treasure/TreasureEmpty'
import { CollectionPlan, TreasureAlbum, TreasureItem } from '../models/TreasureModels'
import { ReviewService } from '../services/ReviewService'
import { TreasureNav } from '../services/TreasureNav'
import { TreasureStore } from '../services/TreasureStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @State total: number = 0
  @State albumCount: number = 0
  @State pendingCount: number = 0
  @State highlightCount: number = 0
  @State recent: TreasureItem[] = []
  @State albums: TreasureAlbum[] = []
  @State pending: TreasureItem[] = []
  @State reviewTitle: string = ''
  @State reviewBody: string = ''
  @State plans: CollectionPlan[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefresh(): void {
    this.reload()
  }

  private reload(): void {
    this.total = TreasureStore.activeItems().length
    this.albumCount = TreasureStore.albums().length
    this.pendingCount = TreasureStore.pendingItems().length
    this.highlightCount = TreasureStore.highlightCount()
    this.recent = TreasureStore.recentItems(5)
    this.albums = TreasureStore.albums()
    this.pending = TreasureStore.pendingItems()
    this.plans = TreasureStore.plans()
    const snip = ReviewService.todaySnippet()
    this.reviewTitle = snip.title
    this.reviewBody = snip.body
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column({ space: Theme.space.s2 }) {
          Text('珍藏空间')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Text('收藏的不只是物品，还有属于你的故事。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_archive'))
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.xl)
            .objectFit(ImageFit.Cover)
          Row({ space: Theme.space.s6 }) {
            Column({ space: 4 }) {
              Text('我的珍藏').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
              Text(`${this.total}`).fontSize(Theme.type.title1).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textOnInverse)
              Text('件').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
            }
            Column({ space: 4 }) {
              Text('主题收藏').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
              Text(`${this.albumCount}`).fontSize(Theme.type.title1).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textOnInverse)
              Text('个').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
            }
            Column({ space: 4 }) {
              Text('待整理').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
              Text(`${this.pendingCount}`).fontSize(Theme.type.title1).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textOnInverse)
              Text('件').fontSize(Theme.type.caption).fontColor(Theme.colors().textOnInverse)
            }
          }
          .width('100%')
          .padding(Theme.space.s5)
          .linearGradient({ angle: 180, colors: [['rgba(44,62,66,0.08)', 0], ['rgba(44,62,66,0.78)', 1]] })
          .borderRadius(Theme.radius.xl)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.QuickChip('新建珍藏', (): void => { TreasureNav.openEditor('') })
            this.QuickChip('创建主题', (): void => { TreasureNav.switchTab(2); TreasureNav.openSubPage('albumEditor') })
            this.QuickChip('收藏计划', (): void => { TreasureNav.openPlanList() })
            this.QuickChip('收藏清单', (): void => { TreasureNav.openWishList() })
            this.QuickChip('快速记录', (): void => { TreasureNav.openNoteEditor('') })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')

        if (this.total === 0) {
          TreasureEmpty({ onAction: (): void => { TreasureNav.openEditor('') } })
        } else {
          this.SectionHeader('最近入藏', '查看全部', (): void => { TreasureNav.switchTab(1) })
          if (this.recent.length === 0) {
            Text('暂无最近入藏').fontColor(Theme.colors().textSecondary).padding({ left: Theme.space.pageX })
          } else {
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.recent, (item: TreasureItem) => {
                  Column() {
                    TreasureListCard({ item: item, onTap: (): void => { TreasureNav.openDetail(item.id) } })
                  }.width(168)
                }, (item: TreasureItem) => item.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          this.SectionHeader('我的主题', '全部主题', (): void => { TreasureNav.switchTab(2) })
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.albums, (a: TreasureAlbum) => {
                Column({ space: Theme.space.s2 }) {
                  Text(a.name).fontSize(Theme.type.subhead).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary)
                  Text(`${a.itemIds.length} 件`).fontSize(Theme.type.caption).fontColor(Theme.colors().brandPrimary)
                }
                .padding(Theme.space.s4)
                .width(140)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { TreasureNav.openAlbumDetail(a.id) })
              }, (a: TreasureAlbum) => a.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.plans.length > 0) {
            this.SectionHeader('收藏计划', '全部计划', (): void => { TreasureNav.openPlanList() })
            ForEach(this.plans.slice(0, 2), (p: CollectionPlan) => {
              Row() {
                Column({ space: 4 }) {
                  Text(p.name).fontColor(Theme.colors().textPrimary)
                  Text(`${TreasureStore.planDoneCount(p)} / ${p.targetCount} · ${TreasureStore.planProgress(p)}%`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 8, bottom: 8 })
              .onClick((): void => { TreasureNav.openPlanEditor(p.id) })
            }, (p: CollectionPlan) => p.id)
          }

          if (this.pending.length > 0) {
            this.SectionHeader('待整理', '智慧整理', (): void => { TreasureNav.openSmartOrganize() })
            ForEach(this.pending.slice(0, 3), (item: TreasureItem) => {
              Row() {
                Text(item.name).layoutWeight(1).fontColor(Theme.colors().textPrimary)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 10, bottom: 10 })
              .onClick(() => TreasureNav.openEditor(item.id))
            }, (item: TreasureItem) => `p_${item.id}`)
          }

          AppCard({
            title: this.reviewTitle,
            content: (): void => { this.ReviewCardContent() }
          })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Row({ space: Theme.space.s3 }) {
            this.StatPill('珍藏', `${this.total}`)
            this.StatPill('主题', `${this.albumCount}`)
            this.StatPill('重点', `${this.highlightCount}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
      .padding({ bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  ReviewCardContent() {
    Column({ space: Theme.space.s3 }) {
      Image($r('app.media.empty_vault'))
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Contain)
        .opacity(0.92)
      Text(this.reviewBody).fontSize(Theme.type.body).fontColor(Theme.colors().textSecondary).lineHeight(22)
    }
  }

  @Builder
  QuickChip(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(Theme.colors().brandOnPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandDeep)
      .borderRadius(Theme.radius.pill)
      .onClick(onTap)
  }

  @Builder
  SectionHeader(title: string, action: string, onTap: () => void) {
    Row() {
      Text(title).fontSize(Theme.type.title3).fontWeight(FontWeight.Medium).fontColor(Theme.colors().textPrimary).layoutWeight(1)
      Text(action).fontSize(Theme.type.subhead).fontColor(Theme.colors().brandPrimary).onClick(onTap)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }

  @Builder
  StatPill(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value).fontSize(Theme.type.title3).fontWeight(FontWeight.Bold).fontColor(Theme.colors().textPrimary)
      Text(label).fontSize(Theme.type.caption).fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .alignItems(HorizontalAlign.Center)
  }
}
