import { Theme } from '../design-system/Theme'
import { DimensionOption } from '../../models/VitalityModels'

@Component
export struct DimensionPicker {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop title: string = ''
  @Prop options: DimensionOption[] = []
  @Prop selectedKey: string = ''
  onSelect: (key: string) => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text(this.title)
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        ForEach(this.options, (o: DimensionOption) => {
          Text(o.label)
            .fontSize(Theme.type.bodyS)
            .fontWeight(this.selectedKey === o.key ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.selectedKey === o.key ?
              Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 14, bottom: 14 })
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .backgroundColor(this.selectedKey === o.key ?
              Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.lg)
            .border({
              width: this.selectedKey === o.key ? 0 : 1,
              color: Theme.colors().strokeHairline
            })
            .shadow(this.selectedKey === o.key ? {
              radius: 10,
              color: Theme.isDark() ? 'rgba(255,107,53,0.25)' : 'rgba(255,107,53,0.18)',
              offsetX: 0,
              offsetY: 3
            } : {
              radius: 0,
              color: 'transparent',
              offsetX: 0,
              offsetY: 0
            })
            .onClick((): void => this.onSelect(o.key))
        }, (o: DimensionOption) => o.key)
      }
      .width('100%')
    }
    .width('100%')
    .opacity(this.themeEpoch >= 0 ? 1 : 1)
  }
}
