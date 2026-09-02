import { Theme } from '../components/design-system/Theme'
import { AppNavBar } from '../components/design-system/AppNavBar'
import { AppCard } from '../components/design-system/AppCard'
import { ContentService } from '../services/ContentService'
import { BusinessItem } from '../models/ZhukeModels'

@Component
export struct BusinessDetailPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop businessId: string = ''
  @State item: BusinessItem = new BusinessItem()
  onBack: () => void = () => {}

  aboutToAppear(): void {
    const found = ContentService.businessById(this.businessId)
    if (found !== null) {
      this.item = found
    }
  }

  build() {
    Column() {
      AppNavBar({ title: '业务详情', onBack: () => this.onBack() })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          AppCard({ title: '业务概述' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(24)
          }

          AppCard({ title: '服务范围' }) {
            Column({ space: Theme.space.s2 }) {
              ForEach(this.item.highlights, (h: string, index: number) => {
                Text(`· ${h}`)
                  .fontSize(Theme.type.callout)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }, (h: string, index: number) => `${index}`)
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
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
