import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { KnowledgeCard } from '../../models/TuceModels'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct KnowledgeListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State cards: KnowledgeCard[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.cards = await TuceStore.cards()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text('从动作详情保存的知识卡会集中在这里，方便赛前复习。')
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        if (this.cards.length === 0) {
          AppEmpty({
            title: '还没有知识卡',
            description: '打开图鉴动作详情，保存要点与节奏提示',
            actionLabel: '知道了',
            onAction: (): void => { TuceNav.close() }
          })
        }
        ForEach(this.cards, (c: KnowledgeCard) => {
          Column({ space: 6 }) {
            Text(c.moveName)
              .fontSize(Theme.type.body)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(`要点：${c.focus}`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(2)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { TuceNav.open('kcard', c.id) })
        }, (c: KnowledgeCard) => c.id)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
