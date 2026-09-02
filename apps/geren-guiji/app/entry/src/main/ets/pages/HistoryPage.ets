import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { TrackListCard } from '../components/track/TrackListCard'
import { TrackRecord } from '../models/TrackModels'
import { TrackStore } from '../services/TrackStore'
import { TrackAnalytics } from '../services/TrackAnalytics'
import { TrackDetailNav } from '../services/TrackDetailNav'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: TrackRecord[] = []
  @State selectMode: boolean = false
  @State selectedIds: string[] = []
  @State totalCount: number = 0
  @StorageLink('trackDetailId') detailId: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = TrackStore.list()
    this.totalCount = TrackAnalytics.summarize().totalTracks
  }

  private isSelected(id: string): boolean {
    for (const sid of this.selectedIds) {
      if (sid === id) {
        return true
      }
    }
    return false
  }

  private toggleSelect(id: string): void {
    if (this.isSelected(id)) {
      const next: string[] = []
      for (const sid of this.selectedIds) {
        if (sid !== id) {
          next.push(sid)
        }
      }
      this.selectedIds = next
    } else {
      this.selectedIds = this.selectedIds.concat([id])
    }
  }

  private async deleteSelected(): Promise<void> {
    if (this.selectedIds.length === 0) {
      return
    }
    await TrackStore.removeMany(this.selectedIds)
    this.selectedIds = []
    this.selectMode = false
    this.reload()
  }

  build() {
    Column() {
      this.PageHeader()

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有足迹',
          description: '在首页记录足迹，时间线会出现在这里',
          actionLabel: '刷新',
          onAction: (): void => {
            this.reload()
          }
        }).layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: this.selectMode ? '取消多选' : '批量管理',
                variant: 'secondary',
                onTap: (): void => {
                  this.selectMode = !this.selectMode
                  this.selectedIds = []
                }
              }).layoutWeight(1)
              if (this.selectMode) {
                AppButton({
                  label: `删除 (${this.selectedIds.length})`,
                  variant: 'danger',
                  onTap: (): void => {
                    void this.deleteSelected()
                  }
                }).layoutWeight(1)
              }
            }

            ForEach(this.items, (item: TrackRecord, idx: number) => {
              TrackListCard({
                item: item,
                cardIndex: idx,
                selected: this.selectMode && this.isSelected(item.id),
                onTap: (): void => {
                  if (this.selectMode) {
                    this.toggleSelect(item.id)
                  } else {
                    TrackDetailNav.open(item.id)
                  }
                }
              })
            }, (item: TrackRecord) => item.id)
          }
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 + 72 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .onAppear(() => {
      this.reload()
    })
  }

  @Builder
  PageHeader() {
    Column({ space: 8 }) {
      Text('足迹历史')
        .fontSize(Theme.type.title1)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Text('本地时间线 · 手动记录')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        Text(`${this.totalCount} 条`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s6, bottom: Theme.space.s4 })
  }
}
