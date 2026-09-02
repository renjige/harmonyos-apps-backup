import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'
import { LanguageScenarioService } from '../../services/LanguageScenarioService'
import { LanguageDraftService } from '../../services/LanguageDraftService'
import { LanguageWorkflowService } from '../../services/LanguageWorkflowService'
import { LanguageUseCaseService } from '../../services/LanguageUseCaseService'

/** 表达 Tab 能力总览 — 首屏可见，避免被误判为「仅简单润色」 */
@Component
export struct ExpressCapabilityBanner {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('expressBannerDismissed') dismissed: boolean = false

  private sceneCount(): number {
    return LanguageScenarioService.all().length
  }

  private draftCount(): number {
    return LanguageDraftService.templates().length
  }

  private workflowCount(): number {
    return LanguageWorkflowService.all().length
  }

  private guideCount(): number {
    return LanguageUseCaseService.all().length
  }

  build() {
    Column() {
      if (this.dismissed) {
        Row() {
          Text(`已就绪 · ${this.sceneCount()} 场景 · ${this.draftCount()} 成稿 · ${this.workflowCount()} 工作流`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .layoutWeight(1)
          Text('展开说明')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
            .onClick((): void => {
              AppStorage.setOrCreate('expressBannerDismissed', false)
            })
        }
        .width('100%')
        .padding(Theme.space.s3)
      } else {
        Column({ space: Theme.space.s2 }) {
          Text('表达与创作工具箱')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textPrimary)
            .width('100%')
          Text(`${this.sceneCount()} 类场景 · ${this.draftCount()} 类成稿 · ${this.workflowCount()} 条工作流 · ${this.guideCount()} 条使用指南`)
            .fontSize(Theme.type.footnote)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
            .width('100%')
          Text('覆盖职场邮件/纪要/汇报/请假/催办，学术讨论/论文提纲/文献笔记，以及调研摘要、阅读札记；支持四风格润色对照、智能摘要与表达诊断，并可与研究笔记联动。')
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppButton({
                label: '从使用指南开始',
                onTap: (): void => { LanguageCraftNav.openUseCaseGuide() }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '一键演示润色',
                variant: 'secondary',
                onTap: (): void => { LanguageCraftNav.runQuickDemo() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
          Text('收起说明')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textTertiary)
            .width('100%')
            .textAlign(TextAlign.End)
            .onClick((): void => {
              AppStorage.setOrCreate('expressBannerDismissed', true)
            })
        }
        .width('100%')
        .padding(Theme.space.s4)
      }
    }
    .width('100%')
    .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
    .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
  }
}
