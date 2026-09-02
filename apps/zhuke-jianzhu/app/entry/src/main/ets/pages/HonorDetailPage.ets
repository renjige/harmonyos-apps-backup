import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { ContentCover } from '../components/common/ContentCover'
import { ContentService } from '../services/ContentService'
import { HonorItem } from '../models/ZhukeModels'

@Component
export struct HonorDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop honorId: string = ''
  @State item: HonorItem = new HonorItem()
  onBack: () => void = () => {}

  aboutToAppear(): void {
    const found = ContentService.honorById(this.honorId)
    if (found !== null) {
      this.item = found
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '荣誉详情', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          ContentCover({
            imageKey: this.item.imageKey,
            coverHeight: 180,
            coverRadius: Theme.radius.lg,
            showGradient: false
          })

          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          Row({ space: Theme.space.s3 }) {
            Text(`${this.item.year} 年`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .padding({
                left: Theme.space.s2,
                right: Theme.space.s2,
                top: 2,
                bottom: 2
              })
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.pill)
            if (this.item.issuer.length > 0) {
              Text(`颁发机构：${this.item.issuer}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
            }
          }
          .width('100%')

          AppCard({ title: '荣誉说明' }) {
            Text(this.item.description)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(26)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
