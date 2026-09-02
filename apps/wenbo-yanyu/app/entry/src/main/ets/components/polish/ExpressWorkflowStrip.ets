import { Theme } from '../design-system/Theme'
import { WritingWorkflow } from '../../models/LanguageCraftModels'
import { LanguageWorkflowService } from '../../services/LanguageWorkflowService'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'

@Component
export struct ExpressWorkflowStrip {
  @StorageLink('darkModeOn') darkModeOn: boolean = false

  build() {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text('创作工作流')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
          .layoutWeight(1)
        Text('一键体验')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textTertiary)
      }
      .width('100%')

      Text('点选后自动载入样例、润色并弹出四风格对照，适合快速感受改写效果。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.of(this.darkModeOn).textSecondary)
        .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(LanguageWorkflowService.all(), (row: WritingWorkflow) => {
            Column({ space: 4 }) {
              Text(row.title)
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(row.hint)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.of(this.darkModeOn).textSecondary)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width(148)
            .height(76)
            .padding(10)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)
            .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
            .onClick((): void => { LanguageCraftNav.applyWorkflow(row) })
          }, (row: WritingWorkflow) => row.key)
        }
        .padding({ right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.space.pageX })
  }
}
