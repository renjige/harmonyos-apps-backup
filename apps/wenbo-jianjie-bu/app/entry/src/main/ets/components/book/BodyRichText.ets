import { Theme } from '../design-system/Theme'
import { MarkupLine, MarkupSeg, MarkupService } from '../../services/MarkupService'

@Component
export struct BodyRichText {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop body: string = ''

  private lines(): MarkupLine[] {
    return MarkupService.parse(this.body)
  }

  private fontSizeOf(seg: MarkupSeg): number {
    if (seg.heading === 1) {
      return Theme.type.title3
    }
    if (seg.heading === 2) {
      return Theme.type.subtitleL
    }
    if (seg.heading === 3) {
      return Theme.type.subtitleM
    }
    return Theme.type.body
  }

  build() {
    Column({ space: 6 }) {
      ForEach(this.lines(), (line: MarkupLine, idx: number) => {
        Text() {
          ForEach(line.segs, (seg: MarkupSeg, si: number) => {
            Span(seg.text)
              .fontSize(this.fontSizeOf(seg))
              .fontWeight(seg.bold || seg.heading > 0 ? FontWeight.Bold : FontWeight.Normal)
              .fontStyle(seg.italic ? FontStyle.Italic : FontStyle.Normal)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          }, (seg: MarkupSeg, si: number) => `s${idx}_${si}_${seg.text}`)
        }
        .width('100%')
        .lineHeight(24)
      }, (line: MarkupLine, idx: number) => `ln${idx}`)
    }
    .width('100%')
  }
}
