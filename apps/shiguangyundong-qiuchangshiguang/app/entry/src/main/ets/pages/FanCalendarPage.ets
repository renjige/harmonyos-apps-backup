import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CourtMedia } from '../config/CourtMedia'
import { FanEntry, FanKind } from '../models/FanModels'
import { FanMemoryStore } from '../services/FanMemoryStore'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { DateFormatUtil } from '../components/design-system/DateFormatUtil'

@Component
export struct FanCalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('fanEpoch') @Watch('onEpoch') fanEpoch: number = 0
  @State upcoming: FanEntry[] = []
  @State past: FanEntry[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onEpoch(): void {
    this.reload()
  }

  private reload(): void {
    const today = DateFormatUtil.formatDate(new Date())
    const all = FanMemoryStore.calendarItems()
    const up: FanEntry[] = []
    const old: FanEntry[] = []
    for (let i = 0; i < all.length; i++) {
      if (all[i].dateLabel >= today) {
        up.push(all[i])
      } else {
        old.push(all[i])
      }
    }
    this.upcoming = up
    this.past = old
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
          CourtDetailNav.closeFanCalendar()
        })
        Text('赛事日历')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('添加')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => {
            CourtDetailNav.openFanEditor(FanKind.EVENT, '')
          })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

      Text('手动排期，不拉实时赛程、不申请日历权限')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.upcoming.length === 0 && this.past.length === 0) {
        AppEmpty({
          title: '还没有观赛计划',
          description: '添加一场关注赛事，或从比赛清单 / 观赛记录带入日期',
          actionLabel: '添加关注赛事',
          onAction: (): void => {
            CourtDetailNav.openFanEditor(FanKind.EVENT, '')
          }
        }).padding(Theme.space.pageX)
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text('近期安排')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (this.upcoming.length === 0) {
              Text('近期暂无排期')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            } else {
              ForEach(this.upcoming, (e: FanEntry) => {
                this.CalRow(e)
              }, (e: FanEntry) => e.id)
            }
            Text('过往')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.past, (e: FanEntry) => {
              this.CalRow(e)
            }, (e: FanEntry) => `p_${e.id}`)
            AppButton({
              label: '添加关注赛事',
              onTap: (): void => {
                CourtDetailNav.openFanEditor(FanKind.EVENT, '')
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
  CalRow(e: FanEntry) {
    Row({ space: Theme.space.s3 }) {
      Image(CourtMedia.byKey(FanKind.coverOf(e.kind)))
        .width(52)
        .height(52)
        .borderRadius(Theme.radius.md)
        .objectFit(ImageFit.Cover)
      Column({ space: 4 }) {
        Text(e.dateLabel)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
        Text(e.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .maxLines(1)
        Text(FanKind.titleOf(e.kind))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => {
      CourtDetailNav.openFanDetail(e.id)
    })
  }
}
