import { Theme } from '../components/design-system/Theme'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { AnnualStatsData, JournalItem, TagPresetItem, TopTagItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'
import { OrganizePage } from './OrganizePage'

@Component
export struct ReviewPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onRequireAuth: () => void = () => {}
  onClose: () => void = () => {}
  @Prop embeddedTab: boolean = false
  @State stats: AnnualStatsData = new AnnualStatsData()
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

  private async reload(): Promise<void> {
    this.loading = true
    if (!AuthService.isLoggedIn()) {
      this.stats = new AnnualStatsData()
      this.stats.year = new Date().getFullYear()
      this.tagPresets = await JournalBizService.loadTagPresets()
      this.loading = false
      return
    }
    const year = new Date().getFullYear()
    this.stats = await JournalBizService.loadAnnualStats(this.currentUsername, year)
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
        if (!this.embeddedTab) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.onClose() })
            Text('年度回顾')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
        } else {
          Text('时光回顾')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (!AuthService.isLoggedIn()) {
              AppEmpty({
                title: '登录后查看年度回顾',
                description: '统计仅展示您本人创建的旅程、相册与收藏；新用户首次进入数据为空',
                actionLabel: '去登录',
                onAction: (): void => { this.onRequireAuth() }
              })
            } else if (this.loading) {
              AppLoading({ label: '加载统计…' })
            } else {
              Text(`${this.stats.year} 年度回顾`)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')

              Row({ space: Theme.space.s3 }) {
                AppStatCard({
                  label: '旅程',
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

            if (AuthService.isLoggedIn()) {
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
            }
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
