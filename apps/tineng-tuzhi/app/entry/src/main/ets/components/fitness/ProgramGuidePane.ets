import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from '../detail/DetailShell'
import { ProgramCatalog, TrainingProgram } from '../../models/TrainingModels'

@Component
export struct ProgramGuidePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onApply: (programId: string) => void = () => {}

  build() {
    Column() {
      DetailShell({
        title: '结构化训练方案',
        onClose: (): void => this.onClose()
      })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('三套多周方案可一键加入周期计划，与周训编排、今日清单配合使用。')
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          ForEach(ProgramCatalog.all(), (p: TrainingProgram) => {
            Column({ space: Theme.space.s3 }) {
              Row() {
                Text(p.title)
                  .fontSize(Theme.type.body)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${p.level} · ${p.weeks} 周`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().brandPrimary)
              }
              .width('100%')
              Text(p.summary)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(`重点：${p.focus}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              ForEach(p.days, (day: string) => {
                Text(`· ${day}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }, (day: string, idx: number) => `${p.id}-d-${idx}`)
              AppButton({
                label: '加入周期计划',
                variant: 'secondary',
                onTap: (): void => { this.onApply(p.id) }
              })
            }
            .width('100%')
            .padding(Theme.space.cardPadding)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.lg)
          }, (p: TrainingProgram) => p.id)
          Row().height(Theme.space.s10)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
