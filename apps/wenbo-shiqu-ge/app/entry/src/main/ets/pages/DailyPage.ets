import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { DailyItem } from '../models/PavilionModels'
import { PavilionBizService } from '../services/PavilionBizService'
import { PavilionDetailNav } from '../services/PavilionDetailNav'
import { PavilionMedia } from '../services/PavilionMedia'
import { PavilionStore } from '../services/PavilionStore'

@Component
export struct DailyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State today: DailyItem = new DailyItem()
  @State list: DailyItem[] = []
  @State hasToday: boolean = false
  @State favorited: boolean = false
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.list = await PavilionBizService.loadDaily()
    this.today = PavilionBizService.pickToday(this.list)
    this.hasToday = this.today.id.length > 0
    if (this.hasToday) {
      this.favorited = PavilionStore.isFavorite(`daily:${this.today.id}`)
    }
    this.loading = false
  }

  private async toggleFavorite(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    this.favorited = await PavilionStore.toggleFavorite(`daily:${this.today.id}`)
  }

  build() {
    Column() {
      Text('每日一趣')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
      Text('每天一条，短读即可收藏')
        .fontSize(13)
        .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })

      if (!this.hasToday && !this.loading) {
        AppEmpty({
          title: '还没有每日一趣',
          description: '稍后再刷新，或先去首页读一篇。',
          actionLabel: '重新加载',
          onAction: (): void => { void this.reload() }
        })
      } else if (this.hasToday) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(PavilionMedia.resource(this.today.coverKey))
                .width('100%')
                .height(260)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(260)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(61,52,44,0)', 0.15], ['rgba(61,52,44,0.88)', 1]]
                })
              Column({ space: 8 }) {
                Text(this.today.dateKey)
                  .fontSize(13)
                  .fontColor('#F7F4F0')
                Text(this.today.title)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#F7F4F0')
                  .maxLines(3)
              }
              .padding(16)
            }
            .width('100%')
            .borderRadius(12)
            .clip(true)
            .onClick((): void => { PavilionDetailNav.openDaily(this.today.id) })

            Text(this.today.quote)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
              .lineHeight(30)
              .width('100%')

            AppButton({
              label: '阅读全文',
              onTap: (): void => { PavilionDetailNav.openDaily(this.today.id) }
            })
            AppButton({
              label: this.favorited ? '已收藏' : '收藏今日',
              variant: 'secondary',
              onTap: (): void => { void this.toggleFavorite() }
            })
            AppButton({
              label: '记下今日发现',
              variant: 'secondary',
              onTap: (): void => { PavilionDetailNav.openFinds() }
            })

            Text('往期')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
              .width('100%')
              .margin({ top: Theme.space.s2 })

            ForEach(this.list, (row: DailyItem) => {
              Row() {
                Text(row.dateKey)
                  .fontSize(13)
                  .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                  .width(96)
                Text(row.title)
                  .fontSize(16)
                  .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                  .maxLines(1)
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
              .borderRadius(8)
              .onClick((): void => { PavilionDetailNav.openDaily(row.id) })
            }, (row: DailyItem) => row.id)
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.pageBg(this.themeEpoch, this.darkModeOn))
  }
}
