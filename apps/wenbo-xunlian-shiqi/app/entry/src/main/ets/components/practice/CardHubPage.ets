import { Theme } from '../design-system/Theme'
import { AppEmpty } from '../design-system/AppEmpty'
import { SolidButton } from '../design-system/SolidButton'
import { HubShell } from './HubShell'
import { CardDetailPane } from '../detail/CardDetailPane'
import { CardFormOverlay } from './CardFormOverlay'
import { CardDraft, KnowledgeCard } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { DataRefresh } from '../../services/DataRefresh'

@Component
export struct CardHubPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State items: KnowledgeCard[] = []
  @State detailId: string = ''
  @State showForm: boolean = false
  @State draft: CardDraft = new CardDraft()
  onClose: () => void = () => {}

  aboutToAppear(): void {
    this.reload()
  }

  private reload(): void {
    this.items = PracticeHubStore.listCards()
  }

  private async submitCard(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    await PracticeHubStore.saveCard(PracticeService.createCard(this.draft))
    this.showForm = false
    this.draft = new CardDraft()
    DataRefresh.bump()
    this.reload()
  }

  build() {
    if (this.detailId.length > 0) {
      CardDetailPane({
        cardId: this.detailId,
        onClose: (): void => {
          this.detailId = ''
          this.reload()
        },
        onChanged: (): void => { this.reload() }
      })
    } else if (this.showForm) {
      CardFormOverlay({
        draft: this.draft,
        onClose: (): void => { this.showForm = false },
        onSubmit: (): void => { void this.submitCard() },
        onDraftChange: (d: CardDraft): void => { this.draft = d }
      })
    } else {
      HubShell({
        title: '趣味训练笔记',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.Body() }
      })
    }
  }

  @Builder
  Body() {
    Text('这里不是百科，只保存你自己整理的要点、方法和注意事项。')
      .fontSize(Theme.type.footnote)
      .fontColor(Theme.colors().textSecondary)
      .width('100%')

    Column() {
      SolidButton({
        label: '新建卡片',
        tone: 'primary',
        onTap: (): void => { this.showForm = true }
      })
    }
    .width('100%')
    .onClick((): void => { this.showForm = true })

    if (this.items.length === 0) {
      AppEmpty({
        title: '还没有知识卡片',
        description: '训练后把「适合自己的晚间拉伸」写成一条笔记'
      })
    } else {
      ForEach(this.items, (k: KnowledgeCard) => {
        Column({ space: 4 }) {
          Text(k.tag)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
          Text(k.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          if (k.body.length > 0) {
            Text(k.body)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .border({ width: 1, color: Theme.colors().strokeHairline })
        .onClick((): void => { this.detailId = k.id })
      }, (k: KnowledgeCard) => k.id)
    }
  }
}
