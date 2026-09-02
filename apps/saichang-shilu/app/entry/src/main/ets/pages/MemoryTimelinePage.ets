import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { TimelineRow } from '../components/sport/SportCards'
import { SportRecordDetailPane } from '../components/sport/SportRecordDetailPane'
import { CollectDetailPane } from '../components/sport/CollectDetailPane'
import { TimelineGroup, TimelineEntry, CollectItem } from '../models/CollectModels'
import { SportRecord } from '../models/SportRecord'
import { MemoryStats } from '../services/MemoryStats'
import { RecordStore } from '../services/RecordStore'
import { CollectStore } from '../services/CollectStore'

@Component
export struct MemoryTimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State groups: TimelineGroup[] = []
  @State detailMatch: SportRecord | undefined = undefined
  @State detailItem: CollectItem | undefined = undefined
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void MemoryStats.buildTimeline().then((g): void => { this.groups = g })
  }

  private openEntry(kind: string, id: string): void {
    if (kind === 'match') {
      void RecordStore.findById(id).then((m): void => {
        if (m !== undefined) {
          this.detailMatch = m
        }
      })
      return
    }
    void CollectStore.find(id).then((it): void => {
      if (it !== undefined) {
        this.detailItem = it
      }
    })
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('赛事记忆时间轴')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s5 }) {
            if (this.groups.length === 0) {
              Text('还没有可展示的记忆。先记录一场，或写一条瞬间。')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            ForEach(this.groups, (g: TimelineGroup) => {
              Column({ space: Theme.space.s3 }) {
                Text(g.monthLabel)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                ForEach(g.entries, (e: TimelineEntry, idx: number) => {
                  TimelineRow({
                    entry: e,
                    isLast: idx >= g.entries.length - 1,
                    onTap: (): void => { this.openEntry(e.kind, e.id) }
                  })
                }, (e: TimelineEntry) => e.id)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }, (g: TimelineGroup) => g.monthLabel)
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.detailMatch !== undefined) {
        SportRecordDetailPane({
          record: this.detailMatch,
          onClose: (): void => { this.detailMatch = undefined },
          onDeleted: (): void => { this.detailMatch = undefined },
          onEdit: (): void => { this.detailMatch = undefined },
          onRecap: (): void => { this.detailMatch = undefined },
          onTimeline: (): void => { this.detailMatch = undefined }
        })
      }
      if (this.detailItem !== undefined) {
        CollectDetailPane({
          item: this.detailItem,
          onClose: (): void => { this.detailItem = undefined },
          onDeleted: (): void => { this.detailItem = undefined },
          onEdit: (): void => { this.detailItem = undefined }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(70)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
