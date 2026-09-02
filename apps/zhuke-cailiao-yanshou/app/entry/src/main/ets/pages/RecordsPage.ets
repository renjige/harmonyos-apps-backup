import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { FilterChips } from '../components/inspect/FilterChips'
import { InspectListCard } from '../components/inspect/InspectListCard'
import { InspectRecord } from '../models/InspectModels'
import { InspectService } from '../services/InspectService'
import { InspectNav } from '../services/InspectNav'
import { InspectLocalStore } from '../services/InspectLocalStore'

@Component
export struct RecordsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('inspectTick') @Watch('onTick') inspectTick: number = 0
  @Prop refreshToken: number = 0
  @State keyword: string = ''
  @State filter: string = 'all'
  @State dayKey: string = ''
  @State items: InspectRecord[] = []
  @State monthTotal: number = 0
  @State passRate: number = 0
  @State monthPending: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onTick(): void {
    this.reload()
  }

  private reload(): void {
    const s = InspectService.stats()
    this.monthTotal = s.monthTotal
    this.passRate = s.passRate
    this.monthPending = s.monthPending
    this.items = []
    const dayList = InspectService.byDay(this.dayKey)
    const searched = InspectService.search(this.keyword, this.filter, false)
    const out: InspectRecord[] = []
    for (const row of searched) {
      if (this.dayKey.length === 0) {
        out.push(row)
      } else {
        for (const d of dayList) {
          if (d.id === row.id) {
            out.push(row)
          }
        }
      }
    }
    this.items = out
  }

  private recentDays(): string[] {
    const out: string[] = []
    const now = new Date()
    for (let i = 6; i >= 0; i--) {
      const d = new Date()
      d.setDate(now.getDate() - i)
      out.push(InspectLocalStore.formatDay(d))
    }
    return out
  }

  build() {
    Column() {
      Text('记录')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.pageY,
          bottom: 8
        })

      Scroll() {
        Row({ space: 8 }) {
          Text('全部日期')
            .fontSize(Theme.type.caption)
            .fontColor(this.dayKey.length === 0 ? Theme.chipFg(true) : Theme.chipFg(false))
            .padding({ left: 10, right: 10, top: 7, bottom: 7 })
            .backgroundColor(this.dayKey.length === 0 ? Theme.chipBg(true) : Theme.chipBg(false))
            .borderRadius(Theme.radius.pill)
            .onClick(() => {
              this.dayKey = ''
              this.reload()
            })
          ForEach(this.recentDays(), (day: string) => {
            Text(day.slice(5))
              .fontSize(Theme.type.caption)
              .fontColor(this.dayKey === day ? Theme.chipFg(true) : Theme.chipFg(false))
              .padding({ left: 10, right: 10, top: 7, bottom: 7 })
              .backgroundColor(this.dayKey === day ? Theme.chipBg(true) : Theme.chipBg(false))
              .borderRadius(Theme.radius.pill)
              .onClick(() => {
                this.dayKey = day
                this.reload()
              })
          }, (day: string) => day)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      Row({ space: 10 }) {
        this.statCard('本月验收', `${this.monthTotal} 条`)
        this.statCard('通过率', `${this.passRate}%`)
        this.statCard('待处理', `${this.monthPending} 条`)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 10 })

      TextInput({ text: this.keyword, placeholder: '搜索材料名称 / 供应商' })
        .height(44)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(12)
        .onChange((v: string) => {
          this.keyword = v
          this.reload()
        })

      Scroll() {
        FilterChips({
          current: this.filter,
          inspectMode: false,
          onChange: (key: string) => {
            this.filter = key
            this.reload()
          }
        })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有验收记录',
            description: '开始一次材料验收，让现场记录更清晰。',
            actionLabel: '开始验收',
            onAction: () => InspectNav.openCreate()
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10 }) {
          ForEach(this.items, (item: InspectRecord) => {
            ListItem() {
              InspectListCard({
                item: item,
                stamp: `${item.updatedAt}_${item.result}`,
                onTap: () => InspectNav.openDetail(item.id)
              })
            }
          }, (item: InspectRecord) => `${item.id}_${item.updatedAt}_${item.result}`)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .opacity(this.refreshToken >= 0 ? 1 : 1)
  }

  @Builder
  statCard(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
