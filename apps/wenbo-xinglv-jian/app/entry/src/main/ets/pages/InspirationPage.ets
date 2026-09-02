import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InspirationItem } from '../models/JournalModels'
import { JianMedia } from '../services/JianMedia'
import { TripStore } from '../services/TripStore'
import { TripNav } from '../services/TripNav'

@Component
export struct InspirationPage {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop themeDark: boolean = false
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State items: InspirationItem[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.items = TripStore.allInspirations()
  }

  build() {
    Column() {
      Row() {
        Text('灵感匣')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.palette(this.themeDark || this.darkModeOn).textPrimary)
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s3
      })

      Stack({ alignContent: Alignment.TopStart }) {
        Image(JianMedia.banner())
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        Column()
          .width('100%')
          .height(120)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .borderRadius(Theme.radius.lg)
          .linearGradient({
            angle: 180,
            colors: [[Theme.heroScrimTop(this.darkModeOn), 0], [Theme.heroScrimBottom(this.darkModeOn), 1]]
          })
        Column({ space: 4 }) {
          Text('收藏旅途灵感')
            .fontSize(Theme.type.subtitleL)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
          Text('想去的目的地与攻略片段，离线也能查看')
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
        }
        .align(Alignment.BottomStart)
        .margin({ left: Theme.space.pageX + 16, bottom: 16, right: Theme.space.pageX + 16 })
      }
      .width('100%')
      .height(120)
      .margin({ bottom: Theme.space.s4 })

      if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '灵感匣还是空的',
            description: '收藏一个想去的目的地，或保存一段攻略灵感',
            actionLabel: '添加灵感',
            onAction: (): void => { TripNav.openInspireCreate() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: InspirationItem) => {
              Row({ space: Theme.space.s3 }) {
                Column() {
                  AppIcon({
                    name: item.kind === 'snippet' ? 'book' : 'bookmark',
                    iconSize: Theme.icon.lg,
                    color: Theme.palette(this.darkModeOn).brandAccent
                  })
                }
                .width(44)
                .height(44)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(Theme.palette(this.darkModeOn).brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                Column({ space: 4 }) {
                  Row() {
                    Text(item.title)
                      .fontSize(Theme.type.subtitleM)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.palette(this.darkModeOn).textPrimary)
                      .layoutWeight(1)
                      .maxLines(1)
                    Text(item.kindLabel())
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.palette(this.darkModeOn).brandAccent)
                  }
                  .width('100%')
                  if (item.destination.length > 0) {
                    Text(item.destination)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.palette(this.darkModeOn).textSecondary)
                      .maxLines(1)
                  }
                  Text(item.body.length > 0 ? item.body : '点击查看详情')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.palette(this.darkModeOn).textTertiary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.palette(this.darkModeOn).textTertiary })
              }
              .width('100%')
              .padding(Theme.space.cardPadding)
              .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.card)
              .onClick((): void => { TripNav.openInspireDetail(item.id) })
            }, (item: InspirationItem) => item.id)
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
