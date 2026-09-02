import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { EssayItem, UserRecordItem } from '../models/InkModels'
import { InkBizService } from '../services/InkBizService'
import { InkDetailNav } from '../services/InkDetailNav'
import { InkMedia } from '../services/InkMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct CirclePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  @State essays: EssayItem[] = []
  @State reviews: UserRecordItem[] = []
  @State checkins: UserRecordItem[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.essays = await InkBizService.loadEssays()
    if (AuthService.isLoggedIn()) {
      this.reviews = await InkBizService.loadReviews()
      this.checkins = await InkBizService.loadCheckins()
    } else {
      this.reviews = []
      this.checkins = []
    }
    this.loading = false
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Text('文友圈')
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.banner_tea'))
            .width('100%')
            .height(140)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,46,0)', 0.2], ['rgba(26,26,46,0.78)', 1]]
            })
          Text('精选笺来自小筑，书评与打卡只属于你。')
            .fontSize(Theme.type.footnote)
            .fontColor('#F4EFE4')
            .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s3 })
        }
        .width('100%')
        .borderRadius(Theme.radius.card)
        .clip(true)

        Text('机构精选笺')
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        if (this.loading) {
          AppEmpty({ title: '正在展开笺页…', description: '' })
        } else if (this.essays.length === 0) {
          AppEmpty({ title: '暂无精选笺', description: '请稍后重试。' })
        } else {
          ForEach(this.essays, (e: EssayItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(InkMedia.resource(e.coverKey))
                .width(84)
                .height(84)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 6 }) {
                Text(e.title)
                  .fontSize(Theme.type.subtitleM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                Text(e.summary)
                  .fontSize(Theme.type.footnote)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .maxLines(2)
                  .width('100%')
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.card)
            .onClick((): void => { InkDetailNav.openEssay(e.id) })
          }, (e: EssayItem) => e.id)
        }

        Row() {
          Text('我的书评')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
          AppButton({
            label: '写书评',
            variant: 'secondary',
            onTap: (): void => {
              if (!AuthService.requireAuth('create_review')) {
                this.onRequireAuth()
                return
              }
              InkDetailNav.openEditor('review', '')
            }
          })
        }
        .width('100%')

        if (this.reviews.length === 0) {
          Text(AuthService.isLoggedIn() ? '还没有书评，读完精选笺再写一句。' : '登录后可写书评。')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        } else {
          ForEach(this.reviews, (r: UserRecordItem) => {
            Column({ space: 4 }) {
              Text(r.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(r.previewLine())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { InkDetailNav.openReview(r.id) })
          }, (r: UserRecordItem) => r.id)
        }

        Text(`读书打卡 ${this.checkins.length} 次`)
          .fontSize(Theme.type.subtitleS)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('在书摘详情里即可打卡；新用户列表为空。')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.pageY,
        bottom: Theme.space.s10
      })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
