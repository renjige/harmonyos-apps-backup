import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CourtMedia } from '../config/CourtMedia'
import { FanEntry, FanKind } from '../models/FanModels'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'

@Component
export struct FanListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('courtFanKind') @Watch('onKindChange') courtFanKind: string = FanKind.MATCH
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: FanEntry[] = []
  @State visible: FanEntry[] = []
  @State filterStatus: string = 'all'

  aboutToAppear(): void {
    this.reload()
  }

  onKindChange(): void {
    this.filterStatus = 'all'
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = FanMemoryStore.listByKind(this.courtFanKind)
    this.applyFilter()
  }

  private applyFilter(): void {
    if (this.courtFanKind !== FanKind.WATCHLIST || this.filterStatus === 'all') {
      this.visible = this.items
      return
    }
    const out: FanEntry[] = []
    for (let i = 0; i < this.items.length; i++) {
      if (this.items[i].status === this.filterStatus) {
        out.push(this.items[i])
      }
    }
    this.visible = out
  }

  private setFilter(status: string): void {
    this.filterStatus = status
    this.applyFilter()
  }

  private kindTitle(): string {
    return FanKind.titleOf(this.courtFanKind)
  }

  private chipColor(active: boolean): ResourceColor {
    return active ? Theme.colors().textOnBrandContainer : Theme.colors().textSecondary
  }

  private emptyTitle(): string {
    if (this.items.length > 0 && this.visible.length === 0) {
      return '该状态下暂无赛事'
    }
    return `还没有${this.kindTitle()}`
  }

  private emptyHint(): string {
    if (this.items.length > 0 && this.visible.length === 0) {
      return '试试其他观看状态，或新建一条比赛清单'
    }
    return FanKind.hintOf(this.courtFanKind)
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
          CourtDetailNav.closeFanList()
        })
        Text(this.kindTitle())
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('新建')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            CourtDetailNav.openFanEditor(this.courtFanKind, '')
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      if (this.courtFanKind === FanKind.WATCHLIST) {
        Row({ space: Theme.space.s2 }) {
          this.FilterChip('all', '全部')
          this.FilterChip('pending', '待观看')
          this.FilterChip('watched', '已观看')
          this.FilterChip('starred', '已收藏')
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      if (this.visible.length === 0) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({
            title: this.emptyTitle(),
            description: this.emptyHint(),
            actionLabel: '写第一条',
            onAction: (): void => {
              CourtDetailNav.openFanEditor(this.courtFanKind, '')
            }
          })
        }
        .padding(Theme.space.pageX)
        .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.visible, (e: FanEntry) => {
              Row({ space: Theme.space.s3 }) {
                Image(CourtMedia.byKey(FanKind.coverOf(e.kind)))
                  .width(56)
                  .height(56)
                  .borderRadius(Theme.radius.md)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(e.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
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
              label: `新增${this.kindTitle()}`,
              onTap: (): void => {
                CourtDetailNav.openFanEditor(this.courtFanKind, '')
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

  @Builder
  FilterChip(status: string, label: string) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.chipColor(this.filterStatus === status))
      .padding({ left: 10, right: 10, top: 8, bottom: 8 })
      .backgroundColor(this.filterStatus === status ? Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick(() => {
        this.setFilter(status)
      })
  }
}
