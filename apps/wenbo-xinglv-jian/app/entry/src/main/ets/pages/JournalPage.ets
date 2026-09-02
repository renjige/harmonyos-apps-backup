import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { JournalEntry } from '../models/JournalModels'
import { JianMedia } from '../services/JianMedia'
import { TripStore } from '../services/TripStore'
import { TripNav } from '../services/TripNav'

@Component
export struct JournalPage {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop themeDark: boolean = false
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State gridMode: boolean = true
  @State items: JournalEntry[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = TripStore.allJournals()
  }

  build() {
    Column() {
      Row() {
        Text('旅迹')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
        Blank()
        Row({ space: 4 }) {
          Column() {
            AppIcon({
              name: 'grid',
              iconSize: Theme.icon.md,
              color: this.gridMode ?
                Theme.palette(this.themeDark || this.darkModeOn).brandPrimary :
                Theme.palette(this.themeDark || this.darkModeOn).textSecondary
            })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.gridMode = true })
          Column() {
            AppIcon({
              name: 'list',
              iconSize: Theme.icon.md,
              color: !this.gridMode ?
                Theme.palette(this.themeDark || this.darkModeOn).brandPrimary :
                Theme.palette(this.themeDark || this.darkModeOn).textSecondary
            })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.gridMode = false })
        }
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      if (this.items.length === 0) {
        Column() {
          Image(JianMedia.empty())
            .width('72%')
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          AppEmpty({
            title: '还没有记录',
            description: '出发吧，让每一段旅途都有迹可循',
            actionLabel: '写第一篇旅迹',
            onAction: (): void => { TripNav.openJournalCreate() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.gridMode) {
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
            ForEach(this.items, (j: JournalEntry) => {
              Column({ space: 6 }) {
                Stack({ alignContent: Alignment.BottomStart }) {
                  Image(JianMedia.cover(j.coverKey))
                    .width('100%')
                    .height(140)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.md)
                  Column()
                    .width('100%')
                    .height(56)
                    .linearGradient({
                      angle: 180,
                      colors: [[Theme.heroScrimTop(this.darkModeOn), 0], [Theme.heroScrimBottom(this.darkModeOn), 1]]
                    })
                    .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
                  Text(j.tagLabel())
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                    .margin({ left: 10, bottom: 8 })
                }
                Text(j.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${j.recordDate} · ${j.location.length > 0 ? j.location : '未标注地点'}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                  .maxLines(1)
              }
              .width('48%')
              .margin({ bottom: Theme.space.s4 })
              .onClick((): void => { TripNav.openJournalDetail(j.id) })
            }, (j: JournalEntry) => j.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 88 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (j: JournalEntry) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  Text(j.recordDate.slice(5))
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.palette(this.darkModeOn).brandAccent)
                  Text(j.recordDate.slice(0, 4))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.palette(this.darkModeOn).textTertiary)
                }
                .width(52)
                Column({ space: 4 }) {
                  Text(j.title)
                    .fontSize(Theme.type.subtitleM)
                    .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                    .maxLines(1)
                  Text(j.body.length > 0 ? j.body : '暂无正文')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.palette(this.darkModeOn).textTertiary })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => { TripNav.openJournalDetail(j.id) })
            }, (j: JournalEntry) => j.id)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 88 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.palette(this.themeDark || this.darkModeOn).surfacePage)
  }
}
