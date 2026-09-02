import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppCard } from '../components/design-system/AppCard'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { ReviewMonthlyChart } from '../components/journal/ReviewMonthlyChart'
import { ReviewTimelineSection } from '../components/journal/ReviewTimelineSection'
import {
  AnnualStatsData,
  JournalItem,
  MonthStatItem,
  TagPresetItem,
  TopTagItem
} from '../models/JournalModels'
import { FootprintItem, JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { AuthService } from '../services/AuthService'
import { OrganizePage } from './OrganizePage'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onOpenTool: (name: string) => void = (_n: string) => {}
  @State stats: AnnualStatsData = new AnnualStatsData()
  @State monthStats: MonthStatItem[] = []
  @State timeline: JournalItem[] = []
  @State footprints: FootprintItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State searchQuery: string = ''
  @State searchDiaries: JournalItem[] = []
  @State searchFeatured: JournalItem[] = []
  @State loading: boolean = true
  @State showOrganize: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    if (this.refreshToken > 0) {
      void this.reload()
    }
  }

  private summaryText(): string {
    if (!AuthService.isLoggedIn()) {
      return '登录后可查看专属年度回顾：记录天数、配图统计与生活足迹。'
    }
    return `今年你已记录 ${this.stats.diaryCount} 篇札记、` +
      `${this.stats.writingDays} 个记录日、${this.stats.albumCount} 本相册、` +
      `${this.stats.imageCount} 张配图，收藏 ${this.stats.favoriteCount} 条美好瞬间。`
  }

  private async reload(): Promise<void> {
    this.loading = true
    const year = new Date().getFullYear()
    if (AuthService.isLoggedIn()) {
      this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
      const monthly = await JournalBizService.loadMonthlyStats(this.currentUsername, year)
      this.monthStats = monthly.months
      this.timeline = await JournalBizService.loadTimeline(this.currentUsername, 8)
      const fp = await JournalBizService.loadFootprints(this.currentUsername)
      this.footprints = fp.list
    } else {
      this.stats = new AnnualStatsData()
      this.stats.year = year
      this.monthStats = []
      this.timeline = []
      this.footprints = []
    }
    this.tagPresets = await JournalBizService.loadTagPresets()
    this.loading = false
  }

  private async runSearch(): Promise<void> {
    const q = this.searchQuery.trim()
    if (q.length === 0) {
      this.searchDiaries = []
      this.searchFeatured = []
      return
    }
    const res = await JournalBizService.search(q, this.currentUsername)
    this.searchDiaries = []
    for (const w of res.diaries) {
      this.searchDiaries.push(JournalItem.fromWire(w))
    }
    this.searchFeatured = []
    for (const w of res.featured) {
      this.searchFeatured.push(JournalItem.fromWire(w))
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '回顾', subtitle: '年度统计 · 趋势 · 足迹 · 时间轴' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.loading) {
              AppLoading({ label: '加载统计…' })
            } else {
              AppCard({ title: `${this.stats.year} 年度回顾`, variant: 'plain' }) {
                Text(this.summaryText())
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .lineHeight(24)
              }

              AppButton({
                label: '查看生活洞察 · 月度成长摘要',
                variant: 'secondary',
                onTap: (): void => { this.onOpenTool('insight') }
              })
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '札记',
                  value: `${this.stats.diaryCount}`,
                  trend: '篇',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '配图',
                  value: `${this.stats.imageCount}`,
                  trend: '张',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '记录日',
                  value: `${this.stats.writingDays}`,
                  trend: '天',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '相册',
                  value: `${this.stats.albumCount}`,
                  trend: '本',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '收藏',
                  value: `${this.stats.favoriteCount}`,
                  trend: '条',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              if (AuthService.isLoggedIn() && this.monthStats.length > 0) {
                ReviewMonthlyChart({ months: this.monthStats })
              }

              ReviewTimelineSection({ items: this.timeline })

              if (this.footprints.length > 0) {
                Column({ space: Theme.space.s3 }) {
                  Text('生活足迹')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Scroll() {
                    Row({ space: Theme.space.s3 }) {
                      ForEach(this.footprints, (fp: FootprintItem) => {
                        Column({ space: 6 }) {
                          Image(JournalMedia.coverMedia(fp.coverKey.length > 0 ?
                            fp.coverKey : 'hero_rain_walk'))
                            .width(100)
                            .height(72)
                            .borderRadius(Theme.radius.lg)
                            .objectFit(ImageFit.Cover)
                          Text(fp.city)
                            .fontSize(Theme.type.caption)
                            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                            .maxLines(1)
                            .width(100)
                          Text(`${fp.count} 次记录`)
                            .fontSize(Theme.type.overline)
                            .fontColor(Theme.colors().textTertiary)
                            .width(100)
                        }
                      }, (fp: FootprintItem) => fp.city)
                    }
                  }
                  .scrollable(ScrollDirection.Horizontal)
                  .scrollBar(BarState.Off)
                  .width('100%')
                }
                .width('100%')
              }

              if (this.stats.topTags.length > 0) {
                Column({ space: Theme.space.s3 }) {
                  Text('高频标签')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.stats.topTags, (t: TopTagItem) => {
                      Text(`${t.tag} (${t.count})`)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                        .margin({ right: 8, bottom: 8 })
                    }, (t: TopTagItem) => t.tag)
                  }
                  .width('100%')
                }
                .width('100%')
              }

              Column({ space: Theme.space.s3 }) {
                Text('标签灵感')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.tagPresets, (tag: TagPresetItem) => {
                    Text(tag.title)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .backgroundColor(Theme.colors().surfaceSubtle)
                      .borderRadius(Theme.radius.pill)
                      .margin({ right: 8, bottom: 8 })
                  }, (tag: TagPresetItem) => tag.id)
                }
                .width('100%')
              }
              .width('100%')
            }

            Column({ space: Theme.space.s3 }) {
              Text('快速搜索')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.searchQuery, placeholder: '搜索札记与回忆…' })
                  .layoutWeight(1)
                  .height(44)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onChange((v: string) => { this.searchQuery = v })
                Column() {
                  AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandOnPrimary })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => { void this.runSearch() })
              }
              .width('100%')

              if (this.searchDiaries.length > 0 || this.searchFeatured.length > 0) {
                ForEach(this.searchDiaries, (item: JournalItem) => {
                  JournalListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                  })
                }, (item: JournalItem) => `sd_${item.id}`)
                ForEach(this.searchFeatured, (item: JournalItem) => {
                  JournalListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { JournalDetailNav.openFeatured(item.id) }
                  })
                }, (item: JournalItem) => `sf_${item.id}`)
              }
            }
            .width('100%')

            AppButton({
              label: '智慧整理',
              variant: 'secondary',
              onTap: (): void => {
                this.showOrganize = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
            })
            AppButton({
              label: '生活日历回顾',
              variant: 'secondary',
              onTap: (): void => { this.onOpenTool('calendar') }
            })
            AppButton({
              label: '心情轨迹',
              variant: 'secondary',
              onTap: (): void => { this.onOpenTool('mood') }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showOrganize) {
        OrganizePage({
          onClose: (): void => {
            this.showOrganize = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onRequireAuth: (): void => this.onRequireAuth()
        })
          .width('100%')
          .height('100%')
          .zIndex(18)
      }
    }
    .width('100%')
    .height('100%')
  }
}
