import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { ArticleItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { DetailShell } from './DetailShell'

@Component
export struct ArticleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ArticleItem = new ArticleItem()

  private metaLine(): string {
    let line = this.item.category
    if (this.item.readMinutes > 0) {
      line = `${line} · 约 ${this.item.readMinutes} 分钟`
    }
    return line
  }

  build() {
    DetailShell({
      title: '职场资讯',
      onBack: () => CareerDetailNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(CareerMedia.cover(this.item.coverKey, this.item.category))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.15], [0xE61A2A6C, 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s4
              })
          }
          .width('100%')
          .height(200)
          .clip(true)

          Column({ space: Theme.space.s4 }) {
            Text(this.metaLine())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppCard({ title: '摘要' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
            AppButton({
              label: '返回首页继续浏览',
              variant: 'secondary',
              onTap: (): void => CareerDetailNav.close()
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
