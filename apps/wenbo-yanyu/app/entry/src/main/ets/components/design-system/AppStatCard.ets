import { Theme } from './Theme'
import { AppCard } from './AppCard'

@Component
export struct AppStatCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop label: string = ''
  @Prop value: string = ''
  @Prop trend: string = ''
  @Prop positive: boolean = true

  build() {
    AppCard({ variant: 'stat' }) {
      Column({ space: Theme.space.s1 }) {
        Text(this.label)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
        Text(this.value)
          .fontSize(Theme.type.display)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
        if (this.trend.length > 0) {
          Text(this.trend)
            .fontSize(Theme.type.footnote)
            .fontColor(this.positive ? Theme.of(this.darkModeOn).success : Theme.of(this.darkModeOn).danger)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }
}
