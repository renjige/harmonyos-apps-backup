import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { RecapMonth, RecapSummary } from '../models/AlbumModels'
import { AlbumStore } from '../services/AlbumStore'
import { AlbumNav } from '../services/AlbumNav'

@Component
export struct RecapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  onBack: () => void = () => {}

  @State recap: RecapSummary = new RecapSummary()
  @State memoryCount: number = 0

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshChange(): void {
    this.reload()
  }

  private reload(): void {
    this.recap = AlbumStore.recap()
    this.memoryCount = AlbumStore.memoryToday().length
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onBack() })
        Text('家庭年册')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
          .margin({ left: Theme.space.s2 })
      }
      .width('100%')
      .height(48)
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

      Scroll() {
        Column() {
          Image($r('app.media.banner_02'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.card)

          Text('把家庭瞬间收成一册：按月份、地点、珍藏继续整理，不只是流水账。')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .margin({ top: Theme.space.s4 })
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(`${this.recap.photoCount}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('全部照片')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { AlbumNav.openFilter('all', '') })

            Column() {
              Text(`${this.recap.favoriteCount}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('珍藏')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { AlbumNav.openFilter('favorite', '') })
          }
          .width('100%')
          .margin({ top: Theme.space.s4 })

          Row({ space: Theme.space.s3 }) {
            Column() {
              Text(`${this.recap.locationCount}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('地点册')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { AlbumNav.openFilter('place', '') })

            Column() {
              Text(`${this.recap.thisMonth}`)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              Text('本月')
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            }
            .layoutWeight(1)
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { AlbumNav.openFilter('time', '') })
          }
          .width('100%')
          .margin({ top: Theme.space.s3 })

          Text(`往年的今天：${this.memoryCount} 张`)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ top: Theme.space.s5 })
            .width('100%')

          Text('月份分布')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .margin({ top: Theme.space.s5, bottom: Theme.space.s3 })
            .width('100%')

          ForEach(this.recap.months, (row: RecapMonth) => {
            Row() {
              Text(row.label)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .layoutWeight(1)
              Text(`${row.count} 张`)
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .margin({ bottom: Theme.space.s2 })
          }, (row: RecapMonth) => row.label)

          AppButton({
            label: '继续上传家庭照片',
            onTap: (): void => {
              this.onBack()
              AlbumNav.openUpload()
            }
          })
            .margin({ top: Theme.space.s6 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
