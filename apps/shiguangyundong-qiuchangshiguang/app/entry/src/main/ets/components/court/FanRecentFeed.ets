import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { CourtMedia } from '../../config/CourtMedia'
import { FanEntry, FanKind } from '../../models/FanModels'
import { FanMemoryStore } from '../../services/FanMemoryStore'
import { CourtDetailNav } from '../../services/CourtDetailNav'

/** 最近记忆流：拾光页预览 + 跳转完整时光轴 */
@Component
export struct FanRecentFeed {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @State items: FanEntry[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = FanMemoryStore.timeline(5)
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Text('最近记忆')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('全部时光轴')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            CourtDetailNav.openFanTimeline()
          })
      }
      .width('100%')

      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有记忆',
          description: '写观赛记录、日志或复盘，会出现在这里',
          actionLabel: '记一场观赛',
          onAction: (): void => {
            CourtDetailNav.openFanEditor(FanKind.MATCH, '')
          }
        })
      } else {
        ForEach(this.items, (e: FanEntry) => {
          Row({ space: Theme.space.s3 }) {
            Image(CourtMedia.byKey(FanKind.coverOf(e.kind)))
              .width(48)
              .height(48)
              .borderRadius(Theme.radius.md)
              .objectFit(ImageFit.Cover)
            Column({ space: 2 }) {
              Text(`${FanKind.titleOf(e.kind)} · ${e.title}`)
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(e.dateLabel.length > 0 ? e.dateLabel : FanMemoryStore.statusLabel(e.kind, e.status))
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
          }
          .width('100%')
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .border({ width: 1, color: Theme.colors().strokeHairline })
          .onClick(() => {
            CourtDetailNav.openFanDetail(e.id)
          })
        }, (e: FanEntry) => e.id)
        AppButton({
          label: '打开记忆时光轴',
          variant: 'secondary',
          onTap: (): void => {
            CourtDetailNav.openFanTimeline()
          }
        })
      }
    }
    .width('100%')
  }
}
