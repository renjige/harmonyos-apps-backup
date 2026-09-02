import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppBarChart, AppRingChart, BarChartItem } from '../components/design-system/AppChart'
import { SectionHeader } from '../components/sport/SportVisual'
import { StatsOverviewCard } from '../components/sport/StatsOverviewCard'
import { RecordCard } from '../components/sport/RecordCard'
import { MatchCalendar } from '../components/sport/MatchCalendar'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { RecordEditPage } from './RecordEditPage'
import { RecapQuizPage } from './RecapQuizPage'
import { RecapTimelinePage } from './RecapTimelinePage'
import { SportRecord, SportStats, SportTypeOption } from '../models/SportRecord'
import { CalendarDay, RivalStat } from '../models/SportExtra'
import { RecordStore } from '../services/RecordStore'
import { StatisticsUtil } from '../services/StatisticsUtil'
import { DateUtil } from '../utils/DateUtil'

@Component
export struct ArchivePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State entries: SportRecord[] = []
  @State stats: SportStats = new SportStats()
  @State filterType: string = 'all'
  @State viewYear: boolean = false
  @State selectedDate: string = ''
  @State rivalName: string = ''
  @State days: CalendarDay[] = []
  @State barItems: BarChartItem[] = []
  @State rivals: RivalStat[] = []
  @State ringPercent: number = 0
  @State detailRecord: SportRecord | undefined = undefined
  @State showEdit: boolean = false
  @State showRecap: boolean = false
  @State showTimeline: boolean = false
  @State recapSeedId: string = ''
  @State editSeedId: string = ''
  @State detailRefreshToken: number = 0
  @Prop reloadToken: number = 0
  @Prop modalMode: boolean = false
  @State lastToken: number = -1
  onClose: () => void = () => {}
  private filterOptions: SportTypeOption[] = SportTypeOption.all()

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const all = await RecordStore.loadAll()
    const now = new Date()
    this.stats = this.viewYear ?
      await StatisticsUtil.computeStats(now.getFullYear()) :
      await StatisticsUtil.computeStats(now.getFullYear(), now.getMonth() + 1)
    const marked: string[] = []
    for (const it of all) {
      marked.push(it.date)
    }
    this.days = StatisticsUtil.monthGrid(now.getFullYear(), now.getMonth() + 1, marked)
    const bars = StatisticsUtil.lastSixMonthBars(all)
    const mapped: BarChartItem[] = []
    for (const b of bars) {
      const item = new BarChartItem()
      item.label = b.label
      item.value = b.value
      mapped.push(item)
    }
    this.barItems = mapped
    this.rivals = StatisticsUtil.rivalStats(all)
    this.ringPercent = this.stats.typeCounts.length > 0 ? this.stats.typeCounts[0].percent / 100 : 0
    let next = StatisticsUtil.filterByType(all, this.filterType)
    if (this.selectedDate.length > 0) {
      const dayList: SportRecord[] = []
      for (const it of next) {
        if (it.date === this.selectedDate) {
          dayList.push(it)
        }
      }
      next = dayList
    }
    if (this.rivalName.length > 0) {
      const rivalList: SportRecord[] = []
      for (const it of next) {
        if (it.opponent === this.rivalName) {
          rivalList.push(it)
        }
      }
      next = rivalList
    }
    this.entries = next
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
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          if (this.modalMode) {
            Row() {
              Row() {
                AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
              }
              .width(44)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .onClick((): void => { this.onClose() })
              Blank()
              Text('数据洞察')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Blank()
              Column().width(44)
            }
            .width('100%')
          }

          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.ambient_empty'))
              .width('100%')
              .height(120)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column() {
              Blank()
              Column({ space: 4 }) {
                Text('观赛数据洞察')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('日历 · 趋势 · 对手交锋 · 类型分布')
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(10,37,64,0.9)', 1]]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(120)

          Row({ space: Theme.space.s2 }) {
            Text('月度')
              .fontSize(Theme.type.bodyS)
              .fontColor(!this.viewYear ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(!this.viewYear ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.viewYear = false; void this.reload() })
            Text('年度')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.viewYear ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.viewYear ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => { this.viewYear = true; void this.reload() })
          }

          StatsOverviewCard({
            stats: this.stats,
            periodLabel: this.viewYear ?
              `${new Date().getFullYear()} 年度概览` :
              DateUtil.monthLabel(new Date().getFullYear(), new Date().getMonth() + 1)
          })

          MatchCalendar({
            days: this.days,
            selectedKey: this.selectedDate,
            onSelect: (key: string): void => {
              this.selectedDate = this.selectedDate === key ? '' : key
              void this.reload()
            }
          })

          SectionHeader({ title: '趋势与分布', action: '' })

          Column() {
            AppBarChart({ title: '近 6 个月场次', items: this.barItems })
          }
          .width('100%')
          .margin({ bottom: Theme.space.s4 })
          Column() {
            AppRingChart({
              title: this.stats.topSportLabel.length > 0 ? `${this.stats.topSportLabel} 占比` : '类型占比',
              percent: this.ringPercent
            })
          }
          .width('100%')
          .margin({ bottom: Theme.space.s5 })

          if (this.rivals.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('对手交锋')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              ForEach(this.rivals, (r: RivalStat) => {
                Text(`${r.name} · ${r.matches} 场 · 胜 ${r.wins}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.rivalName === r.name ?
                    Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.rivalName === r.name ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => {
                    this.rivalName = this.rivalName === r.name ? '' : r.name
                    void this.reload()
                  })
              }, (r: RivalStat) => r.name)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .margin({ top: Theme.space.s2 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              Text('全部')
                .fontSize(Theme.type.bodyS)
                .fontColor(this.filterType === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.filterType === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.filterType = 'all'; void this.reload() })
              ForEach(this.filterOptions, (opt: SportTypeOption) => {
                Text(opt.label)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(this.filterType === opt.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .backgroundColor(this.filterType === opt.id ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.filterType = opt.id; void this.reload() })
              }, (opt: SportTypeOption) => opt.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.entries.length === 0) {
            AppEmpty({
              title: '这一筛选项下没有记录',
              description: '点日历有点的日子，或去首页记下新的一场',
              actionLabel: '',
              onAction: (): void => {}
            })
          } else {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.entries, (item: SportRecord) => {
                RecordCard({
                  record: item,
                  onTap: (): void => { this.detailRecord = item }
                })
              }, (item: SportRecord) => item.id)
            }
          }
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.detailRecord !== undefined) {
        SportRecordDetailPane({
          record: this.detailRecord,
          refreshToken: this.detailRefreshToken,
          onClose: (): void => { this.detailRecord = undefined },
          onDeleted: (): void => {
            this.detailRecord = undefined
            void this.reload()
          },
          onEdit: (): void => {
            if (this.detailRecord === undefined) {
              return
            }
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
            this.detailRecord = undefined
          }
        })
      }
      if (this.showEdit) {
        RecordEditPage({
          editMode: true,
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
    }
    .width('100%')
    .height('100%')
    .zIndex(this.modalMode ? 70 : 0)
    .onAppear((): void => {
      if (this.modalMode) {
        AppStorage.setOrCreate('tabBarHidden', true)
      }
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
    .onDisAppear((): void => {
      if (this.modalMode) {
        AppStorage.setOrCreate('tabBarHidden', false)
      }
    })
  }
}
