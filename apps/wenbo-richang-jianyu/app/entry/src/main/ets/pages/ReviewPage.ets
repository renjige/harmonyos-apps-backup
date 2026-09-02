import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { MonthStampGrid } from '../components/journal/MonthStampGrid'
import { AnnualStatsData, JournalItem, TagPresetItem, TopTagItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { OrganizePage } from './OrganizePage'
import { AuthService } from '../services/AuthService'
import { LifeHubNav } from '../services/LifeHubNav'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('diaryDataVersion') @Watch('onDiaryDataVersionChange') diaryDataVersion: number = 0
  onRequireAuth: () => void = () => {}
  @State stats: AnnualStatsData = new AnnualStatsData()
  @State tagPresets: TagPresetItem[] = []
  @State searchQuery: string = ''
  @State searchDiaries: JournalItem[] = []
  @State searchFeatured: JournalItem[] = []
  @State loading: boolean = true
  @State showOrganize: boolean = false
  @State stampDays: string[] = []
  @State dayItems: JournalItem[] = []
  @State stampYear: number = 2026
  @State stampMonth: number = 1
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onDiaryDataVersionChange(): void {
    void this.reload()
    if (this.dayItems.length > 0) {
      void this.refreshDayItems()
    }
  }

  private async refreshDayItems(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.dayItems = []
      return
    }
    const diaries = await JournalBizService.loadDiaries(this.currentUsername)
    const picked = this.dayItems.length > 0 ? this.dayItems[0].recordDate.substring(0, 10) : ''
    if (picked.length < 10) {
      return
    }
    const next: JournalItem[] = []
    for (const d of diaries) {
      if (d.recordDate.length >= 10 && d.recordDate.substring(0, 10) === picked) {
        next.push(d)
      }
    }
    this.dayItems = next
  }

  private async reload(): Promise<void> {
    this.loading = true
    try {
      const now = new Date()
      this.stampYear = now.getFullYear()
      this.stampMonth = now.getMonth() + 1
      this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, this.stampYear)
      this.tagPresets = await JournalBizService.loadTagPresets()
      if (AuthService.isLoggedIn()) {
        const diaries = await JournalBizService.loadDiaries(this.currentUsername)
        const marks: string[] = []
        for (const d of diaries) {
          if (d.recordDate.length >= 10) {
            marks.push(d.recordDate.substring(0, 10))
          }
        }
        this.stampDays = marks
      }
    } catch {
      this.stats.year = this.stampYear
    }
    this.loading = false
  }

  private async onPickDay(iso: string): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.dayItems = []
      return
    }
    const all = await JournalBizService.loadDiaries(this.currentUsername)
    const out: JournalItem[] = []
    for (const d of all) {
      if (d.recordDate === iso) {
        out.push(d)
      }
    }
    this.dayItems = out
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
        AppHeader({ title: '年度回顾', subtitle: '总览记录 · 智慧整理 · 智能搜索' })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.loading) {
              AppLoading({ label: '加载统计…' })
            } else {
              Text(`${this.stats.year} 年度回顾`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '笺语',
                  value: `${this.stats.diaryCount}`,
                  trend: '篇',
                  positive: true
                }).layoutWeight(1)
                AppStatCard({
                  label: '图片',
                  value: `${this.stats.imageCount}`,
                  trend: '张',
                  positive: true
                }).layoutWeight(1)
              }
              .width('100%')

              Row({ space: Theme.space.s3 }) {
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

              Column({ space: Theme.space.s3 }) {
                Text('本月笺历')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text('点选有记录的日期，回看当天笺语')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
                MonthStampGrid({
                  year: this.stampYear,
                  month: this.stampMonth,
                  markedIso: this.stampDays,
                  onPick: (iso: string): void => { void this.onPickDay(iso) }
                })
                ForEach(this.dayItems, (item: JournalItem) => {
                  JournalListCard({
                    item: item,
                    compact: true,
                    onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                  })
                }, (item: JournalItem) => `cal_${item.id}`)
              }
              .width('100%')

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
                TextInput({ text: this.searchQuery, placeholder: '智能搜索笺语与温暖片段…' })
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
              label: '生活日历与月度总结',
              variant: 'secondary',
              onTap: (): void => { LifeHubNav.open('stats', false) }
            })
            AppButton({
              label: '智慧整理',
              variant: 'secondary',
              onTap: (): void => {
                this.showOrganize = true
                AppStorage.setOrCreate('tabBarHidden', true)
              }
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
