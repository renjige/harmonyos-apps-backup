import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { InspectionCard } from '../components/quality/InspectionCard'
import { InspectionRecord } from '../models/QualityModels'
import { QualityService } from '../services/QualityService'
import { QualityNav } from '../services/QualityNav'

@Component
export struct InspectionListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop refreshToken: number = 0

  private rows(token: number): InspectionRecord[] {
    const _keep = token
    return QualityService.inspections()
  }

  build() {
    Column() {
      Row() {
        Text('巡查')
          .fontSize(Theme.type.title1)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Text('开始巡查')
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().brandOnPrimary)
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ left: 16, right: 16, bottom: 12 })
        .padding({ top: 14, bottom: 14 })
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(14)
        .onClick(() => QualityNav.open('start'))

      if (this.rows(this.refreshToken).length === 0) {
        AppEmpty({
          title: '开始第一次质量巡查',
          description: '创建巡查后，记录会显示在这里。',
          actionLabel: '开始巡查',
          onAction: () => QualityNav.open('start')
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: 10 }) {
            Text('最近巡查记录')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.rows(this.refreshToken), (row: InspectionRecord) => {
              InspectionCard({
                item: row,
                onOpen: (id: string) => QualityNav.open('inspect', id)
              })
            }, (row: InspectionRecord) => `${row.id}_${this.refreshToken}`)
          }
          .padding({ left: 16, right: 16, bottom: 32 })
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
