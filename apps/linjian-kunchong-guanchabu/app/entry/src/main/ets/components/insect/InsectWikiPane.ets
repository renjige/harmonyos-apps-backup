import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from '../detail/DetailShell'
import { InsectWikiItem } from '../../models/InsectCatalog'
import { InsectMedia } from '../../services/InsectMedia'

@Component
export struct InsectWikiPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InsectWikiItem = new InsectWikiItem()
  onBack: () => void = () => {}
  onStartObserve: () => void = () => {}

  build() {
    DetailShell({ title: this.item.name, onBack: (): void => this.onBack() }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(InsectMedia.cover(this.item.coverKey))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text(this.item.latin)
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(16)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(16,32,24,0.78)', 1]]
            })
          }
          .width('100%')
          .borderRadius(Theme.radius.lg)
          .clip(true)

          Text(`${this.item.season} · ${this.item.region}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          AppCard({ title: '特征' }) {
            Text(this.item.traits)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
              .width('100%')
          }
          AppCard({ title: '习性' }) {
            Text(this.item.habit)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
              .width('100%')
          }
          AppCard({ title: '分布' }) {
            Text(this.item.region)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
              .width('100%')
          }

          AppButton({ label: '开始观察', onTap: (): void => this.onStartObserve() })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
  }
}
