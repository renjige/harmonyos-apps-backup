import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { YunSandboxImage } from '../components/yun/YunSandboxImage'
import { YunTimelineGroupView } from '../components/yun/YunTimelineGroup'
import {
  YunAlbumGroup,
  YunAnniversaryItem,
  YunMonthlyReview,
  YunNoteItem,
  YunTimelineGroup
} from '../models/YunModels'
import { YunDateHelper, YunLocalStore } from '../services/YunLocalStore'
import { YunDetailNav } from '../services/YunDetailNav'

@Component
export struct ReviewHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State segment: number = 0
  @State groups: YunAlbumGroup[] = []
  @State timelineGroups: YunTimelineGroup[] = []
  @State anniversaries: YunAnniversaryItem[] = []
  @State groupByYear: boolean = false
  @State review: YunMonthlyReview = new YunMonthlyReview()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.groups = await YunLocalStore.groupAlbumNotes(this.groupByYear)
    this.anniversaries = await YunLocalStore.loadAnniversaries()
    this.review = await YunLocalStore.buildMonthlyReview()
    const allTimeline = await YunLocalStore.groupNotesByDate()
    const limited: YunTimelineGroup[] = []
    for (let i = 0; i < allTimeline.length && i < 10; i++) {
      limited.push(allTimeline[i])
    }
    this.timelineGroups = limited
  }

  private toggleGroupMode(): void {
    this.groupByYear = !this.groupByYear
    void this.reload()
  }

  @Builder
  SegmentBar() {
    Row({ space: Theme.space.s2 }) {
      Text('主题册')
        .fontSize(Theme.type.caption)
        .fontWeight(this.segment === 0 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.segment === 0 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor(this.segment === 0 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.segment = 0 })
      Text('月度回顾')
        .fontSize(Theme.type.caption)
        .fontWeight(this.segment === 1 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.segment === 1 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor(this.segment === 1 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.segment = 1 })
      Text('时光')
        .fontSize(Theme.type.caption)
        .fontWeight(this.segment === 2 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.segment === 2 ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor(this.segment === 2 ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.pill)
        .onClick((): void => { this.segment = 2 })
    }
    .width('100%')
  }

  @Builder
  AnniversaryCard(item: YunAnniversaryItem) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Text(item.dateKey)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column() {
        Text(`${YunDateHelper.daysUntil(item.dateKey, item.yearly)}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
        Text('天后')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  PhotoTile(note: YunNoteItem) {
    Stack({ alignContent: Alignment.BottomStart }) {
      YunSandboxImage({ srcPath: note.imagePaths[0], squareFill: true, radius: Theme.radius.sm })
      if (note.title.length > 0) {
        Text(note.title)
          .fontSize(Theme.type.caption)
          .fontColor('#FFFFFF')
          .maxLines(1)
          .padding({ left: 6, right: 6, top: 4, bottom: 4 })
          .width('100%')
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.65)', 1]]
          })
      }
    }
    .onClick((): void => { YunDetailNav.openNote(note.id) })
  }

  @Builder
  AlbumSegment() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text(this.groupByYear ? '按年' : '按月')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.toggleGroupMode() })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      if (this.anniversaries.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('纪念日倒计时')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)
          ForEach(this.anniversaries, (a: YunAnniversaryItem) => {
            this.AnniversaryCard(a)
          }, (a: YunAnniversaryItem) => a.id)
        }
        .width('100%')
      }

      if (this.groups.length === 0) {
        AppEmpty({
          title: '相册还是空的',
          description: '在札记中添加照片，它们会出现在这里',
          actionLabel: '去写札记',
          onAction: (): void => { YunDetailNav.openNoteEditor('') }
        })
      } else {
        ForEach(this.groups, (g: YunAlbumGroup) => {
          Column({ space: Theme.space.s3 }) {
            Text(g.displayLabel)
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(g.notes, (note: YunNoteItem) => {
                Column() {
                  this.PhotoTile(note)
                }
                .width('31%')
                .aspectRatio(1)
                .clip(true)
                .borderRadius(Theme.radius.sm)
                .margin({ right: '2%', bottom: Theme.space.s2 })
              }, (note: YunNoteItem) => note.id)
            }
            .width('100%')
          }
          .width('100%')
        }, (g: YunAlbumGroup) => g.groupKey)
      }
    }
    .width('100%')
  }

  @Builder
  MonthlyReviewSegment() {
    Column({ space: Theme.space.s4 }) {
      Column({ space: Theme.space.s2 }) {
        Text('本月回忆册')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandDeep)
        Text(this.review.summary)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .lineHeight(20)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Row({ space: Theme.space.s4 }) {
        Column({ space: 4 }) {
          Text(`${this.review.noteCount}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('札记')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(`${this.review.photoCount}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('照片')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(`${this.review.checkinCount}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().brandPrimary)
          Text('打卡')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.cardPadding)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)

      if (this.review.topTag.length > 0) {
        Text(`本月常写标签：${this.review.topTag}`)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
      }
    }
    .width('100%')
  }

  @Builder
  TimelineSegment() {
    Column({ space: Theme.space.s4 }) {
      if (this.timelineGroups.length === 0) {
        AppEmpty({
          title: '还没有时光记录',
          description: '写下札记后，这里会按日期归档展示',
          actionLabel: '写札记',
          onAction: (): void => { YunDetailNav.openNoteEditor('') }
        })
      } else {
        ForEach(this.timelineGroups, (g: YunTimelineGroup) => {
          YunTimelineGroupView({ group: g })
        }, (g: YunTimelineGroup) => g.dateKey)
      }
    }
    .width('100%')
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text('回顾与沉淀')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)

        this.SegmentBar()

        if (this.segment === 0) {
          this.AlbumSegment()
        } else if (this.segment === 1) {
          this.MonthlyReviewSegment()
        } else {
          this.TimelineSegment()
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Theme.colors().surfacePage)
  }
}
