import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { KnowledgeCard } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct KnowledgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cardId: string = ''
  @State card: KnowledgeCard = new KnowledgeCard()

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await TuceStore.cards()
    for (const it of list) {
      if (it.id === this.cardId) {
        this.card = it
        return
      }
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(this.card.moveName)
          .fontSize(Theme.type.title2)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        this.Field('发力要点', this.card.focus)
        this.Field('节奏呼吸', this.card.rhythm)
        this.Field('注意事项', this.card.caution)
        this.Field('训练心得', this.card.insight)
        AppButton({
          label: '删除知识卡',
          variant: 'secondary',
          onTap: (): void => { void this.remove() }
        })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Field(label: string, body: string) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Text(body.length > 0 ? body : '暂无内容')
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
  }

  private async remove(): Promise<void> {
    await TuceStore.deleteCard(this.cardId)
    TuceNav.bump()
    TuceNav.close()
  }
}
