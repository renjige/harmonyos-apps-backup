import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordListCard } from '../components/saitu/RecordListCard'
import { SportEventCard } from '../components/sport/SportEventCard'
import { SaituRecord, DateGroup } from '../models/SaituModels'
import { SportEvent } from '../models/SaituSportModels'
import { SearchResultItem } from '../models/SaituGrowthModels'
import { SaituLocalStore } from '../services/SaituLocalStore'
import { SaituSportStore } from '../services/SaituSportStore'
import { SaituSearchService } from '../services/SaituSearchService'
import { SaituDetailNav } from '../services/SaituDetailNav'

@Component
export struct ArchivePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State segment: string = 'all'
  @State keyword: string = ''
  @State records: SaituRecord[] = []
  @State events: SportEvent[] = []
  @State searchResults: SearchResultItem[] = []
  @State journeyNames: Map<string, string> = new Map()
  @State groups: DateGroup[] = []
  @State useSearch: boolean = false
  @State displayRecords: SaituRecord[] = []
  @State displayEvents: SportEvent[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.records = await SaituLocalStore.loadRecords()
    this.events = await SaituSportStore.loadEvents()
    const journeys = await SaituLocalStore.loadJourneys()
    const map = new Map<string, string>()
    for (const j of journeys) {
      map.set(j.id, j.name)
    }
    this.journeyNames = map
    this.groups = DateGroup.groupRecords(this.records)
    this.updateDisplayLists()
    await this.runSearch()
  }

  private updateDisplayLists(): void {
    const recs: SaituRecord[] = []
    for (const r of this.records) {
      if (this.segment === 'record' || this.segment === 'all') {
        recs.push(r)
      } else if (this.segment === 'favorite' && r.favorite) {
        recs.push(r)
      }
    }
    this.displayRecords = recs
    const evs: SportEvent[] = []
    for (const e of this.events) {
      if (this.segment === 'sport' || this.segment === 'all') {
        evs.push(e)
      } else if (this.segment === 'favorite' && e.favorite) {
        evs.push(e)
      }
    }
    this.displayEvents = evs
    this.groups = DateGroup.groupRecords(recs)
  }

  private async runSearch(): Promise<void> {
    const q = this.keyword.trim()
    this.useSearch = q.length > 0 || this.segment === 'favorite'
    const filter = this.segment === 'favorite' ? 'favorite' : this.segment
    this.searchResults = await SaituSearchService.search(q, filter, this.segment === 'favorite')
  }

  private journeyLabel(id: string): string {
    const name = this.journeyNames.get(id)
    return name !== undefined ? name : ''
  }

  private filteredRecords(): SaituRecord[] {
    return this.displayRecords
  }

  private filteredEvents(): SportEvent[] {
    return this.displayEvents
  }

  @Builder
  SegChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.segment === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.segment === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.segment = key
        this.updateDisplayLists()
        void this.runSearch()
      })
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row() {
          Text('赛途档案')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
          Blank()
          Text('赛事中枢')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => SaituDetailNav.openSportHub())
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        Row({ space: Theme.space.s2 }) {
          TextInput({ text: this.keyword, placeholder: '搜索札记、赛事、小结…' })
            .layoutWeight(1)
            .fontSize(Theme.type.body)
            .onChange((v: string): void => {
              this.keyword = v
              void this.runSearch()
            })
          Column() {
            AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Row({ space: Theme.space.s2 }) {
            this.SegChip('all', '全部')
            this.SegChip('record', '札记')
            this.SegChip('sport', '赛事')
            this.SegChip('favorite', '收藏')
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.useSearch) {
              if (this.searchResults.length === 0) {
                AppEmpty({ title: '无匹配结果', description: '换个关键词或切换分段试试' })
              } else {
                ForEach(this.searchResults, (item: SearchResultItem) => {
                  Row({ space: Theme.space.s3 }) {
                    Column({ space: 4 }) {
                      Text(item.title)
                        .fontSize(Theme.type.body)
                        .fontColor(Theme.colors().textPrimary)
                      Text(item.subtitle)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textTertiary)
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    if (item.favorite) {
                      Text('★')
                        .fontSize(Theme.type.body)
                        .fontColor(Theme.colors().brandPrimary)
                    }
                  }
                  .width('100%')
                  .padding(Theme.space.cardPadding)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .onClick((): void => {
                    if (item.kind === 'record') {
                      SaituDetailNav.openRecord(item.id)
                    } else if (item.kind === 'sport') {
                      SaituDetailNav.openSportDetail(item.id)
                    } else if (item.kind === 'insight') {
                      SaituDetailNav.openInsight(item.id)
                    }
                  })
                }, (item: SearchResultItem) => `${item.kind}_${item.id}`)
              }
            } else if (this.segment === 'sport' || this.segment === 'favorite') {
              if (this.displayEvents.length === 0) {
                AppEmpty({ title: '暂无赛事档案', description: '点击右下角 + 创建赛事记录' })
              } else {
                ForEach(this.displayEvents, (e: SportEvent) => {
                  SportEventCard({
                    item: e,
                    onTap: (): void => SaituDetailNav.openSportDetail(e.id)
                  })
                }, (e: SportEvent) => e.id)
              }
            } else {
              if (this.displayRecords.length === 0) {
                AppEmpty({ title: '暂无札记', description: '点击右下角 + 写下第一条' })
              } else {
                ForEach(this.groups, (g: DateGroup) => {
                  Column({ space: Theme.space.s2 }) {
                    Text(g.label)
                      .fontSize(Theme.type.overline)
                      .fontColor(Theme.colors().textTertiary)
                      .width('100%')
                    ForEach(g.records, (r: SaituRecord) => {
                      if (this.segment !== 'favorite' || r.favorite) {
                        RecordListCard({
                          record: r,
                          journeyName: this.journeyLabel(r.journeyId),
                          onTap: (): void => SaituDetailNav.openRecord(r.id)
                        })
                      }
                    }, (r: SaituRecord) => r.id)
                  }
                }, (g: DateGroup) => g.dateKey)
              }
            }
            Blank().height(this.bottomInset + Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: this.bottomInset + Theme.space.s3 })
      .shadow({ radius: 12, color: 'rgba(0,122,255,0.35)', offsetY: 4 })
      .onClick((): void => {
        if (this.segment === 'sport') {
          SaituDetailNav.openNewSportEditor('record', '')
        } else {
          SaituDetailNav.openNewEditor()
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
