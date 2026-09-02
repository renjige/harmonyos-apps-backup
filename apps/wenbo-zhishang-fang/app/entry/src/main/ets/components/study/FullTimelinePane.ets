import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { OverlayShell } from './OverlayShell'
import { TimelineDayGroup, TimelineDayItem } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct FullTimelinePane {
  @StorageLink('noteEpoch') @Watch('onChange') noteEpoch: number = 0
  @State groups: TimelineDayGroup[] = []
  onClose: () => void = () => {}
  onOpenDetail: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.groups = await StudyStore.fullTimeline()
  }

  build() {
    OverlayShell({
      title: '完整阅读时间轴',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s4 }) {
      if (this.groups.length === 0) {
        AppEmpty({
          title: '还没有阅读记录',
          description: '添加书摘后，这里会按日期串联你的阅读历史',
          actionLabel: '去添加',
          onAction: (): void => { this.onClose() }
        })
      } else {
        ForEach(this.groups, (g: TimelineDayGroup) => {
          Column({ space: Theme.space.s2 }) {
            Text(g.dateLabel)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            ForEach(g.items, (item: TimelineDayItem) => {
              Row({ space: Theme.space.s3 }) {
                Column({ space: 4 }) {
                  Text(item.bookName)
                    .fontSize(Theme.type.bodyS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                    .width('100%')
                  Text(item.excerptPreview)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(item.tagLabel)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandAccent)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { this.onOpenDetail(item.id) })
            }, (item: TimelineDayItem) => item.id)
          }
          .width('100%')
        }, (g: TimelineDayGroup) => g.dateLabel)
      }
    }
    .width('100%')
  }
}
