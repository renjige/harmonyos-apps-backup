import { Theme } from '../design-system/Theme'
import { ScenePreset } from '../../models/MomentModels'

@Component
export struct SceneChipRow {
  onPick: (s: ScenePreset) => void = (s: ScenePreset) => {
    if (s.key.length === 0) {
      return
    }
  }

  build() {
    Row({ space: 8 }) {
      ForEach(ScenePreset.all(), (s: ScenePreset) => {
        Text(s.label)
          .fontSize(Theme.type.bodyS)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => this.onPick(s))
      }, (s: ScenePreset) => s.key)
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
  }
}
