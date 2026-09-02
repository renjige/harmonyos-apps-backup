import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { RecordCard } from '../components/sport/RecordCard'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { DataInsightsPage } from './DataInsightsPage'
import { RecordEditPage } from './RecordEditPage'
import { RecapQuizPage } from './RecapQuizPage'
import { RecapTimelinePage } from './RecapTimelinePage'
import { SportRecord } from '../models/SportRecord'
import { NamedChip, TagLib, WatchStatus } from '../models/CollectModels'
import { StatusCounts } from '../models/CollectModels'
import { RecordStore } from '../services/RecordStore'
import { MemoryStats } from '../services/MemoryStats'
import { StatusPill } from '../components/sport/SportCards'
import { MatchWorkbenchPage } from './MatchWorkbenchPage'
import { MemoryTimelinePage } from './MemoryTimelinePage'
import { WatchQueuePage } from './WatchQueuePage'

@Component
export struct MatchListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State entries: SportRecord[] = []
  @State statusStats: StatusCounts = new StatusCounts()
  @State query: string = ''
  @State statusFilter: string = 'all'
  @State tagFilter: string = ''
  @State showMemoryTimeline: boolean = false
  @State showInsights: boolean = false
  @State showWatchQueue: boolean = false
  @State showWorkbench: boolean = false
  @State workbenchId: string = ''
  @State detailRecord: SportRecord | undefined = undefined
  @State showEdit: boolean = false
  @State showRecap: boolean = false
  @State showTimeline: boolean = false
  @State recapSeedId: string = ''
  @State editMode: boolean = false
  @State editSeedId: string = ''
  @State detailRefreshToken: number = 0
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private tags: string[] = TagLib.preset()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.statusStats = await MemoryStats.statusCounts()
    let list = await RecordStore.loadAll()
    if (this.statusFilter !== 'all') {
      const filtered: SportRecord[] = []
      for (const it of list) {
        const st = WatchStatus.normalize(it.status)
        if (this.statusFilter === 'want') {
          // 「待看」筛选与待看清单一致：待看 + 重点
          if (WatchStatus.isPending(st)) {
            filtered.push(it)
          }
        } else if (st === this.statusFilter) {
          filtered.push(it)
        }
      }
      list = filtered
    }
    if (this.tagFilter.length > 0) {
      const tagged: SportRecord[] = []
      for (const it of list) {
        if (it.tagsPacked.indexOf(this.tagFilter) >= 0) {
          tagged.push(it)
        }
      }
      list = tagged
    }
    this.entries = MemoryStats.searchMatches(list, this.query)
  }

  private async afterEditSaved(saved: SportRecord): Promise<void> {
    this.showEdit = false
    this.detailRecord = SportRecord.cloneFrom(saved)
    this.detailRefreshToken++
    await this.reload()
    const fresh = await RecordStore.findById(saved.id)
    if (fresh !== undefined) {
      this.detailRecord = fresh
      this.detailRefreshToken++
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('赛事')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
          }
          .width(44)
          .height(44)
          .borderRadius(22)
          .backgroundColor(Theme.colors().brandPrimary)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => {
            this.editMode = false
            this.editSeedId = ''
            this.showEdit = true
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_sport_track'))
            .width('100%')
            .height(100)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Column() {
            Blank()
            Row() {
              Column({ space: 2 }) {
                Text('我的赛事档案')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(`${this.statusStats.all} 场 · 待看 ${this.statusStats.pending()}`)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text('数据洞察')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('rgba(255,255,255,0.2)')
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.showInsights = true })
              Text('待看清单')
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('rgba(255,255,255,0.2)')
                .borderRadius(Theme.radius.pill)
                .margin({ left: 8 })
                .onClick((): void => { this.showWatchQueue = true })
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.88)', 1]]
            })
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height(100)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })

        TextInput({ text: this.query, placeholder: '搜索赛事 / 球队 / 标签' })
          .onChange((v: string) => {
            this.query = v
            void this.reload()
          })
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .padding(Theme.space.s3)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s2 }) {
              StatusPill({
                label: '全部',
                count: this.statusStats.all,
                active: this.statusFilter === 'all',
                onTap: (): void => { this.statusFilter = 'all'; void this.reload() }
              })
              StatusPill({
                label: '待看',
                count: this.statusStats.pending(),
                active: this.statusFilter === 'want',
                onTap: (): void => { this.statusFilter = 'want'; void this.reload() }
              })
              StatusPill({
                label: '已看',
                count: this.statusStats.watched,
                active: this.statusFilter === 'watched',
                onTap: (): void => { this.statusFilter = 'watched'; void this.reload() }
              })
              StatusPill({
                label: '重点',
                count: this.statusStats.focus,
                active: this.statusFilter === 'focus',
                onTap: (): void => { this.statusFilter = 'focus'; void this.reload() }
              })
            }
            .width('100%')

            Row() {
              Text('观赛清单 · 按状态筛选')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Blank()
              Text('记忆时间轴 →')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => { this.showMemoryTimeline = true })
            }
            .width('100%')

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.tags, (t: string) => {
                  Text(t)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.tagFilter === t ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.tagFilter === t ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .onClick((): void => {
                      this.tagFilter = this.tagFilter === t ? '' : t
                      void this.reload()
                    })
                }, (t: string) => t)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.entries.length === 0) {
              AppEmpty({
                title: '还没有赛事档案',
                description: '记下名称、对阵、结果和评价，建立你的观赛清单',
                actionLabel: '开始记录',
                onAction: (): void => {
                  this.editMode = false
                  this.editSeedId = ''
                  this.showEdit = true
                }
              })
            } else {
              ForEach(this.entries, (item: SportRecord) => {
                RecordCard({
                  record: item,
                  onTap: (): void => { this.detailRecord = item }
                })
              }, (item: SportRecord) => item.id)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailRecord !== undefined) {
        SportRecordDetailPane({
          record: this.detailRecord,
          refreshToken: this.detailRefreshToken,
          onClose: (): void => { this.detailRecord = undefined },
          onDeleted: (): void => { this.detailRecord = undefined; void this.reload() },
          onEdit: (): void => {
            if (this.detailRecord === undefined) {
              return
            }
            this.editMode = true
            this.editSeedId = this.detailRecord.id
            this.showEdit = true
          },
          onRecap: (): void => {
            this.recapSeedId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showRecap = true
          },
          onTimeline: (): void => {
            this.recapSeedId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showTimeline = true
          },
          onWorkbench: (): void => {
            this.workbenchId = (this.detailRecord as SportRecord).id
            this.detailRecord = undefined
            this.showWorkbench = true
          }
        })
      }
      if (this.showEdit) {
        RecordEditPage({
          editMode: this.editMode,
          seedId: this.editSeedId,
          onClose: (): void => { this.showEdit = false },
          onSaved: (saved: SportRecord): void => { void this.afterEditSaved(saved) }
        })
      }
      if (this.showRecap) {
        RecapQuizPage({
          seedId: this.recapSeedId,
          onClose: (): void => { this.showRecap = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showTimeline) {
        RecapTimelinePage({
          seedId: this.recapSeedId,
          onClose: (): void => { this.showTimeline = false },
          onSaved: (): void => { void this.reload() }
        })
      }
      if (this.showMemoryTimeline) {
        MemoryTimelinePage({ onClose: (): void => { this.showMemoryTimeline = false } })
      }
      if (this.showInsights) {
        DataInsightsPage({
          reloadToken: this.reloadToken,
          onClose: (): void => { this.showInsights = false; void this.reload() }
        })
      }
      if (this.showWatchQueue) {
        WatchQueuePage({ onClose: (): void => { this.showWatchQueue = false; void this.reload() } })
      }
      if (this.showWorkbench && this.workbenchId.length > 0) {
        MatchWorkbenchPage({
          seedId: this.workbenchId,
          onClose: (): void => { this.showWorkbench = false },
          onSaved: (): void => { void this.reload() }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }
}
