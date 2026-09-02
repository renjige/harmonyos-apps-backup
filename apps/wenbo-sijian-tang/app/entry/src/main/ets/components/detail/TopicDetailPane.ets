import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { WisdomMedia } from '../../services/WisdomMedia'

@Component
export struct TopicDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State item: WisdomItem = new WisdomItem()
  @State loaded: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await WisdomHallBizService.findTopic(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private startThought(): void {
    WisdomHallNav.closeDetail()
    WisdomHallNav.openWriteWithPrefill(this.item.title, this.item.body)
  }

  build() {
    DetailShell({
      title: '今日思考',
      showFavorite: false,
      favorited: false,
      onClose: (): void => { WisdomHallNav.closeDetail() },
      onFavorite: (): void => {}
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '议题不存在', description: '' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(WisdomMedia.resource(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.28], ['rgba(26,26,46,0.78)', 1]]
                })
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F5F0E8')
                .maxLines(3)
                .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.item.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(28)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '开始写思录',
                variant: 'primary',
                onTap: (): void => { this.startThought() }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
      }
    }
  }
}
