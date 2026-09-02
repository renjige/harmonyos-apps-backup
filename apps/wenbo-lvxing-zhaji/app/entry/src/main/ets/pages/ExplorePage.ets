import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalItem, TagPresetItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'

/** 探索 Tab：搜索 · 标签 · 旅行灵感 */
@Component
export struct ExplorePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State filterDate: string = ''
  @State filterTag: string = ''
  @State searchQuery: string = ''
  @State results: JournalItem[] = []
  @State featured: JournalItem[] = []
  @State tagPresets: TagPresetItem[] = []
  @State showFeatured: boolean = false
  @State featuredLoading: boolean = false
  @State searched: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadTags()
  }

  onRefreshTokenChange(): void {
    void this.loadTags()
  }

  private async loadTags(): Promise<void> {
    this.tagPresets = await JournalBizService.loadTagPresets()
  }

  private async loadFeaturedExamples(): Promise<void> {
    this.featuredLoading = true
    this.featured = await JournalBizService.loadFeatured()
    this.showFeatured = true
    this.featuredLoading = false
  }

  private async runFilter(): Promise<void> {
    this.searched = true
    const q = this.searchQuery.trim()
    if (q.length > 0) {
      const res = await JournalBizService.search(q, this.currentUsername)
      this.results = []
      for (const w of res.diaries) {
        this.results.push(JournalItem.fromWire(w))
      }
      for (const w of res.featured) {
        this.results.push(JournalItem.fromWire(w))
      }
      return
    }
    if (!AuthService.isLoggedIn()) {
      this.results = []
      return
    }
    let items = JournalBizService.filterJourneys(
      await JournalBizService.loadDiaries(this.currentUsername)
    )
    if (this.filterDate.length > 0) {
      const filtered: JournalItem[] = []
      for (const item of items) {
        if (item.recordDate === this.filterDate) {
          filtered.push(item)
        }
      }
      items = filtered
    }
    if (this.filterTag.length > 0) {
      const filtered: JournalItem[] = []
      for (const item of items) {
        for (const t of item.tags) {
          if (t === this.filterTag) {
            filtered.push(item)
          }
        }
      }
      items = filtered
    }
    this.results = items
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        AppHeader({ title: '探索', subtitle: '搜索札记 · 按标签浏览 · 旅行灵感' })

        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.searchQuery, placeholder: '搜索旅程、目的地、标签…' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.searchQuery = v })
          AppDatePickerField({
            label: '按日期筛选',
            value: this.filterDate,
            placeholder: '不限日期',
            minDaysFromToday: -3650,
            maxDaysFromToday: 365,
            onChange: (v: string) => { this.filterDate = v }
          })
          if (this.tagPresets.length > 0) {
            Text('标签筛选')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tagPresets, (tag: TagPresetItem) => {
                Text(tag.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterTag === tag.title ?
                    Theme.colors().brandPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.filterTag === tag.title ?
                    Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => {
                    this.filterTag = this.filterTag === tag.title ? '' : tag.title
                  })
              }, (tag: TagPresetItem) => tag.id)
            }
            .width('100%')
          }
          AppButton({
            label: '开始搜索',
            onTap: (): void => { void this.runFilter() }
          })
        }
        .width('100%')

        if (this.searched) {
          Column({ space: Theme.space.s3 }) {
            Text(`搜索结果（${this.results.length}）`)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.results.length === 0) {
              AppEmpty({
                title: '暂无匹配',
                description: '试试更换关键词或标签；登录后可搜索你的旅程',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.results, (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  compact: false,
                  onTap: (): void => {
                    if (item.userId.length > 0) {
                      JournalDetailNav.openDiary(item.id)
                    } else {
                      JournalDetailNav.openFeatured(item.id)
                    }
                  }
                })
              }, (item: JournalItem) => item.id)
            }
          }
          .width('100%')
        }

        Column({ space: Theme.space.s3 }) {
          Text('旅行灵感')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (!this.showFeatured) {
            Text('平台示例内容，需主动浏览；不会自动写入你的账号。')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: this.featuredLoading ? '加载中…' : '浏览旅行灵感（平台示例）',
              variant: 'secondary',
              disabled: this.featuredLoading,
              onTap: (): void => { void this.loadFeaturedExamples() }
            })
          } else {
            ForEach(this.featured.slice(0, 6), (item: JournalItem) => {
              JournalListCard({
                item: item,
                compact: false,
                onTap: (): void => { JournalDetailNav.openFeatured(item.id) }
              })
            }, (item: JournalItem) => item.id)
          }
        }
        .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
