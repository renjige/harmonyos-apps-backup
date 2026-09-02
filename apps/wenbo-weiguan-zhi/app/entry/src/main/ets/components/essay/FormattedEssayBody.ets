import { Theme } from '../design-system/Theme'
import { EssayFormatSegment } from '../../models/EssayModels'
import { EssayFormatter } from '../../services/EssayFormatter'

@Component
export struct FormattedEssayBody {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop body: string = ''
  @Prop fontSize: number = Theme.type.bodyL
  @Prop lineHeight: number = 26

  @Builder
  LineText(segments: EssayFormatSegment[]) {
    Text() {
      ForEach(segments, (seg: EssayFormatSegment) => {
        Span(seg.text)
          .fontSize(this.fontSize)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .fontWeight(seg.bold ? FontWeight.Bold : FontWeight.Regular)
          .fontStyle(seg.italic ? FontStyle.Italic : FontStyle.Normal)
          .decoration({ type: seg.underline ? TextDecorationType.Underline : TextDecorationType.None })
      }, (seg: EssayFormatSegment) => `${seg.text}_${seg.bold}_${seg.italic}_${seg.underline}`)
    }
    .width('100%')
    .lineHeight(this.lineHeight)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      ForEach(EssayFormatter.lines(this.body), (line: EssayFormatSegment[], index: number) => {
        if (line.length === 0) {
          Text(' ')
            .fontSize(this.fontSize)
            .lineHeight(this.lineHeight)
        } else {
          this.LineText(line)
        }
      }, (_line: EssayFormatSegment[], index: number) => `fmt_${index}`)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
