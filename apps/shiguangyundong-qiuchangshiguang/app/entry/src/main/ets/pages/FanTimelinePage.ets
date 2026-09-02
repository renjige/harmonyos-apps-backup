import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppTextField } from '../components/design-system/AppTextField'
import { CourtMedia } from '../config/CourtMedia'
import { FanEntry, FanKind } from '../models/FanModels'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'

/** 记忆时光轴：跨类型检索 + 时间排序，丰富使用场景 */
@Component
export struct FanTimelinePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fanEpoch') @Watch('onEpoch') fanEpoch: number = 0
  @State query: string = ''
  @State items: FanEntry[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onEpoch(): void {
    this.reload()
  }

  private reload(): void {
    this.items = FanMemoryStore.search(this.query)
  }

  build() {
    Column() {
      Row({ space: Theme.space.s3 }) {
        Row() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .rotate({ angle: 180 })
        .onClick(() => {
          CourtDetailNav.closeFanTimeline()
        })
        Text('记忆时光轴')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('新建')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            CourtDetailNav.openFanEditor(FanKind.MATCH, '')
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      AppTextField({
        text: this.query,
        placeholder: '搜索比赛、球队、球员、复盘…',
        fieldHeight: 40,
        pill: true,
        onChange: (v: string): void => {
          this.query = v
          this.reload()
        }
      })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      Text('按日期聚合全部球迷记忆，支持跨类型检索')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.items.length === 0) {
        AppEmpty({
          title: this.query.length > 0 ? '没有匹配的记忆' : '时光轴还是空的',
          description: '写下观赛、日志、复盘或瞬间，都会出现在这里',
          actionLabel: '写观赛记录',
          onAction: (): void => {
            CourtDetailNav.openFanEditor(FanKind.MATCH, '')
          }
        }).padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (e: FanEntry) => {
              Row({ space: Theme.space.s3 }) {
                Image(CourtMedia.byKey(FanKind.coverOf(e.kind)))
                  .width(56)
                  .height(56)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(FanKind.titleOf(e.kind))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(e.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                  Text(e.dateLabel.length > 0 ? e.dateLabel : FanMemoryStore.statusLabel(e.kind, e.status))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                  if (e.body.length > 0) {
                    Text(e.body)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().textSecondary)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
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
              label: '继续添加记忆',
              onTap: (): void => {
                CourtDetailNav.openFanEditor(FanKind.JOURNAL, '')
              }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
