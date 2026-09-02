import { Theme } from '../components/design-system/Theme'
import { PhotoGrid, PhotoViewerOverlay } from '../components/sport/PhotoGrid'
import { SportRecord } from '../models/SportRecord'
import { RecordStore } from '../services/RecordStore'
import { StatisticsUtil } from '../services/StatisticsUtil'

@Component
export struct GalleryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State photos: string[] = []
  @State monthSummary: string = ''
  @State viewerPath: string = ''
  @Prop reloadToken: number = 0
  @State lastToken: number = -1

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const list = await RecordStore.loadAll()
    this.photos = StatisticsUtil.allPhotos(list)
    const now = new Date()
    const monthList = StatisticsUtil.monthRecords(list, now.getFullYear(), now.getMonth() + 1)
    const monthPhotos = StatisticsUtil.allPhotos(monthList)
    this.monthSummary = `本月 ${monthList.length} 场 · ${monthPhotos.length} 张精彩瞬间`
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_monthly'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column() {
              Blank()
              Column({ space: 4 }) {
                Text('本月精彩时刻 ✨')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text(this.monthSummary)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0], ['rgba(26,26,46,0.85)', 1]]
              })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(140)

          Text('赛场瞬间墙')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)

          PhotoGrid({
            photos: this.photos,
            onPhotoTap: (index: number): void => {
              if (index >= 0 && index < this.photos.length) {
                this.viewerPath = this.photos[index]
              }
            }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .edgeEffect(EdgeEffect.Spring)

      if (this.viewerPath.length > 0) {
        PhotoViewerOverlay({
          photoPath: this.viewerPath,
          onClose: (): void => { this.viewerPath = '' }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reload()
      }
    })
  }
}
