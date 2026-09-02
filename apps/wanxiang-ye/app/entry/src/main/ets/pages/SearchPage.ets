import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { SearchResultSkeleton } from '../components/wanxiang/HomeFeedSkeleton'
import { InfoRowCard } from '../components/wanxiang/InfoRowCard'
import { SearchInputBar } from '../components/wanxiang/SearchInputBar'
import { InfoItem } from '../models/InfoModels'
import { InfoRepository } from '../services/InfoRepository'
import { UserDataStore } from '../services/UserDataStore'
import { WanXiangDetailNav } from '../services/WanXiangDetailNav'

@Component
export struct SearchPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bottomInset: number = 0
  @Prop refreshToken: number = 0
  @State keyword: string = ''
  @State results: InfoItem[] = []
  @State suggestions: string[] = []
  @State history: string[] = []
  @State hotTopics: string[] = InfoRepository.hotTopics()
  @State trending: InfoItem[] = InfoRepository.editorPicks()
  @State searched: boolean = false
  @State searching: boolean = false

  aboutToAppear(): void {
    void this.loadHistory()
  }

  aboutToUpdate(): void {
    void this.loadHistory()
  }

  private async loadHistory(): Promise<void> {
    this.history = await UserDataStore.getSearchHistory()
  }

  private onKeywordChange(v: string): void {
    this.keyword = v
    this.suggestions = InfoRepository.suggest(v)
    if (v.trim().length === 0) {
      this.searched = false
      this.results = []
    }
  }

  private runSearch(term?: string): void {
    const q = term !== undefined ? term : this.keyword
    this.keyword = q
    if (q.trim().length === 0) {
      return
    }
    this.searching = true
    this.searched = true
    this.suggestions = []
    void UserDataStore.addSearchTerm(q).then((): void => {
      void this.loadHistory()
    })
    InfoRepository.loadWithDelay((): void => {
      this.results = InfoRepository.search(q)
      this.searching = false
    })
  }

  private openDetail(item: InfoItem): void {
    WanXiangDetailNav.open(item.id)
  }

  build() {
    Column() {
      Column({ space: Theme.space.s2 }) {
        Text('搜索')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text('在全库资讯中快速定位')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

      SearchInputBar({
        value: this.keyword,
        placeholder: '输入关键词，如「科技」「博物馆」',
        onChange: (v: string): void => this.onKeywordChange(v),
        onSubmit: (): void => { this.runSearch() }
      })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .margin({ top: Theme.space.s3, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.suggestions.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('搜索建议')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              ForEach(this.suggestions, (s: string) => {
                Row() {
                  Text(s)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Text('↗')
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { void this.runSearch(s) })
              }, (s: string) => s)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          if (!this.searched) {
            Column({ space: Theme.space.s3 }) {
              Column({ space: Theme.space.s2 }) {
                Text('热门主题')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.hotTopics, (t: string) => {
                    Text(t)
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().textPrimary)
                      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                      .backgroundColor(Theme.colors().surfaceCard)
                      .borderRadius(Theme.radius.pill)
                      .border({ width: 1, color: Theme.colors().strokeStrong })
                      .margin({ right: 8, bottom: 8 })
                      .onClick((): void => { this.runSearch(t) })
                  }, (t: string) => t)
                }
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)

              Text('大家在读')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              ForEach(this.trending, (item: InfoItem) => {
                InfoRowCard({
                  item: item,
                  onTap: (): void => { this.openDetail(item) }
                })
              }, (item: InfoItem) => `trend-${item.id}`)
            }
            .width('100%')
          }

          if (!this.searched && this.history.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Row() {
                Text('最近搜索')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                Blank()
                Text('清空')
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .onClick((): void => {
                    void UserDataStore.clearSearchHistory().then(() => this.loadHistory())
                  })
              }
              .width('100%')

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.history, (h: string) => {
                  Text(h)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { void this.runSearch(h) })
                }, (h: string) => h)
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }

          if (this.searching) {
            SearchResultSkeleton()
          } else if (this.searched && this.results.length === 0) {
            AppEmpty({
              title: '未找到相关内容',
              description: '换个关键词或试试热门主题',
              actionLabel: '清除',
              onAction: (): void => {
                this.keyword = ''
                this.searched = false
                this.results = []
              }
            })
          } else if (this.results.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text(`找到 ${this.results.length} 条结果`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              ForEach(this.results, (item: InfoItem) => {
                InfoRowCard({
                  item: item,
                  onTap: (): void => { this.openDetail(item) }
                })
              }, (item: InfoItem) => item.id)
            }
            .width('100%')
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: this.bottomInset + Theme.space.s8
        })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
