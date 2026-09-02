import { Theme } from '../design-system/Theme'
import { TagPreset } from '../../models/MomentModels'

@Component
export struct NoteFilterChips {
  @Prop filterTag: string = ''
  @Prop onlyStar: boolean = false
  onAll: () => void = () => {}
  onStar: () => void = () => {}
  onTag: (label: string) => void = (label: string) => {
    if (label.length === 0) {
      return
    }
  }

  build() {
    Scroll() {
      Row({ space: 8 }) {
        Text('全部')
          .fontSize(12)
          .fontColor(this.filterTag.length === 0 && !this.onlyStar ? '#FFFFFF' : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.filterTag.length === 0 && !this.onlyStar ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => this.onAll())
        Text('星标')
          .fontSize(12)
          .fontColor(this.onlyStar ? '#FFFFFF' : Theme.colors().textPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.onlyStar ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => this.onStar())
        ForEach(TagPreset.all(), (t: TagPreset) => {
          Text(`#${t.label}`)
            .fontSize(12)
            .fontColor(this.filterTag === t.label ? '#FFFFFF' : Theme.colors().textPrimary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.filterTag === t.label ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .onClick((): void => this.onTag(t.label))
        }, (t: TagPreset) => t.key)
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .clip(true)
    .height(44)
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
  }
}
