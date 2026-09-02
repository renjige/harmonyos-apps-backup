import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { HazardCard } from '../components/hazard/HazardCard'
import { HazardItem } from '../models/HazardModels'
import { HazardBizService } from '../services/HazardBizService'

class StatusChip {
  id: string = 'all'
  label: string = '全部'
}

@Component
export struct HazardListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop @Watch('onFilterSeedChange') filterSeed: string = 'all'
  @State query: string = ''
  @State status: string = 'all'
  @State items: HazardItem[] = []
  @State loading: boolean = true
  onOpen: (item: HazardItem) => void = (_i: HazardItem) => {}
  onAdd: () => void = () => {}

  private chips(): StatusChip[] {
    const ids: string[] = ['all', 'pending_rectify', 'rectifying', 'pending_review', 'closed']
    const labels: string[] = ['全部', '待整改', '整改中', '待复查', '已闭环']
    const list: StatusChip[] = []
    for (let i = 0; i < ids.length; i++) {
      const c = new StatusChip()
      c.id = ids[i]
      c.label = labels[i]
      list.push(c)
    }
    return list
  }

  aboutToAppear(): void {
    if (this.filterSeed.length > 0) {
      this.status = this.filterSeed
    }
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  onFilterSeedChange(): void {
    this.status = this.filterSeed.length > 0 ? this.filterSeed : 'all'
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.items = await HazardBizService.listHazards()
    this.loading = false
  }

  private shown(): HazardItem[] {
    return HazardBizService.filter(this.items, this.status, this.query)
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Text('隐患')
          .fontSize(24).fontWeight(FontWeight.Bold).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
        Row({ space: 8 }) {
          AppIcon({ name: 'search', iconSize: 16, color: Theme.colors().textSecondary })
          TextInput({ text: this.query, placeholder: '搜索隐患名称或位置' })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((v: string) => { this.query = v })
        }
        .width('100%').height(42).padding({ left: 12, right: 12 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard).borderRadius(12)

        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.chips(), (c: StatusChip) => {
              Text(c.label)
                .fontSize(13)
                .fontColor(this.status === c.id ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.status === c.id ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(14)
                .onClick(() => { this.status = c.id })
            }, (c: StatusChip) => `${c.id}_${this.status}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .width('100%')

      if (this.shown().length === 0) {
        AppEmpty({
          title: '暂无隐患记录',
          description: '发现现场问题后，可以快速记录并跟踪整改。',
          actionLabel: '新增隐患',
          onAction: (): void => { this.onAdd() }
        })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.shown(), (it: HazardItem) => {
            ListItem() {
              HazardCard({ item: it, onTap: (row: HazardItem) => this.onOpen(row) })
                .margin({ bottom: 10 })
            }
          }, (it: HazardItem) => it.id)
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16, bottom: 16 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
