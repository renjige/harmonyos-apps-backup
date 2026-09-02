import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { XdEntry, XdLabels, XdLookbackItem, XdMoodLog } from '../models/XdModels'
import { XdStore } from '../services/XdStore'
import { XdDetailNav } from '../services/XdDetailNav'
import { EntryListCard } from '../components/xd/EntryListCard'
import { StatTileCard } from '../components/xd/StatTileCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('xdDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State entryCount: number = 0
  @State clipCount: number = 0
  @State treasureCount: number = 0
  @State themeCount: number = 0
  @State inboxCount: number = 0
  @State recent: XdEntry[] = []
  @State look: XdLookbackItem = new XdLookbackItem()
  @State prompt: string = XdLabels.promptOfDay()
  @State streakDays: number = 0
  @State todayMood: XdMoodLog | undefined = undefined
  @State tidyCount: number = 0
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
    const stats = await XdStore.computeStats()
    this.entryCount = stats.entryCount
    this.clipCount = stats.clipCount
    this.treasureCount = stats.treasureCount
    this.themeCount = stats.themeCount
    this.inboxCount = stats.inboxCount
    this.streakDays = stats.streakDays
    this.statsEpoch = this.statsEpoch + 1
    this.recent = await XdStore.recentEntries(4)
    this.look = await XdStore.buildLookback()
    this.prompt = XdLabels.promptOfDay()
    this.todayMood = await XdStore.moodForToday()
    const tidy = await XdStore.buildTidySuggestions()
    this.tidyCount = tidy.length
  }

  private openLook(): void {
    if (this.look.sourceKind === 'clip' && this.look.sourceId.length > 0) {
      XdDetailNav.openClip(this.look.sourceId)
      return
    }
    if (this.look.sourceId.length > 0) {
      XdDetailNav.openEntry(this.look.sourceId)
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_island_mist'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({ angle: 180, colors: [['rgba(61,85,102,0)', 0], ['rgba(61,85,102,0.88)', 1]] })
          Column({ space: 6 }) {
            Text('小岛慢记')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
            Text(this.prompt)
              .fontSize(Theme.type.subtitleS)
              .fontColor('#F6F1E8')
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
        }
        .width('100%')
        .clip(true)
        .borderRadius(Theme.radius.lg)

        Row({ space: Theme.space.s3 }) {
          Column({ space: 6 }) {
            Text('写慢记')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandOnPrimary)
            Text('用模板留下今天')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandOnPrimary)
          }
          .layoutWeight(1.2)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { XdDetailNav.openEntryEditor('', 'today') })

          Column({ space: 6 }) {
            Text('收瞬间')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandDeep)
            Text('一句话收藏')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { XdDetailNav.openClipEditor('') })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          StatTileCard({ label: '慢记', value: this.entryCount })
          StatTileCard({ label: '收藏', value: this.clipCount })
          StatTileCard({ label: '主题岛', value: this.themeCount })
          StatTileCard({ label: '连续', value: this.streakDays })
        }
        .width('100%')
        .key(`stats_${this.statsEpoch}_${this.dataRev}`)

        Row() {
          Column({ space: 4 }) {
            Text('今日心情')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
            Text(this.todayMood !== undefined ? XdLabels.moodLabel(this.todayMood.moodKey) : '尚未记录')
              .fontSize(Theme.type.subtitleS)
              .fontColor(Theme.colors().textPrimary)
          }
          .layoutWeight(1)
          Text('记录')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandPrimary)
        }
        .width('100%')
        .padding(Theme.space.s3)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onClick((): void => { XdDetailNav.openMoodEditor() })

        if (this.tidyCount > 0) {
          Row() {
            AppIcon({ name: 'sparkle', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
            Text(`智慧整理 · ${this.tidyCount} 条建议`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textPrimary)
              .margin({ left: 8 })
              .layoutWeight(1)
            Text('查看')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().brandPrimary)
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { XdDetailNav.openTidyPanel() })
        }

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
            AppStorage.setOrCreate('xdJumpJournalInbox', true)
            AppStorage.setOrCreate('xdActiveTab', 1)
          })
        }

        Text('最近片段')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        if (this.recent.length === 0) {
          AppEmpty({
            title: '档案还是空的',
            description: '先留下一条慢记或一道瞬间',
            actionLabel: '写第一条',
            onAction: (): void => { XdDetailNav.openEntryEditor('', 'today') }
          })
        } else {
          ForEach(this.recent, (e: XdEntry) => {
            EntryListCard({
              entry: e,
              categoryLabel: e.categoryKey,
              onOpen: (): void => { XdDetailNav.openEntry(e.id) }
            })
          }, (e: XdEntry) => e.id)
        }

        Column({ space: 6 }) {
          Image($r('app.media.hero_corridor_sea'))
            .width('100%')
            .height(72)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.sm)
          Text('时光回望')
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
          AppButton({ label: '新建主题', variant: 'secondary', onTap: (): void => { XdDetailNav.openThemeEditor('') } })
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
