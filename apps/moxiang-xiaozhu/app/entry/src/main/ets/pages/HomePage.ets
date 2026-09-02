import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { ExcerptItem } from '../models/InkModels'
import { InkBizService } from '../services/InkBizService'
import { InkDetailNav } from '../services/InkDetailNav'
import { InkMedia } from '../services/InkMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '墨香小筑'
  @Prop tagline: string = '读今日书摘，写下墨迹，在小筑与文友打卡。'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State today: ExcerptItem = new ExcerptItem()
  @State quotes: ExcerptItem[] = []
  @State hasToday: boolean = false
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const list = await InkBizService.loadExcerpts()
    this.today = InkBizService.pickDaily(list)
    this.hasToday = this.today.id.length > 0
    this.quotes = list
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.hero_ink'))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,46,0)', 0.18], ['rgba(26,26,46,0.84)', 1]]
            })
          Column({ space: 6 }) {
            Text(this.appName)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor('#F4EFE4')
            Text(this.tagline)
              .fontSize(Theme.type.footnote)
              .fontColor('#E8D5A3')
              .maxLines(2)
          }
          .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
        }
        .width('100%')
        .borderRadius(Theme.radius.card)
        .clip(true)

        if (this.loading) {
          AppEmpty({ title: '正在铺开今日书摘…', description: '' })
        } else if (!this.hasToday) {
          AppEmpty({
            title: '暂无书摘',
            description: '请检查网络后重试。',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            Text('今日书摘')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(InkMedia.resource(this.today.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(180)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.2], ['rgba(26,26,46,0.8)', 1]]
                })
              Column({ space: 4 }) {
                Text(this.today.source)
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8D5A3')
                Text(this.today.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE4')
                Text(this.today.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor('#F4EFE4')
                  .maxLines(2)
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .onClick((): void => { InkDetailNav.openExcerpt(this.today.id) })

            AppButton({
              label: '读今日书摘',
              variant: 'primary',
              onTap: (): void => { InkDetailNav.openExcerpt(this.today.id) }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Text('经典名句')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Scroll() {
            Row({ space: Theme.space.s3 }) {
              ForEach(this.quotes, (q: ExcerptItem) => {
                Column({ space: 8 }) {
                  Image(InkMedia.resource(q.coverKey))
                    .width(148)
                    .height(100)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(Theme.radius.sm)
                  Text(q.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(1)
                    .width(148)
                  Text(q.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width(148)
                }
                .width(148)
                .onClick((): void => { InkDetailNav.openExcerpt(q.id) })
              }, (q: ExcerptItem) => q.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')

          Column({ space: 6 }) {
            Text('进入智慧书房')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('按阅读气质匹配主题书单，不做生成式对话。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppButton({
              label: '去书房匹配',
              variant: 'secondary',
              onTap: (): void => { InkDetailNav.switchTab(1) }
            })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
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
