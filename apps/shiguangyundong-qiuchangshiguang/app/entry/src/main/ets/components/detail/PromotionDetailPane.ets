import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { PromotionItem } from '../../models/CourtModels'
import { CourtMedia } from '../../config/CourtMedia'
import { CourtBizService } from '../../services/CourtBizService'
import { CourtDetailNav } from '../../services/CourtDetailNav'

@Component
export struct PromotionDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop promotionId: string = ''
  @State item: PromotionItem = new PromotionItem()
  @State loading: boolean = true
  onBrowseVenues: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.loading = true
    const found = await CourtBizService.findPromotion(this.promotionId)
    if (found !== undefined) {
      this.item = found
    }
    this.loading = false
  }

  build() {
    DetailShell({
      title: '优惠活动',
      onClose: (): void => {
        CourtDetailNav.close()
      },
      body: (): void => {
        this.BodyContent()
      },
      footer: (): void => {
        this.FooterActions()
      }
    })
  }

  @Builder
  BodyContent() {
    if (this.loading) {
      Text('加载中…')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
    } else {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CourtMedia.byKey(this.item.coverKey))
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.xl)
        Column({ space: 0 })
          .width('100%')
          .height(200)
          .borderRadius(Theme.radius.xl)
          .linearGradient({
            angle: 180,
            colors: [
              ['rgba(26,42,58,0.10)', 0.0],
              ['rgba(26,42,58,0.90)', 1.0]
            ]
          })
        Column({ space: 6 }) {
          Text(this.item.discountLabel)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandAccent)
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textOnInverse)
          if (this.item.endAt.length > 0) {
            Text(`有效期至 ${this.item.endAt}`)
              .fontSize(Theme.type.caption)
              .fontColor('rgba(255,255,255,0.88)')
          }
        }
        .padding(Theme.space.s5)
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }

      AppCard({ title: '活动说明', variant: 'plain' }) {
        Text(this.item.summary.length > 0 ? this.item.summary : '欢迎预约参与')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }

      if (this.item.body.length > 0) {
        Column({ space: Theme.space.s2 }) {
          Text('详细规则')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(this.item.body)
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
      }
    }
  }

  @Builder
  FooterActions() {
    AppButton({
      label: '查看可订场馆',
      onTap: (): void => {
        this.onBrowseVenues()
      }
    })
  }
}
