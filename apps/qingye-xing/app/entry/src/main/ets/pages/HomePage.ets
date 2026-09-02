import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { QyEntry, QyLabels, QyLookbackItem } from '../models/QyModels'
import { QyStore } from '../services/QyStore'
import { QyDetailNav } from '../services/QyDetailNav'
import { EntryListCard } from '../components/qy/EntryListCard'
import { StatTileCard } from '../components/qy/StatTileCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('QyDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State entryCount: number = 0
  @State clipCount: number = 0
  @State treasureCount: number = 0
  @State themeCount: number = 0
  @State inboxCount: number = 0
  @State recent: QyEntry[] = []
  @State look: QyLookbackItem = new QyLookbackItem()
  @State prompt: string = QyLabels.promptOfDay()
  @State statsEpoch: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const stats = await QyStore.computeStats()
    this.entryCount = stats.entryCount
    this.clipCount = stats.clipCount
    this.treasureCount = stats.treasureCount
    this.themeCount = stats.themeCount
    this.inboxCount = stats.inboxCount
    this.statsEpoch = this.statsEpoch + 1
    this.recent = await QyStore.recentEntries(4)
    this.look = await QyStore.buildLookback()
    this.prompt = QyLabels.promptOfDay()
  }

  private openLook(): void {
    if (this.look.sourceKind === 'clip' && this.look.sourceId.length > 0) {
      QyDetailNav.openClip(this.look.sourceId)
      return
    }
    if (this.look.sourceId.length > 0) {
      QyDetailNav.openEntry(this.look.sourceId)
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_forest_trail'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({ angle: 180, colors: [['rgba(26,61,50,0)', 0], ['rgba(26,61,50,0.88)', 1]] })
          Column({ space: 6 }) {
            Text('清野行')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F5F5F0')
            Text(this.prompt)
              .fontSize(Theme.type.subtitleS)
              .fontColor('#F5F5F0')
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            Text('新建探索')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
            Text('记录今天的发现')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
          }
          .layoutWeight(1.2)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { QyDetailNav.openEntryEditor('', 'today') })

          Column({ space: 6 }) {
            Text('添加观察')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandDeep)
            Text('植物·天气·景色')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { QyDetailNav.openClipEditor('') })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          StatTileCard({ label: '探索', value: this.entryCount })
          StatTileCard({ label: '观察', value: this.clipCount })
          StatTileCard({ label: '收藏', value: this.treasureCount })
          StatTileCard({ label: '主题', value: this.themeCount })
        }
        .width('100%')
        .key(`stats_${this.statsEpoch}_${this.dataRev}`)

        if (this.inboxCount > 0) {
          Row() {
            AppIcon({ name: 'alert', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
            Text(`有 ${this.inboxCount} 条待整理`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textPrimary)
              .margin({ left: 8 })
              .layoutWeight(1)
            Text('去整理')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => {
            AppStorage.setOrCreate('qyJumpExploreInbox', true)
            AppStorage.setOrCreate('QyActiveTab', 1)
          })
        }

        Text('最近探索')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.recent.length === 0) {
          AppEmpty({
            title: '探索档案还是空的',
            description: '先留下一条探索或一次观察',
            actionLabel: '开始探索',
            onAction: (): void => { QyDetailNav.openEntryEditor('', 'today') }
          })
        } else {
          ForEach(this.recent, (e: QyEntry) => {
            EntryListCard({
              entry: e,
              categoryLabel: e.categoryKey,
              onOpen: (): void => { QyDetailNav.openEntry(e.id) }
            })
          }, (e: QyEntry) => e.id)
        }

        Column({ space: 6 }) {
          Image($r('app.media.hero_timeline_corridor'))
            .width('100%')
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Text('智慧回望')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
            .width('100%')
          Text(this.look.title)
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.look.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { this.openLook() })

        Row() {
          AppButton({ label: '新建主题', variant: 'secondary', onTap: (): void => { QyDetailNav.openThemeEditor('') } })
        }
        .width('100%')

        Column().height(this.bottomInset + Theme.space.s4)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onAppear((): void => { void this.reload() })
    .backgroundColor(this.dataRev >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
