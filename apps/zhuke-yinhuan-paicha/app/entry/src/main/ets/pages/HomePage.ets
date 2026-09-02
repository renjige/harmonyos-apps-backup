import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { HazardCard } from '../components/hazard/HazardCard'
import { HazardItem } from '../models/HazardModels'
import { HazardBizService } from '../services/HazardBizService'
import { HazardMedia } from '../services/HazardMedia'
import { HazardLocalStore } from '../services/HazardLocalStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: HazardItem[] = []
  @State openTotal: number = 0
  @State todayInspect: number = 0
  @State pendingRectify: number = 0
  @State rectified: number = 0
  @State pendingReview: number = 0
  @State highCount: number = 0
  @State midCount: number = 0
  @State lowCount: number = 0
  @State loading: boolean = true
  onAdd: () => void = () => {}
  onInspect: () => void = () => {}
  onOpen: (item: HazardItem) => void = (_i: HazardItem) => {}
  onOpenAll: () => void = () => {}
  onOpenRectify: () => void = () => {}
  onOpenReview: () => void = () => {}
  onOpenMessages: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    let list: HazardItem[] = []
    let inspectToday: number = HazardLocalStore.todayInspect()
    if (HazardLocalStore.isRemoteSyncPaused()) {
      list = HazardLocalStore.all()
      this.items = list
      this.applyStats(list, inspectToday)
      this.loading = false
      return
    }
    try {
      list = await HazardBizService.listHazards()
    } catch {
      list = HazardLocalStore.all()
    }
    try {
      const inspects = await HazardBizService.listInspections()
      inspectToday = HazardBizService.countTodayInspections(inspects)
    } catch {
      // 保留本机今日检查次数
    }
    this.items = list
    this.applyStats(list, inspectToday)
    this.loading = false
  }

  private applyStats(list: HazardItem[], inspectToday: number): void {
    const s = HazardBizService.stats(list, inspectToday)
    this.openTotal = s.openTotal
    this.todayInspect = s.todayInspect
    this.pendingRectify = s.pendingRectify
    this.rectified = s.rectified
    this.pendingReview = s.pendingReview
    this.highCount = s.high
    this.midCount = s.mid
    this.lowCount = s.low
  }

  private recent(): HazardItem[] {
    return HazardBizService.recent(this.items, 4)
  }

  private barWeight(n: number): number {
    const t = this.highCount + this.midCount + this.lowCount
    if (t <= 0) {
      return 1
    }
    if (n <= 0) {
      return 1
    }
    return n
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(HazardMedia.cover('hero_site'))
            .width('100%').height(168).objectFit(ImageFit.Cover).borderRadius(18)
          Column()
            .width('100%').height(168).borderRadius(18)
            .linearGradient({ angle: 180, colors: [['#0016324F', 0.15], ['#E616324F', 1]] })
          Column({ space: 6 }) {
            Row() {
              Column({ space: 4 }) {
                Text('筑科隐患排查')
                  .fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').width('100%')
                Text('今日安全，及时发现')
                  .fontSize(14).fontColor('#FFFFFF').width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              Column() {
                AppIcon({ name: 'bell', iconSize: 20, color: '#FFFFFF' })
              }
              .width(40).height(40).justifyContent(FlexAlign.Center)
              .backgroundColor('#33FFFFFF').borderRadius(20)
              .onClick(() => this.onOpenMessages())
            }
            .width('100%')
          }
          .padding(16)
          .width('100%')
        }
        .width('100%')
        .height(168)
        .clip(true)
        .borderRadius(18)

        Column({ space: 8 }) {
          Text('当前待处理隐患')
            .fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
          Text(`${this.openTotal}`)
            .fontSize(36).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
          Text(this.openTotal === 0 ? '现场整体风险可控' : '请优先处理高风险项')
            .fontSize(13).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
        }
        .padding(18).width('100%').alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(18)

        Row({ space: 8 }) {
          Column({ space: 4 }) {
            Text(`${this.todayInspect}`)
              .fontSize(20).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('今日检查').fontSize(11).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding({ top: 12, bottom: 12 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(14)
          .justifyContent(FlexAlign.Center)

          Column({ space: 4 }) {
            Text(`${this.pendingRectify}`)
              .fontSize(20).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('待整改').fontSize(11).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding({ top: 12, bottom: 12 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(14)
          .justifyContent(FlexAlign.Center)

          Column({ space: 4 }) {
            Text(`${this.rectified}`)
              .fontSize(20).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('已整改').fontSize(11).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding({ top: 12, bottom: 12 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(14)
          .justifyContent(FlexAlign.Center)

          Column({ space: 4 }) {
            Text(`${this.pendingReview}`)
              .fontSize(20).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('待复查').fontSize(11).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1).padding({ top: 12, bottom: 12 })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(14)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')

        Column({ space: 10 }) {
          Text('当前隐患状态').fontSize(15).fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          Row({ space: 8 }) {
            Text('高风险').fontSize(12).fontColor('#D94A4A').width(48)
            Column()
              .height(8)
              .layoutWeight(this.barWeight(this.highCount))
              .backgroundColor('#D94A4A')
              .borderRadius(4)
            Text(`${this.highCount}`).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width(24)
          }
          .width('100%')
          Row({ space: 8 }) {
            Text('中风险').fontSize(12).fontColor('#E9932E').width(48)
            Column()
              .height(8)
              .layoutWeight(this.barWeight(this.midCount))
              .backgroundColor('#E9932E')
              .borderRadius(4)
            Text(`${this.midCount}`).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width(24)
          }
          .width('100%')
          Row({ space: 8 }) {
            Text('低风险').fontSize(12).fontColor('#36A269').width(48)
            Column()
              .height(8)
              .layoutWeight(this.barWeight(this.lowCount))
              .backgroundColor('#36A269')
              .borderRadius(4)
            Text(`${this.lowCount}`).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width(24)
          }
          .width('100%')
        }
        .padding(16).width('100%').alignItems(HorizontalAlign.Start)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(18)

        AppButton({ label: '新增隐患', onTap: (): void => { this.onAdd() } })

        Row({ space: 8 }) {
          this.Quick('开始检查', 'alert', (): void => { this.onInspect() })
          this.Quick('整改记录', 'biz', (): void => { this.onOpenRectify() })
          this.Quick('复查隐患', 'check', (): void => { this.onOpenReview() })
        }
        .width('100%')

        Row() {
          Text('最近隐患').fontSize(16).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Text('查看全部').fontSize(13).fontColor(Theme.colors().brandAccent).onClick(() => this.onOpenAll())
        }
        .width('100%')

        if (this.recent().length === 0) {
          AppEmpty({
            title: '暂无隐患记录',
            description: '发现现场问题后，可以快速记录并跟踪整改。',
            actionLabel: '新增隐患',
            onAction: (): void => { this.onAdd() }
          })
        } else {
          ForEach(this.recent(), (it: HazardItem) => {
            HazardCard({ item: it, onTap: (row: HazardItem) => this.onOpen(row) })
          }, (it: HazardItem) => it.id)
        }
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 32 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Quick(label: string, icon: string, tap: () => void) {
    Column({ space: 6 }) {
      AppIcon({ name: icon === 'alert' ? 'alert' : (icon === 'check' ? 'check' : 'biz'), iconSize: 20,
        color: Theme.colors().brandPrimary })
      Text(label).fontSize(12).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1).padding({ top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(14)
    .justifyContent(FlexAlign.Center)
    .onClick(() => tap())
  }
}
