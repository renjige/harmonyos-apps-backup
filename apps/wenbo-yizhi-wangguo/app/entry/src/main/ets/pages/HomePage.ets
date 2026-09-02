import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CatalogItem } from '../models/KingdomModels'
import { KingdomBizService } from '../services/KingdomBizService'
import { KingdomDetailNav } from '../services/KingdomDetailNav'
import { KingdomMedia } from '../services/KingdomMedia'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop levels: CatalogItem[] = []
  @Prop dailies: CatalogItem[] = []
  @Prop guides: CatalogItem[] = []
  @StorageLink('currentUsername') currentUsername: string = ''
  @State stars: number = 0
  @State dailyDone: boolean = false
  onStepStone: () => void = () => {}
  onOpenChallenge: () => void = () => {}
  onOpenDaily: () => void = () => {}
  onOpenReport: () => void = () => {}
  onOpenCollection: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.stars = KingdomBizService.growth().stars
    this.dailyDone = KingdomBizService.isDailyDone()
  }

  private greet(): string {
    const name = this.currentUsername.length > 0 ? this.currentUsername : '小探索者'
    const h = new Date().getHours()
    if (h < 11) {
      return `早上好，${name}`
    }
    if (h < 18) {
      return `下午好，${name}`
    }
    return `晚上好，${name}`
  }

  private nextLevel(): CatalogItem {
    return KingdomBizService.nextPlayable(this.levels)
  }

  private openGuide(item: CatalogItem): void {
    KingdomDetailNav.open('guide', item.id, '踏上石阶')
  }

  private tapPortal(kind: string): void {
    if (kind === 'challenge') {
      this.onOpenChallenge()
      return
    }
    if (kind === 'daily') {
      this.onOpenDaily()
      return
    }
    if (kind === 'report') {
      this.onOpenReport()
      return
    }
    this.onOpenCollection()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s6 }) {
        Column({ space: Theme.space.s2 }) {
          Text('益智王国')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.greet())
            .fontSize(Theme.type.subtitleM)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding({ top: Theme.space.s2 })

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(KingdomMedia.resource('hero_hall'))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(140)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.82)', 1]]
            })
          Column({ space: Theme.space.s2 }) {
            Text('下一座石阶')
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(this.nextLevel().title.length > 0 ? this.nextLevel().title : '关卡加载中')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
            Text(`已点亮 ${this.stars} 颗星星`)
              .fontSize(Theme.type.footnote)
              .fontColor('#FFFFFF')
              .width('100%')
            AppButton({ label: '踏上石阶', onTap: () => this.onStepStone() })
          }
          .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s5 })
          .width('100%')
        }
        .width('100%')
        .height(240)
        .borderRadius(Theme.radius.xl)
        .clip(true)

        Column({ space: Theme.space.s3 }) {
          Text('王国入口')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s4 }) {
            this.Portal('智慧闯关', 'cover_shape', 'challenge')
            this.Portal(this.dailyDone ? '每日益智已完成' : '每日益智', 'cover_daily', 'daily')
          }
          .width('100%')
          Row({ space: Theme.space.s4 }) {
            this.Portal('成长报告', 'hero_path', 'report')
            this.Portal('收藏馆', 'relic_crown', 'collect')
          }
          .width('100%')
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          Text('王国手札')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.guides.length === 0) {
            AppEmpty({
              title: '手札还在路上',
              description: '连接王国后会出现说明。可先点踏上石阶试一关。',
              actionLabel: '踏上石阶',
              onAction: () => this.onStepStone()
            })
          } else {
            ForEach(this.guides, (item: CatalogItem) => {
              Row({ space: Theme.space.s4 }) {
                Image(KingdomMedia.resource(item.coverKey))
                  .width(72)
                  .height(72)
                  .borderRadius(16)
                  .objectFit(ImageFit.Cover)
                Column({ space: 4 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textSecondary })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .borderRadius(20)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .onClick(() => this.openGuide(item))
            }, (item: CatalogItem) => item.id)
          }
        }
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
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Portal(title: string, cover: string, kind: string) {
    Column({ space: Theme.space.s2 }) {
      Image(KingdomMedia.resource(cover))
        .width(88)
        .height(88)
        .borderRadius(44)
        .objectFit(ImageFit.Cover)
      Text(title)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .textAlign(TextAlign.Center)
        .maxLines(2)
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s4, bottom: Theme.space.s4 })
    .borderRadius(24)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .onClick(() => this.tapPortal(kind))
  }
}
