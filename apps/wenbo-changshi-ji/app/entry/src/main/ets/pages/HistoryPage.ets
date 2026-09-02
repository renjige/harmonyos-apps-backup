import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { ContentCard } from '../components/ContentCard'
import { FactItem } from '../models/CommonSenseModels'
import { CommonSenseBizService } from '../services/CommonSenseBizService'
import { CommonSenseDetailNav } from '../services/CommonSenseDetailNav'
import { CommonSenseLocalService } from '../services/CommonSenseLocalService'
import { CommonSenseStore } from '../services/CommonSenseStore'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('csRefresh') @Watch('onCsRefresh') csRefresh: number = 0
  @State reads: FactItem[] = []
  @State mastered: FactItem[] = []
  @State tab: string = 'read'
  @State favCount: number = 0
  @State dayCount: number = 0
  @State readCount: number = 0
  @State masterCount: number = 0

  aboutToAppear(): void {
    void this.reload()
  }

  onCsRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const stats = CommonSenseStore.stats()
    this.favCount = stats.favorites
    this.dayCount = stats.readDays
    this.readCount = stats.readCount
    this.masterCount = stats.mastered
    const all = await CommonSenseBizService.loadFacts()
    this.reads = this.pick(all, CommonSenseStore.readIds())
    this.mastered = this.pick(all, CommonSenseLocalService.masteredIds())
  }

  private pick(all: FactItem[], ids: string[]): FactItem[] {
    const out: FactItem[] = []
    for (const id of ids) {
      for (const item of all) {
        if (item.id === id) {
          out.push(item)
        }
      }
    }
    return out
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => { CommonSenseDetailNav.close() })
        Text('学习记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: Theme.space.s3 }) {
        this.Stat('阅读', `${this.readCount}`)
        this.Stat('收藏', `${this.favCount}`)
        this.Stat('打卡天', `${this.dayCount}`)
        this.Stat('已掌握', `${this.masterCount}`)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Row({ space: 8 }) {
        Text('阅读历史')
          .fontSize(12)
          .fontColor(this.tab === 'read' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.tab === 'read' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.tab = 'read' })
        Text('已掌握')
          .fontSize(12)
          .fontColor(this.tab === 'master' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.tab === 'master' ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.tab = 'master' })
      }
      .padding({ left: Theme.space.pageX, top: 8, bottom: 8 })

      if (this.currentList().length === 0) {
        AppEmpty({
          title: this.tab === 'read' ? '还没有阅读记录' : '还没有已掌握条目',
          description: '打开详情阅读、完成问答或标为已掌握后会出现在这里。'
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.currentList(), (row: FactItem) => {
              ContentCard({
                item: row,
                compact: false,
                onOpen: (): void => { CommonSenseDetailNav.openFact(row.id) }
              })
            }, (row: FactItem) => row.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private currentList(): FactItem[] {
    return this.tab === 'master' ? this.mastered : this.reads
  }

  @Builder
  Stat(label: string, value: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().brandPrimary)
      Text(label)
        .fontSize(11)
        .fontColor(Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.card)
  }
}
