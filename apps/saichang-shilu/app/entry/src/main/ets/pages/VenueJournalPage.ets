import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { VenueStatRow } from '../models/SportExtra'
import { AnalyticsService } from '../services/AnalyticsService'

@Component
export struct VenueJournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: VenueStatRow[] = []
  onClose: () => void = () => {}

  aboutToAppear(): void {
    void AnalyticsService.venueStats().then((r): void => { this.rows = r })
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('场馆志')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('按「地点备注」汇总观赛场次与场均评价，回顾你的主场记忆。')
              .fontSize(Theme.type.bodyS)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

            if (this.rows.length === 0) {
              AppEmpty({
                title: '还没有场馆数据',
                description: '在赛事档案填写地点备注（球馆/城市）后这里会统计',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.rows, (row: VenueStatRow) => {
                Column({ space: Theme.space.s2 }) {
                  Text(row.name)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${row.matchCount} 场${row.avgRating > 0 ? ` · 均评 ${row.avgRating} 星` : ''}${row.lastDate.length > 0 ? ` · 最近 ${row.lastDate}` : ''}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .alignItems(HorizontalAlign.Start)
              }, (row: VenueStatRow) => row.name)
            }
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    }
    .width('100%')
    .height('100%')
    .zIndex(80)
    .onAppear((): void => { AppStorage.setOrCreate('tabBarHidden', true) })
    .onDisAppear((): void => { AppStorage.setOrCreate('tabBarHidden', false) })
  }
}
