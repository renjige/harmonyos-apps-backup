import { Theme } from '../design-system/Theme'
import { DiaryFormatSegment, DiaryFormatter } from '../../services/DiaryFormatter'

@Component
export struct FormattedDiaryBody {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop body: string = ''
  @Prop fontSize: number = Theme.type.bodyL
  @Prop lineHeight: number = 26

  @Builder
  LineText(segments: DiaryFormatSegment[]) {
    Text() {
      ForEach(segments, (seg: DiaryFormatSegment) => {
        Span(seg.text)
          .fontSize(this.fontSize)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .fontWeight(seg.bold ? FontWeight.Bold : FontWeight.Regular)
          .fontStyle(seg.italic ? FontStyle.Italic : FontStyle.Normal)
          .decoration({ type: seg.isList ? TextDecorationType.None : TextDecorationType.None })
      }, (seg: DiaryFormatSegment) => `${seg.text}_${seg.bold}_${seg.italic}`)
    }
    .width('100%')
    .lineHeight(this.lineHeight)
  }

  build() {
    Column({ space: Theme.space.s2 }) {
      ForEach(DiaryFormatter.lines(this.body), (line: DiaryFormatSegment[], index: number) => {
        if (line.length === 0) {
          Text(' ')
            .fontSize(this.fontSize)
            .lineHeight(this.lineHeight)
        } else {
          this.LineText(line)
        }
      }, (_line: DiaryFormatSegment[], index: number) => `fmt_${index}`)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
