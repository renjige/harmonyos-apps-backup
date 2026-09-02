import { Theme } from '../design-system/Theme'
import { FanMemoryStore } from '../../services/FanMemoryStore'

/** 拾光洞察：基于本机数据的动态摘要与使用建议 */
@Component
export struct FanInsightCard {
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @StorageLink('fanEpoch') @Watch('onRefreshTokenChange') fanEpoch: number = 0
  @State lines: string[] = []

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.lines = FanMemoryStore.insightLines()
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      Text('拾光洞察')
        .fontSize(Theme.type.subhead)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      ForEach(this.lines, (line: string, idx: number) => {
        Text(`· ${line}`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
      }, (line: string, idx: number) => `ins_${idx}`)
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(Theme.colors().surfaceCard)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .borderRadius(Theme.radius.lg)
  }
}
