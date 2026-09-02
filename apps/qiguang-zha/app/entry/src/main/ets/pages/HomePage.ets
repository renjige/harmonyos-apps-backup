import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { QgEntry, QgLabels, QgLookbackItem } from '../models/QgModels'
import { QgStore } from '../services/QgStore'
import { QgDetailNav } from '../services/QgDetailNav'
import { EntryListCard } from '../components/qg/EntryListCard'
import { StatTileCard } from '../components/qg/StatTileCard'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageProp('qgDataRev') @Watch('onDataRev') dataRev: number = 0
  @Prop @Watch('onRefresh') refreshToken: number = 0
  @Prop bottomInset: number = 76
  @State entryCount: number = 0
  @State clipCount: number = 0
  @State treasureCount: number = 0
  @State themeCount: number = 0
  @State inboxCount: number = 0
  @State recent: QgEntry[] = []
  @State look: QgLookbackItem = new QgLookbackItem()
  @State prompt: string = QgLabels.promptOfDay()
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
    const stats = await QgStore.computeStats()
    this.entryCount = stats.entryCount
    this.clipCount = stats.clipCount
    this.treasureCount = stats.treasureCount
    this.themeCount = stats.themeCount
    this.inboxCount = stats.inboxCount
    this.statsEpoch = this.statsEpoch + 1
    this.recent = await QgStore.recentEntries(4)
    this.look = await QgStore.buildLookback()
    this.prompt = QgLabels.promptOfDay()
  }

  private openLook(): void {
    if (this.look.sourceKind === 'clip' && this.look.sourceId.length > 0) {
      QgDetailNav.openClip(this.look.sourceId)
      return
    }
    if (this.look.sourceId.length > 0) {
      QgDetailNav.openEntry(this.look.sourceId)
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_window_light'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.88)', 1]] })
          Column({ space: 6 }) {
            Text('栖光札')
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
            Text('写札记')
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
          .onClick((): void => { QgDetailNav.openEntryEditor('', 'today') })

          Column({ space: 6 }) {
            Text('收光影')
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
          .onClick((): void => { QgDetailNav.openClipEditor('') })
        }
        .width('100%')

        Row({ space: Theme.space.s2 }) {
          StatTileCard({ label: '札记', value: this.entryCount })
          StatTileCard({ label: '光影', value: this.clipCount })
          StatTileCard({ label: '珍藏', value: this.treasureCount })
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
            AppStorage.setOrCreate('qgJumpJournalInbox', true)
            AppStorage.setOrCreate('qgActiveTab', 1)
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
            description: '先留下一条札记或一道光影',
            actionLabel: '写第一条',
            onAction: (): void => { QgDetailNav.openEntryEditor('', 'today') }
          })
        } else {
          ForEach(this.recent, (e: QgEntry) => {
            EntryListCard({
              entry: e,
              categoryLabel: e.categoryKey,
              onOpen: (): void => { QgDetailNav.openEntry(e.id) }
            })
          }, (e: QgEntry) => e.id)
        }

        Column({ space: 6 }) {
          Image($r('app.media.hero_corridor_light'))
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
          AppButton({ label: '新建主题', variant: 'secondary', onTap: (): void => { QgDetailNav.openThemeEditor('') } })
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
