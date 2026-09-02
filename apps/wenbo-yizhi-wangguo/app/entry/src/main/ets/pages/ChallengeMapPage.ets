import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CatalogItem } from '../models/KingdomModels'
import { KingdomBizService } from '../services/KingdomBizService'
import { KingdomDetailNav } from '../services/KingdomDetailNav'
import { KingdomMedia } from '../services/KingdomMedia'

@Component
export struct ChallengeMapPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @Prop levels: CatalogItem[] = []
  onLocked: () => void = () => {}

  onRefreshTokenChange(): void {
  }

  private openLevel(item: CatalogItem): void {
    if (!KingdomBizService.isUnlocked(item, this.levels)) {
      this.onLocked()
      return
    }
    KingdomDetailNav.open('level', item.id, '开始闯关')
  }

  private nodeColor(item: CatalogItem): string {
    if (KingdomBizService.levelDone(item.id)) {
      return Theme.colors().brandAccent
    }
    if (KingdomBizService.isUnlocked(item, this.levels)) {
      return Theme.colors().brandPrimary
    }
    return Theme.colors().textTertiary
  }

  build() {
    Column() {
      Text('智慧闯关')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s2
        })

      if (this.levels.length === 0) {
        AppEmpty({
          title: '路径还没铺好',
          description: '请检查网络后重试。题目来自王国题库，不会使用本机假关卡。',
          actionLabel: ''
        })
      } else {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(KingdomMedia.resource('hero_path'))
                .width('100%')
                .height(140)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(80)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.78)', 1]]
                })
              Text('沿石阶往前走，完成一关才会点亮下一关')
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
                .padding({ left: Theme.space.s5, right: Theme.space.s5, bottom: Theme.space.s4 })
            }
            .width('100%')
            .height(140)
            .borderRadius(Theme.radius.xl)
            .clip(true)

            ForEach(this.levels, (item: CatalogItem, idx: number) => {
              Row({ space: Theme.space.s4 }) {
                Column() {
                  if (!KingdomBizService.isUnlocked(item, this.levels)) {
                    AppIcon({ name: 'lock', iconSize: 22, color: Theme.colors().textSecondary })
                  } else if (KingdomBizService.levelDone(item.id)) {
                    AppIcon({ name: 'ai', iconSize: 22, color: this.nodeColor(item) })
                  } else {
                    AppIcon({ name: 'biz', iconSize: 22, color: this.nodeColor(item) })
                  }
                }
                .width(52)
                .height(52)
                .justifyContent(FlexAlign.Center)
                .borderRadius(26)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .border({
                  width: KingdomBizService.isUnlocked(item, this.levels) &&
                    !KingdomBizService.levelDone(item.id) ? 2 : 0,
                  color: Theme.colors().brandAccent
                })

                Column({ space: 4 }) {
                  Text(`${idx + 1}. ${item.title}`)
                    .fontSize(Theme.type.subtitleS)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.subtitle.length > 0 ? item.subtitle : item.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                  if (KingdomBizService.levelDone(item.id)) {
                    Text(`星星 ${KingdomBizService.levelStars(item.id)}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .width('100%')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                AppIcon({
                  name: 'chevron',
                  iconSize: Theme.icon.sm,
                  color: Theme.colors().textSecondary
                })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .margin({ left: idx % 2 === 0 ? 0 : 20, right: idx % 2 === 0 ? 20 : 0 })
              .borderRadius(20)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .onClick(() => this.openLevel(item))
            }, (item: CatalogItem) => item.id)
          }
          .width('100%')
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
