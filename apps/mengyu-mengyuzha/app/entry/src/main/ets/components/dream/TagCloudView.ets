import { Theme } from '../design-system/Theme'
import { TagWeight } from '../../services/InsightService'

@Component
export struct TagCloudView {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop weights: TagWeight[] = []

  private fontSize(count: number, max: number): number {
    if (max <= 0) {
      return 12
    }
    const ratio = count / max
    if (ratio >= 0.8) {
      return 18
    }
    if (ratio >= 0.5) {
      return 16
    }
    if (ratio >= 0.3) {
      return 14
    }
    return 12
  }

  private maxCount(): number {
    let m = 1
    for (const t of this.weights) {
      if (t.count > m) {
        m = t.count
      }
    }
    return m
  }

  build() {
    if (this.weights.length === 0) {
      Text('暂无标签统计，为梦境加上标签后将生成词云。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
    } else {
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
        ForEach(this.weights, (t: TagWeight) => {
          Text(t.tag)
            .fontSize(this.fontSize(t.count, this.maxCount()))
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .fontWeight(t.count >= this.maxCount() ? FontWeight.Medium : FontWeight.Normal)
            .margin({ left: 8, right: 8, top: 6, bottom: 6 })
        }, (t: TagWeight) => t.tag)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.lg)
    }
  }
}
