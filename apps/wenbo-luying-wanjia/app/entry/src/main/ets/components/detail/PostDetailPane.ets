import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampMedia } from '../../services/CampMedia'
import { CatalogItem } from '../../models/CampModels'
import { DetailShell } from './DetailShell'

@Component
export struct PostDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') itemId: string = ''
  @Prop @Watch('onIdChange') refreshToken: number = 0
  @State item: CatalogItem | undefined = undefined
  @State loading: boolean = true

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.item = await CampBizService.findPost(this.itemId)
    this.loading = false
  }

  build() {
    if (this.loading) {
      Column() {
        AppLoading({ label: '打开攻略' })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    } else if (this.item === undefined) {
      DetailShell({ title: '攻略', onClose: () => CampDetailNav.close() }) {
        AppEmpty({ title: '攻略不存在', actionLabel: '返回', onAction: () => CampDetailNav.close() })
      }
    } else {
      DetailShell({ title: this.item.title, onClose: () => CampDetailNav.close() }) {
        Column({ space: Theme.space.s5 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(CampMedia.resource(this.item !== undefined ? this.item.coverKey : 'guide_tent'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(22,51,24,0)', 0.0], ['rgba(22,51,24,0.78)', 1.0]]
              })
            Text(this.item !== undefined ? this.item.title : '')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F5F0E8')
              .padding(16)
              .width('100%')
          }
          .width('100%')
          .height(220)
          .clip(true)
          .borderRadius(Theme.radius.card)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

          Column({ space: 8 }) {
            Text(this.item !== undefined && this.item.authorName.length > 0
              ? `作者 ${this.item.authorName}` : '玩家分享')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
            Text(this.item !== undefined ? this.item.summary : '')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.card)

          Text(this.item !== undefined ? this.item.body : '')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          AppButton({
            label: '返回',
            variant: 'secondary',
            onTap: () => CampDetailNav.close()
          }).margin({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
