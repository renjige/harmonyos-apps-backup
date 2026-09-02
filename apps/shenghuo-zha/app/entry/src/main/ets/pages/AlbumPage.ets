import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { LifeSandboxImage } from '../components/life/LifeSandboxImage'
import { LifeAlbumGroup, LifeAnniversaryItem, LifeMonthlyReview, LifeNoteItem } from '../models/LifeModels'
import { LifeDateHelper, LifeLocalStore } from '../services/LifeLocalStore'
import { LifeDetailNav } from '../services/LifeDetailNav'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State groups: LifeAlbumGroup[] = []
  @State anniversaries: LifeAnniversaryItem[] = []
  @State groupByYear: boolean = false
  @State review: LifeMonthlyReview = new LifeMonthlyReview()

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.groups = await LifeLocalStore.groupAlbumNotes(this.groupByYear)
    this.anniversaries = await LifeLocalStore.loadAnniversaries()
    this.review = await LifeLocalStore.buildMonthlyReview()
  }

  private toggleGroupMode(): void {
    this.groupByYear = !this.groupByYear
    void this.reload()
  }

  @Builder
  AnniversaryCard(item: LifeAnniversaryItem) {
    Row({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(item.dateKey)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column() {
        Text(`${LifeDateHelper.daysUntil(item.dateKey, item.yearly)}`)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text('天后')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      }
    }
    .width('100%')
    .padding(Theme.space.cardPadding)
    .backgroundColor(Theme.colors().brandPrimaryContainer)
    .borderRadius(Theme.radius.md)
  }

  @Builder
  PhotoTile(note: LifeNoteItem) {
    Stack({ alignContent: Alignment.BottomStart }) {
      LifeSandboxImage({ srcPath: note.imagePaths[0], squareFill: true, radius: Theme.radius.sm })
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
    .onClick((): void => { LifeDetailNav.openNote(note.id) })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Text('时光相册')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          Text(this.groupByYear ? '按年' : '按月')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => { this.toggleGroupMode() })
        }
        .width('100%')

        Column({ space: Theme.space.s2 }) {
          Text('本月回忆册')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().brandDeep)
          Text(this.review.summary)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .lineHeight(20)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .border({ width: 1, color: Theme.colors().strokeHairline })

        if (this.anniversaries.length > 0) {
          Column({ space: Theme.space.s2 }) {
            Text('纪念日倒计时')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().brandDeep)
            ForEach(this.anniversaries, (a: LifeAnniversaryItem) => {
              this.AnniversaryCard(a)
            }, (a: LifeAnniversaryItem) => a.id)
          }
          .width('100%')
        }

        if (this.groups.length === 0) {
          AppEmpty({
            title: '相册还是空的',
            description: '在札记中添加照片，它们会出现在这里',
            actionLabel: '去写札记',
            onAction: (): void => { LifeDetailNav.openNoteEditor('') }
          })
        } else {
          ForEach(this.groups, (g: LifeAlbumGroup) => {
            Column({ space: Theme.space.s3 }) {
              Text(g.displayLabel)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(g.notes, (note: LifeNoteItem) => {
                  Column() {
                    this.PhotoTile(note)
                  }
                  .width('31%')
                  .aspectRatio(1)
                  .clip(true)
                  .borderRadius(Theme.radius.sm)
                  .margin({ right: '2%', bottom: Theme.space.s2 })
                }, (note: LifeNoteItem) => note.id)
              }
              .width('100%')
            }
            .width('100%')
          }, (g: LifeAlbumGroup) => g.groupKey)
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
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
