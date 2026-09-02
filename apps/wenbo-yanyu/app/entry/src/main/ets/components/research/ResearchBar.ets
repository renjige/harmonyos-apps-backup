import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { ResearchNav } from '../../services/ResearchNav'

@Component
export struct ResearchBar {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop title: string = ''
  onBack: () => void = () => { ResearchNav.close() }

  build() {
    Row({ space: Theme.space.s2 }) {
      Column() {
        AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.of(this.darkModeOn).textPrimary })
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .rotate({ angle: 180 })
      .onClick((): void => { this.onBack() })
      Text(this.title)
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.of(this.darkModeOn).textPrimary)
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
  }
}
