import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CoolMedia } from '../../services/CoolMedia'
import { RouteItem } from '../../models/CoolModels'
import { CoolDetailNav } from '../../services/CoolDetailNav'

@Component
export struct RouteListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RouteItem = new RouteItem()

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(CoolMedia.resource(this.item.coverKey))
          .width('100%')
          .height(128)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
        Column()
          .width('100%')
          .height(56)
          .linearGradient({
            angle: 180,
            colors: [['rgba(11,42,54,0)', 0], ['rgba(11,42,54,0.78)', 1]]
          })
          .borderRadius({ bottomLeft: Theme.radius.md, bottomRight: Theme.radius.md })
        Text(this.item.title)
          .fontSize(Theme.type.subtitleM)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, bottom: 10 })
      }
      .width('100%')
      .height(128)

      Text(`${this.item.origin} → ${this.item.dest}`)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Text(this.item.modeLabel())
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        Text(`${this.item.durationMin} 分钟`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Text(`树荫 ${this.item.shadeRate}%`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        Blank()
        Text(`清凉 ${this.item.coolIndex}`)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
        AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .onClick(() => CoolDetailNav.openRoute(this.item.id))
  }
}
