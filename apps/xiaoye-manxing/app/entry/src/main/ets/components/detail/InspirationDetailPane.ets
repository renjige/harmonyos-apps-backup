import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { InspirationItem } from '../../models/WanderModels'
import { WanderBizService } from '../../services/WanderBizService'
import { WanderDetailNav } from '../../services/WanderDetailNav'
import { WanderMedia } from '../../services/WanderMedia'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onItemIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await WanderBizService.findInspiration(this.itemId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      AppLoading({ label: '展开这一页' })
    } else if (this.item === undefined) {
      DetailShell({ title: '灵感', onClose: () => WanderDetailNav.close() }) {
        AppEmpty({ title: '这一页被风吹走了', description: '换一条灵感看看', actionLabel: '返回', onAction: () => WanderDetailNav.close() })
      }
    } else {
      DetailShell({ title: this.item.title, onClose: () => WanderDetailNav.close() }) {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(WanderMedia.resource(this.item.coverKey))
              .width('100%')
              .height(240)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(36,53,43,0)', 0.0], ['rgba(36,53,43,0.76)', 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F6F1E8')
              .padding(20)
          }
          .width('100%')
          .height(240)
          .clip(true)

          Column({ space: 10 }) {
            Text(this.item.subtitle)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .alignItems(HorizontalAlign.Start)

          AppButton({
            label: '去看今日漫行',
            variant: 'primary',
            onTap: (): void => WanderDetailNav.close()
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')
      }
    }
  }
}
