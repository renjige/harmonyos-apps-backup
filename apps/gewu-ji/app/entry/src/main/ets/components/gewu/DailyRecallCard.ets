import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KnowledgeFact, KnowledgeObject } from '../../models/KnowledgeModels'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'

@Component
export struct DailyRecallCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onObjectChange') objectId: string = ''
  @State quizIndex: number = 0
  @State revealed: boolean = false

  onObjectChange(): void {
    this.quizIndex = 0
    this.revealed = false
  }

  private currentFact(): KnowledgeFact {
    const obj: KnowledgeObject | undefined = KnowledgeCatalog.resolveById(this.objectId)
    if (obj === undefined || obj.facts.length === 0) {
      return new KnowledgeFact()
    }
    const idx = this.quizIndex % obj.facts.length
    return obj.facts[idx]
  }

  private factCount(): number {
    const obj: KnowledgeObject | undefined = KnowledgeCatalog.resolveById(this.objectId)
    if (obj === undefined) {
      return 0
    }
    return obj.facts.length
  }

  private nextFact(): void {
    const total = this.factCount()
    if (total <= 0) {
      return
    }
    this.quizIndex = (this.quizIndex + 1) % total
    this.revealed = false
  }

  build() {
    Column() {
      if (this.factCount() > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('今日回想')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('先想一想再揭晓，把阅读变成主动回忆')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Text(`要点 ${this.quizIndex + 1} / ${this.factCount()}`)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          Text(this.currentFact().label)
            .fontSize(Theme.type.body)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.revealed) {
            Text(this.currentFact().content)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(22)
              .width('100%')
          } else {
            Text('想好后再点「揭晓要点」')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
          }
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: this.revealed ? '已揭晓' : '揭晓要点',
                variant: 'secondary',
                onTap: (): void => { this.revealed = true }
              })
            }
            .layoutWeight(1)
            if (this.factCount() > 1) {
              Column() {
                AppButton({
                  label: '下一问',
                  variant: 'ghost',
                  onTap: (): void => { this.nextFact() }
                })
              }
              .layoutWeight(1)
            }
          }
          .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.md)
      }
    }
    .width('100%')
  }
}
