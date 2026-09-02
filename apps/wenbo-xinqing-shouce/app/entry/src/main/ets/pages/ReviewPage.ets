import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { AnnualStatsData, JournalItem, TagPresetItem, TopTagItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { MoodCatalog } from '../services/MoodCatalog'
import { AuthService } from '../services/AuthService'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State stats: AnnualStatsData = new AnnualStatsData()
  @State tagPresets: TagPresetItem[] = []
  @State streakDays: number = 0
  @State searchQuery: string = ''
  @State searchDiaries: JournalItem[] = []
  @State searchFeatured: JournalItem[] = []
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const year = new Date().getFullYear()
    this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
    this.tagPresets = await JournalBizService.loadTagPresets()
    if (AuthService.isLoggedIn()) {
      const diaries = await JournalBizService.loadDiaries(this.currentUsername)
      const dates: string[] = []
      for (const d of diaries) {
        if (d.recordDate.length > 0) {
          dates.push(d.recordDate)
        }
      }
      this.streakDays = MoodCatalog.streakDays(dates)
    } else {
      this.streakDays = 0
    }
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
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '成长足迹', subtitle: '记录数量 · 坚持天数 · 常用标签' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.loading) {
              AppLoading({ label: '加载足迹…' })
            } else {
              Text(`${this.stats.year} 年成长概览`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '记录数',
                  value: `${this.stats.diaryCount}`,
                  trend: '篇',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '坚持',
                  value: `${this.streakDays}`,
                  trend: '天',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '图片',
                  value: `${this.stats.imageCount}`,
                  trend: '张',
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

              if (this.stats.topTags.length > 0) {
                Column({ space: Theme.space.s3 }) {
                  Text('常用标签')
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
              Text('智能搜索')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Row({ space: Theme.space.s2 }) {
                TextInput({ text: this.searchQuery, placeholder: '搜索心情与回忆…' })
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

              if (this.searchDiaries.length > 0) {
                ForEach(this.searchDiaries, (item: JournalItem) => {
                  JournalListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                  })
                }, (item: JournalItem) => `sd_${item.id}`)
              }
            }
            .width('100%')
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
    }
    .width('100%')
    .height('100%')
  }
}
