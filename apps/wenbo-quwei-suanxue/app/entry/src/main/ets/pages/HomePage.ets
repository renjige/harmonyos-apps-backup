import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { MathMedia } from '../services/MathMedia'
import { MathBizService } from '../services/MathBizService'
import { MathLocalStore } from '../services/MathLocalStore'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State done: number = 0
  @State total: number = 10
  @State stars: number = 0
  @State accuracy: number = 0
  onStartDaily: () => void = () => {}
  onQuick: (mode: string) => void = (_m: string) => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.total = MathLocalStore.settings().dailyCount
    const sess = MathBizService.todaySession()
    this.done = sess !== undefined ? sess.total : 0
    this.stars = MathBizService.todayStars()
    this.accuracy = MathBizService.todayAccuracy()
  }

  private greet(): string {
    const h = new Date().getHours()
    if (h < 11) {
      return '早上好，小算术家 👋'
    }
    if (h < 18) {
      return '下午好，小算术家'
    }
    return '晚上好，小算术家'
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Column({ space: Theme.space.s2 }) {
          Text('趣味算学')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.greet())
            .fontSize(Theme.type.subtitleM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .padding({ top: Theme.space.s2 })
        .width('100%')

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(MathMedia.resource('hero_desk'))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(160)
            .linearGradient({
              angle: 180,
              colors: [['rgba(23,32,51,0)', 0], ['rgba(23,32,51,0.78)', 1]]
            })
          Column({ space: Theme.space.s3 }) {
            Text('今日智慧挑战')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`${this.total} 道计算题`)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`${this.done} / ${this.total}`)
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
              .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Row().width('100%').height(6).backgroundColor('rgba(255,255,255,0.28)').borderRadius(99)
              Row()
                .width(`${this.total > 0 ? Math.floor((this.done / this.total) * 100) : 0}%`)
                .height(6)
                .backgroundColor('#F5A623')
                .borderRadius(99)
            }
            .width('100%')
            .height(6)
            AppButton({
              label: '开始挑战',
              onTap: () => this.onStartDaily()
            })
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          .width('100%')
        }
        .width('100%')
        .height(280)
        .borderRadius(Theme.radius.sheet)
        .clip(true)

        Column({ space: Theme.space.s3 }) {
          Text('今日表现')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            this.statCard('获得星星', `${this.stars}`)
            this.statCard('今日正确率', this.done > 0 ? `${this.accuracy}%` : '—')
          }
          .width('100%')
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('快速练习')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            this.quick('加法', 'add', 'cover_add')
            this.quick('减法', 'sub', 'cover_sub')
            this.quick('混合', 'mix', 'cover_mix')
          }
          .width('100%')
        }
        .width('100%')

        Image(MathMedia.resource('hero_paper'))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
      .constraintSize({ maxWidth: 720 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  statCard(label: string, value: string) {
    Column({ space: Theme.space.s1 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(value)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
    }
    .layoutWeight(1)
    .padding(Theme.space.s4)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
  }

  @Builder
  quick(label: string, mode: string, cover: string) {
    Column({ space: Theme.space.s2 }) {
      Image(MathMedia.resource(cover))
        .width('100%')
        .height(72)
        .objectFit(ImageFit.Cover)
        .borderRadius(Theme.radius.md)
      Text(label)
        .fontSize(Theme.type.footnote)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
    }
    .layoutWeight(1)
    .onClick(() => this.onQuick(mode))
  }
}
