import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { SymbolHero } from '../design-system/SymbolVisual'
import { WisdomItem } from '../../models/WisdomHallModels'
import { WisdomHallBizService } from '../../services/WisdomHallBizService'
import { WisdomHallNav } from '../../services/WisdomHallNav'

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
      title: '每日一问',
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
            SymbolHero({
              category: '思辨',
              coverKey: 'cover_topic_daily',
              bannerHeight: 200,
              overline: '✨ 每日一问',
              title: this.item.title
            })
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

            Text(this.item.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(28)
              .width('100%')
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: '记录思考',
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
