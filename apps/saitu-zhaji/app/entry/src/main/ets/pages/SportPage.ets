import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppStatCard } from '../components/design-system/AppStatCard'
import { SportAlbum, SportEvent, SportFollow, SportStats, TrainingLog } from '../models/SaituSportModels'
import { SaituSportStore } from '../services/SaituSportStore'
import { SaituDetailNav } from '../services/SaituDetailNav'
import { SportEventCard } from '../components/sport/SportEventCard'

class SportMonthGroup {
  label: string = ''
  events: SportEvent[] = []
}

@Component
export struct SportPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituSportHubOpen') sportHubOpen: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State filter: string = 'all'
  @State events: SportEvent[] = []
  @State trainings: TrainingLog[] = []
  @State albums: SportAlbum[] = []
  @State follows: SportFollow[] = []
  @State stats: SportStats = new SportStats()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.events = await SaituSportStore.loadEvents()
    this.trainings = await SaituSportStore.loadTrainings()
    this.albums = await SaituSportStore.loadAlbums()
    this.follows = await SaituSportStore.loadFollows()
    this.stats = await SaituSportStore.stats()
  }

  private monthGroups(): SportMonthGroup[] {
    const map = new Map<string, SportEvent[]>()
    for (const e of this.events) {
      const label = e.eventDate.length >= 7 ? e.eventDate.substring(0, 7) : '未知'
      const bucket = map.get(label)
      if (bucket === undefined) {
        map.set(label, [e])
      } else {
        bucket.push(e)
      }
    }
    const keys: string[] = []
    map.forEach((_v: SportEvent[], k: string): void => {
      keys.push(k)
    })
    keys.sort((a, b) => b.localeCompare(a))
    const out: SportMonthGroup[] = []
    for (const k of keys) {
      const g = new SportMonthGroup()
      g.label = k
      const evs = map.get(k)
      g.events = evs !== undefined ? evs : []
      out.push(g)
    }
    return out
  }

  private visibleEvents(): SportEvent[] {
    if (this.filter === 'all' || this.filter === 'timeline') {
      return this.events
    }
    const out: SportEvent[] = []
    for (const e of this.events) {
      if (e.kind === this.filter) {
        out.push(e)
      }
    }
    return out
  }

  @Builder
  FilterChip(key: string, label: string) {
    Text(label)
      .fontSize(Theme.type.bodyS)
      .fontColor(this.filter === key ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.filter === key ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { this.filter = key })
  }


  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.sportHubOpen) {
            Row() {
              Text('赛事中枢')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(Theme.colors().textPrimary)
              Blank()
              Text('关闭')
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().brandPrimary)
                .onClick((): void => SaituDetailNav.closeSportHub())
            }
            .width('100%')
          } else {
            Text('赛事档案')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          Text('观赛记录、结构化复盘、训练日志与纪念册，构成完整赛途档案。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '赛事', value: `${this.stats.records}` })
            AppStatCard({ label: '笔记', value: `${this.stats.notes}` })
            AppStatCard({ label: '复盘', value: `${this.stats.reviews}` })
          }
          .width('100%')
          Row({ space: Theme.space.s3 }) {
            AppStatCard({ label: '训练', value: `${this.stats.trainings}` })
            AppStatCard({ label: '纪念册', value: `${this.stats.albums}` })
            AppStatCard({ label: '关注', value: `${this.stats.follows}` })
          }
          .width('100%')

          Scroll() {
            Row({ space: Theme.space.s2 }) {
              this.FilterChip('all', '全部')
              this.FilterChip('timeline', '时间轴')
              this.FilterChip('record', '记录')
              this.FilterChip('note', '笔记')
              this.FilterChip('review', '复盘')
              this.FilterChip('plan', '计划')
              this.FilterChip('training', '训练')
              this.FilterChip('album', '纪念册')
              this.FilterChip('follow', '关注')
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          if (this.filter === 'album') {
            if (this.albums.length === 0) {
              AppEmpty({ title: '还没有纪念册', description: '把世界杯、季后赛等整理成专题' })
            } else {
              ForEach(this.albums, (a: SportAlbum) => {
                Column({ space: 4 }) {
                  Text(a.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(a.description.length > 0 ? a.description : '点击打开专题')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(Theme.space.cardPadding)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => SaituDetailNav.openAlbumDetail(a.id))
              }, (a: SportAlbum) => a.id)
            }
          } else if (this.filter === 'follow') {
            if (this.follows.length === 0) {
              AppEmpty({ title: '还没有关注', description: '点右下角 + 添加球队或选手' })
            } else {
              ForEach(this.follows, (f: SportFollow) => {
                Column({ space: 4 }) {
                  Text(`${f.roleLabel()} · ${f.name}`)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  if (f.note.length > 0) {
                    Text(f.note)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(Theme.space.cardPadding)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => SaituDetailNav.openFollowDetail(f.id))
              }, (f: SportFollow) => f.id)
            }
          } else if (this.filter === 'training') {
            if (this.trainings.length === 0) {
              AppEmpty({ title: '还没有训练日志', description: '记录自主训练与体能练习' })
            } else {
              ForEach(this.trainings, (t: TrainingLog) => {
                Column({ space: 4 }) {
                  Text(t.title)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                  Text(`${t.logDate} · ${t.durationMin}分钟 · 强度${t.intensity}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                  if (t.summaryLine().length > 0) {
                    Text(t.summaryLine())
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(2)
                  }
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
                .padding(Theme.space.cardPadding)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => SaituDetailNav.openTrainingDetail(t.id))
              }, (t: TrainingLog) => t.id)
            }
          } else if (this.filter === 'timeline') {
            if (this.events.length === 0) {
              AppEmpty({ title: '时间轴还是空的', description: '按月份浏览赛事档案' })
            } else {
              ForEach(this.monthGroups(), (g: SportMonthGroup) => {
                Column({ space: Theme.space.s2 }) {
                  Text(g.label)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  ForEach(g.events, (e: SportEvent) => {
                    SportEventCard({ item: e, onTap: (): void => SaituDetailNav.openSportDetail(e.id) })
                  }, (e: SportEvent) => e.id)
                }
                .width('100%')
              }, (g: SportMonthGroup) => g.label)
            }
          } else if (this.visibleEvents().length === 0) {
            AppEmpty({
              title: this.filter === 'timeline' ? '时间轴还是空的' : '还没有内容',
              description: '点右下角 + 写下第一条赛事档案'
            })
          } else {
            ForEach(this.visibleEvents(), (e: SportEvent) => {
              SportEventCard({ item: e, onTap: (): void => SaituDetailNav.openSportDetail(e.id) })
            }, (e: SportEvent) => e.id)
          }

          Blank().height(this.bottomInset + Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.Spring)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .margin({ right: Theme.space.pageX, bottom: this.bottomInset + Theme.space.s3 })
      .onClick((): void => SaituDetailNav.openSportComposer())

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.colors().surfacePage)
  }
}
