import { Theme } from '../design-system/Theme'
import { InspectStatus } from '../../models/InspectModels'

@Component
export struct StatusTag {
  @Prop result: string = ''
  @Prop compact: boolean = false

  private bg(): string {
    if (Theme.isDark()) {
      if (this.result === 'pass') {
        return '#0C2814'
      }
      if (this.result === 'fail') {
        return '#4A1414'
      }
      return '#4A3010'
    }
    if (this.result === 'pass') {
      return '#C5E4CE'
    }
    if (this.result === 'fail') {
      return '#F0C8C8'
    }
    return '#F0D9B0'
  }

  private fg(): string {
    if (Theme.isDark()) {
      if (this.result === 'pass') {
        return '#E8F8EC'
      }
      if (this.result === 'fail') {
        return '#FFE8E8'
      }
      return '#FFF0D0'
    }
    if (this.result === 'pass') {
      return '#143D22'
    }
    if (this.result === 'fail') {
      return '#6B1A1A'
    }
    return '#6B4210'
  }

  build() {
    Text(this.compact ? InspectStatus.shortLabel(this.result) : InspectStatus.label(this.result))
      .fontSize(this.compact ? Theme.type.caption : Theme.type.subhead)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.fg())
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .backgroundColor(this.bg())
      .borderRadius(Theme.radius.pill)
  }
}
