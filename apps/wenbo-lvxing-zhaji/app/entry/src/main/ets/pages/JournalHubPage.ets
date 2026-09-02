import { Theme } from '../components/design-system/Theme'
import { JournalPage } from './JournalPage'
import { AlbumPage } from './AlbumPage'

/** 札记 Tab：日记 + 相册 Segment */
@Component
export struct JournalHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') journalCreateTrigger: number = 0
  @Prop @Watch('onAlbumCreateTriggerChange') albumCreateTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop segment: number = 0
  onRequireAuth: () => void = () => {}
  onDiaryCreated: () => void = () => {}
  onAlbumCreated: () => void = () => {}
  onSegmentChange: (index: number) => void = () => {}
  @State localSegment: number = 0

  aboutToAppear(): void {
    this.localSegment = this.segment
  }

  onCreateTriggerChange(): void {
    this.localSegment = 0
    this.onSegmentChange(0)
  }

  onAlbumCreateTriggerChange(): void {
    this.localSegment = 1
    this.onSegmentChange(1)
  }

  onRefreshTokenChange(): void {
    // AlbumPage 内部会 reload
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        this.SegmentChip('旅行日记', 0)
        this.SegmentChip('旅行相册', 1)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s2,
        bottom: Theme.space.s2
      })

      if (this.localSegment === 0) {
        JournalPage({
          createTrigger: this.journalCreateTrigger,
          onRequireAuth: (): void => { this.onRequireAuth() },
          onDiaryCreated: (): void => { this.onDiaryCreated() }
        }).layoutWeight(1)
      } else {
        AlbumPage({
          createTrigger: this.albumCreateTrigger,
          refreshToken: this.refreshToken,
          onRequireAuth: (): void => { this.onRequireAuth() },
          onAlbumCreated: (): void => { this.onAlbumCreated() }
        }).layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  SegmentChip(label: string, index: number) {
    Text(label)
      .fontSize(Theme.type.subhead)
      .fontWeight(this.localSegment === index ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.localSegment === index ?
        Theme.colors().brandPrimary : Theme.colors().textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.localSegment === index ?
        Theme.colors().brandPrimaryContainer : Theme.colors().surfaceSubtle)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => {
        this.localSegment = index
        this.onSegmentChange(index)
      })
  }
}
