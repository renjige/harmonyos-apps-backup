import { Theme } from '../design-system/Theme'
import { PortfolioProject } from '../../models/PortfolioModels'
import { PortfolioMedia } from '../../services/PortfolioMedia'

@Component
export struct ProjectGridCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop project: PortfolioProject = new PortfolioProject()
  onTap: () => void = () => {}
  @State pressed: boolean = false

  build() {
    Column({ space: Theme.space.s2 }) {
      Stack({ alignContent: Alignment.TopEnd }) {
        Image(PortfolioMedia.coverResource(this.project.coverKey))
          .width('100%')
          .aspectRatio(16 / 9)
          .objectFit(ImageFit.Cover)
          .borderRadius(12)

        Text(PortfolioMedia.categoryLabel(this.project.category))
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('rgba(26,35,50,0.72)')
          .borderRadius(Theme.radius.pill)
          .margin(Theme.space.s2)
      }
      .width('100%')

      Text(this.project.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.project.tags.length > 0) {
        Text(`#${this.project.tags[0]}`)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
      }
    }
    .width('100%')
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(12)
    .shadow({ radius: this.pressed ? 4 : 10, color: 'rgba(26,35,50,0.08)', offsetY: this.pressed ? 1 : 3 })
    .scale({ x: this.pressed ? 0.96 : 1, y: this.pressed ? 0.96 : 1 })
    .animation({ duration: Theme.motion.fast, curve: Curve.EaseOut })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressed = true
      }
      if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick(() => {
      this.onTap()
    })
  }
}
