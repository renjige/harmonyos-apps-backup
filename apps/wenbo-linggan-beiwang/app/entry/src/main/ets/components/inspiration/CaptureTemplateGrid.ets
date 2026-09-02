import { Theme } from '../design-system/Theme'
import { DailyPrompt } from '../../models/WorkbenchModels'
import { DailyPromptService } from '../../services/DailyPromptService'

@Component
export struct CaptureTemplateGrid {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onPick: (item: DailyPrompt) => void = (_p: DailyPrompt) => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('快记模板')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Grid() {
        ForEach(DailyPromptService.templates(), (item: DailyPrompt) => {
          GridItem() {
            Column({ space: 6 }) {
              Text(item.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(item.hint)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .maxLines(2)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.colors().strokeHairline })
            .onClick((): void => { this.onPick(item) })
          }
        }, (item: DailyPrompt) => item.title)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(Theme.space.s3)
      .rowsGap(Theme.space.s3)
      .width('100%')
    }
    .width('100%')
  }
}
