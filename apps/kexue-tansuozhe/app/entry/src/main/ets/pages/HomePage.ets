import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { LayoutConstants } from '../components/design-system/LayoutConstants'
import { SectionHeader } from '../components/explore/SectionHeader'
import { ExploreListCard } from '../components/explore/ExploreListCard'
import { AtlasCatalog, AtlasItem } from '../data/AtlasCatalog'
import { UserDiscovery } from '../models/ExplorationModels'
import { DomainStat } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'
import { CategoryEmojiUtil } from '../utils/CategoryEmojiUtil'

class MetricChip {
  label: string = ''
  value: string = ''
}

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('progressRev') @Watch('onProgress') progressRev: number = 0
  @StorageLink('explorerLevel') level: number = 1
  @StorageLink('explorerLevelTitle') levelTitle: string = ''
  @StorageLink('exploreCount') exploreCount: number = 0
  @StorageLink('discoveryCount') discoveryCount: number = 0
  @StorageLink('favoriteCount') favoriteCount: number = 0
  @StorageLink('streakDays') streakDays: number = 0
  @StorageLink('taskDoneToday') taskDone: number = 0
  @StorageLink('taskTotalToday') taskTotal: number = 3
  @State daily: AtlasItem = new AtlasItem()
  @State tips: string[] = []
  @State lookback: string = ''
  @State recent: UserDiscovery[] = []
  @State domains: DomainStat[] = []
  @State metrics: MetricChip[] = []
  private readonly scrollBottom: number = Theme.space.s10 + LayoutConstants.tabBarInset()

  aboutToAppear(): void {
    this.reload()
  }

  onProgress(): void {
    this.reload()
  }

  private reload(): void {
    this.daily = ExplorationStore.dailyAtlas()
    this.tips = ExplorationStore.wisdomTips()
    this.lookback = ExplorationStore.lookbackHint()
    this.recent = ExplorationStore.recentDiscoveries(5)
    this.domains = ExplorationStore.domainStats()
    const chips: MetricChip[] = []
    const m1 = new MetricChip()
    m1.label = '📖 图鉴'
    m1.value = `${this.exploreCount}`
    chips.push(m1)
    const m2 = new MetricChip()
    m2.label = '🔥 连续'
    m2.value = `${this.streakDays}天`
    chips.push(m2)
    const m3 = new MetricChip()
    m3.label = '✅ 任务'
    m3.value = `${this.taskDone}/${this.taskTotal}`
    chips.push(m3)
    const m4 = new MetricChip()
    m4.label = '⭐ 收藏'
    m4.value = `${this.favoriteCount}`
    chips.push(m4)
    this.metrics = chips
  }

  build() {
    Scroll() {
      Column({ space: 0 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_explore'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(240)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0.06)', 0], ['rgba(8,28,21,0.88)', 1.0]]
            })
          Column({ space: Theme.space.s3 }) {
            Row() {
              Column({ space: 4 }) {
                Text('元素探索者')
                  .fontSize(Theme.type.titleL)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('世界很大，也藏在每天经过的地方')
                  .fontSize(Theme.type.footnote)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Row({ space: 6 }) {
                AppIcon({ name: 'search', iconSize: Theme.icon.md, color: '#FFFFFF' })
              }
              .padding(10)
              .backgroundColor('rgba(255,255,255,0.16)')
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { ExploreNav.openSearch() })
            }
            .width('100%')
            Text(`${CategoryEmojiUtil.markFor(this.daily.category)} 今日 · ${this.daily.name}`)
              .fontSize(Theme.type.subhead)
              .fontColor('#FFFFFF')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
            AppButton({
              label: '开始探索',
              onTap: (): void => {
                ExploreNav.openAtlasDetail(this.daily.id)
                void ExplorationStore.completeTask('task_browse3').then((): void => {
                  ExploreToast.show('已开启今日探索')
                })
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s6
          })
          .alignItems(HorizontalAlign.Start)
          .width('100%')
        }
        .width('100%')

        Column({ space: Theme.space.section }) {
          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.metrics, (m: MetricChip) => {
                Column({ space: 4 }) {
                  Text(m.value)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(m.label)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .padding({
                  left: Theme.space.s4,
                  right: Theme.space.s4,
                  top: Theme.space.s3,
                  bottom: Theme.space.s3
                })
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (m: MetricChip) => `${m.label}_${m.value}_${this.progressRev}`)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Row({ space: Theme.space.s3 }) {
            this.ActionPill('新建发现', (): void => { ExploreNav.openNewRecord() })
            this.ActionPill('图鉴', (): void => { ExploreNav.switchTab(2) })
            this.ActionPill('7日挑战', (): void => { ExploreNav.openChallenge() })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: Theme.space.s3 }) {
            SectionHeader({
              title: '最近发现',
              subtitle: '你的观察与记录',
              actionLabel: this.recent.length > 0 ? '全部 ›' : '',
              onAction: (): void => { ExploreNav.switchTab(3) }
            })
            if (this.recent.length === 0) {
              Column({ space: Theme.space.s3 }) {
                Text('🌱 还没有记录')
                  .fontSize(Theme.type.subhead)
                  .fontColor(Theme.colors().textPrimary)
                Text('从今天注意到的一件小事开始')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                AppButton({
                  label: '开始第一次探索',
                  onTap: (): void => { ExploreNav.openNewRecord() }
                })
              }
              .width('100%')
              .padding(Theme.space.s5)
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
            } else {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.recent.slice(0, 3), (d: UserDiscovery) => {
                  ExploreListCard({
                    title: d.title,
                    summary: d.description,
                    category: d.category,
                    coverKey: d.atlasRefId,
                    badge: d.isSample ? '示例' : '',
                    meta: `${CategoryEmojiUtil.chipLabel(d.category)} · ${d.dateKey}`,
                    onTap: (): void => { ExploreNav.openRecordDetail(d.id) }
                  })
                }, (d: UserDiscovery) => `${d.id}_${d.updatedAt}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
          }

          Column({ space: Theme.space.s3 }) {
            SectionHeader({
              title: '探索领域',
              subtitle: '五大领域点亮进度',
              actionLabel: '地图 ›',
              onAction: (): void => { ExploreNav.openDomainMap() }
            })
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.domains, (d: DomainStat) => {
                  Column({ space: 6 }) {
                    Text(CategoryEmojiUtil.chipLabel(d.category))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textPrimary)
                    Text(`${d.count}/${d.total}`)
                      .fontSize(Theme.type.title3)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(d.count > 0 ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
                  }
                  .padding(Theme.space.s4)
                  .backgroundColor(d.count > 0 ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.xl)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                  .onClick((): void => { ExploreNav.openDomainMap() })
                }, (d: DomainStat) => `${d.category}_${d.count}`)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }

          if (this.lookback.length > 0) {
            Column({ space: Theme.space.s3 }) {
              SectionHeader({ title: '探索回顾', subtitle: '温习过往发现' })
              Text(this.lookback)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
                .padding(Theme.space.s5)
                .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
            }
          }

          if (this.tips.length > 0) {
            Column({ space: Theme.space.s3 }) {
              SectionHeader({ title: '智慧探索', subtitle: '基于你的记录推荐' })
              Stack({ alignContent: Alignment.BottomStart }) {
                Image($r('app.media.ambient_nature'))
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.xl)
                Column()
                  .width('100%')
                  .height(120)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(8,28,21,0.08)', 0], ['rgba(8,28,21,0.72)', 1.0]]
                  })
                  .borderRadius(Theme.radius.xl)
                Text(`💡 ${this.tips[0]}`)
                  .fontSize(Theme.type.body)
                  .fontColor('#FFFFFF')
                  .lineHeight(22)
                  .width('100%')
                  .padding(Theme.space.s5)
              }
              .width('100%')
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
          }
        }
        .width('100%')
        .padding({ top: Theme.space.section, bottom: this.scrollBottom })
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }

  @Builder
  ActionPill(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontColor(Theme.colors().brandPrimary)
      .padding({ left: 14, right: 14, top: 10, bottom: 10 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .onClick((): void => { onTap() })
  }
}
