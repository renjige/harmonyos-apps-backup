import { Theme } from '../design-system/Theme'
import { PracticeSession } from '../../models/MathModels'
import { MathBizService } from '../../services/MathBizService'

@Component
export struct HomeRecentStrip {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop items: PracticeSession[] = []

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('最近练习')
        .fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      if (this.items.length === 0) {
        Text('完成第一组后，会出现在这里')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        ForEach(this.items, (s: PracticeSession) => {
          Column({ space: Theme.space.s1 }) {
            Text(MathBizService.sessionTitle(s.kind))
              .fontSize(Theme.type.body).fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`${s.date} · ${s.correct}/${s.total} 正确 · ${s.stars} 星`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%').padding(Theme.space.s4).alignItems(HorizontalAlign.Start)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
        }, (s: PracticeSession) => s.id)
      }
    }
    .width('100%')
  }
}
