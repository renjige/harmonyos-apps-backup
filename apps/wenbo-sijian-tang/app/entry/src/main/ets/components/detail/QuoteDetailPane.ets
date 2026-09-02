import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'
import { WisdomMedia } from '../../services/WisdomMedia'

@Component
export struct QuoteDetailPane {
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
    const found = await WisdomHallBizService.findQuote(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.loaded = true
    }
  }

  private writeThought(): void {
    WisdomHallNav.closeDetail()
    const prefill = `${this.item.title}\n\n—— ${this.item.authorName}`
    WisdomHallNav.openWriteWithPrefill(this.item.title, prefill)
  }

  build() {
    DetailShell({
      title: '今日慧语',
      showFavorite: false,
      favorited: false,
      onClose: (): void => { WisdomHallNav.closeDetail() },
      onFavorite: (): void => {}
    }) {
      if (!this.loaded) {
        AppEmpty({ title: '慧语不存在', description: '' })
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(WisdomMedia.resource(this.item.coverKey))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,26,46,0)', 0.28], ['rgba(26,26,46,0.78)', 1]]
                })
              Column({ space: 6 }) {
                Text(this.item.authorName.length > 0 ? this.item.authorName : '先贤')
                  .fontSize(Theme.type.caption)
                  .fontColor('#C9A84C')
                Text(this.item.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#F5F0E8')
                  .maxLines(4)
              }
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
            }
            .width('100%')
            .borderRadius(Theme.radius.card)
            .clip(true)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.item.summary.length > 0 ? this.item.summary : this.item.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(28)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '写入思录',
                variant: 'primary',
                onTap: (): void => { this.writeThought() }
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
