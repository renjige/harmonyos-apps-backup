import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { ExcerptItem } from '../models/RoamModels'
import { RoamBizService } from '../services/RoamBizService'
import { RoamDetailNav } from '../services/RoamDetailNav'
import { RoamMedia } from '../services/RoamMedia'
import { RoamStore } from '../services/RoamStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop appName: string = '书页漫游'
  @Prop tagline: string = '在书页间漫游，发现属于你的阅读风景。'
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State today: ExcerptItem = new ExcerptItem()
  @State hasToday: boolean = false
  @State favorited: boolean = false
  @State readLater: boolean = false
  @State finished: boolean = false
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const list = await RoamBizService.loadExcerpts()
    this.today = RoamBizService.pickDailyExcerpt(list)
    this.hasToday = this.today.id.length > 0
    if (this.hasToday) {
      this.favorited = RoamStore.isFavorite(this.today.id)
      this.readLater = RoamStore.isReadLater(this.today.id)
      this.finished = RoamStore.isFinished(this.today.id)
    }
    this.loading = false
  }

  private openToday(): void {
    if (!this.hasToday) {
      return
    }
    RoamDetailNav.openExcerpt(this.today.id)
  }

  private async toggleFavorite(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    await RoamStore.toggleFavorite(this.today.id, this.today.bookTitle, this.today.theme)
    void this.reload()
  }

  private async toggleReadLater(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    await RoamStore.toggleReadLater(this.today.id, this.today.bookTitle, this.today.theme)
    void this.reload()
  }

  private async markFinished(): Promise<void> {
    if (!this.hasToday) {
      return
    }
    await RoamStore.markFinished(this.today.id, this.today.bookTitle, this.today.theme)
    void this.reload()
  }

  @Builder
  MiniAction(label: string, onTap: () => void) {
    Text(label)
      .fontSize(Theme.type.caption)
      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.pill)
      .onClick((): void => { onTap() })
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text(this.appName)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Text('今日，在书页间停驻片刻')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Text(this.tagline)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .lineHeight(24)
          .width('100%')

        if (this.loading) {
          AppEmpty({ title: '正在加载今日节选…', description: '' })
        } else if (!this.hasToday) {
          AppEmpty({
            title: '暂无节选内容',
            description: '请检查网络后下拉刷新。',
            actionLabel: '重试',
            onAction: (): void => { void this.reload() }
          })
        } else {
          Column({ space: Theme.space.s3 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(RoamMedia.resource(this.today.coverKey))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(45,74,62,0)', 0.28], ['rgba(45,74,62,0.76)', 1]]
                })
              Column({ space: 6 }) {
                Text('每日一书')
                  .fontSize(Theme.type.caption)
                  .fontColor('#F4EFE6')
                Text(this.today.theme)
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8DFD0')
                Text(this.today.bookTitle)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F4EFE6')
                  .maxLines(2)
                Text(this.today.author)
                  .fontSize(Theme.type.footnote)
                  .fontColor('#E8DFD0')
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .onClick((): void => { this.openToday() })

            Text(this.today.summaryLine())
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')

            Row({ space: Theme.space.s2 }) {
              this.MiniAction(this.favorited ? '已收藏' : '收藏', (): void => { void this.toggleFavorite() })
              this.MiniAction(this.readLater ? '已稍后读' : '稍后读', (): void => { void this.toggleReadLater() })
              this.MiniAction(this.finished ? '已读完' : '标记读完', (): void => { void this.markFinished() })
            }
            .width('100%')

            AppButton({
              label: '展开阅读',
              variant: 'primary',
              onTap: (): void => { this.openToday() }
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
