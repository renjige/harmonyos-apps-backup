import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { SolidButton } from '../design-system/SolidButton'
import { DetailShell } from './DetailShell'
import { CardDraft, KnowledgeCard } from '../../models/TrainingModels'
import { PracticeHubStore } from '../../services/PracticeHubStore'
import { PracticeService } from '../../services/PracticeService'
import { DataRefresh } from '../../services/DataRefresh'
import { CardFormOverlay } from '../practice/CardFormOverlay'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop cardId: string = ''
  @State item: KnowledgeCard = new KnowledgeCard()
  @State confirmDelete: boolean = false
  @State showEdit: boolean = false
  @State draft: CardDraft = new CardDraft()
  onClose: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    const found = PracticeHubStore.findCard(this.cardId)
    if (found !== null) {
      this.item = found
    }
  }

  private openEdit(): void {
    const d = new CardDraft()
    d.title = this.item.title
    d.body = this.item.body
    d.tag = this.item.tag
    this.draft = d
    this.showEdit = true
  }

  private async submitEdit(): Promise<void> {
    if (this.draft.title.trim().length === 0) {
      return
    }
    const next = PracticeService.createCard(this.draft)
    next.id = this.item.id
    next.createdAt = this.item.createdAt
    await PracticeHubStore.saveCard(next)
    this.showEdit = false
    DataRefresh.bump()
    this.onChanged()
    this.load()
  }

  private async deleteCard(): Promise<void> {
    await PracticeHubStore.deleteCard(this.cardId)
    DataRefresh.bump()
    this.onChanged()
    this.onClose()
  }

  build() {
    if (this.showEdit) {
      CardFormOverlay({
        draft: this.draft,
        formTitle: '编辑知识卡片',
        onClose: (): void => { this.showEdit = false },
        onSubmit: (): void => { void this.submitEdit() },
        onDraftChange: (d: CardDraft): void => { this.draft = d }
      })
    } else {
      DetailShell({
        title: '知识卡片',
        onClose: (): void => { this.onClose() },
        body: (): void => { this.BodyContent() },
        footer: (): void => { this.FooterActions() }
      })
    }
  }

  @Builder
  BodyContent() {
    Column({ space: 8 }) {
      Text(this.item.tag)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().brandPrimary)
      Text(this.item.title)
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(Theme.colors().textPrimary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)

    AppCard({ title: '我整理的内容' }) {
      Text(this.item.body.length > 0 ? this.item.body : '还没有正文。把动作要点、训练方法或注意事项写在这里。')
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textSecondary)
        .lineHeight(22)
    }
  }

  @Builder
  FooterActions() {
    if (this.confirmDelete) {
      Text('确定删除这张卡片？')
        .fontSize(Theme.type.bodyS)
        .fontColor(Theme.colors().danger)
        .width('100%')
      Row({ space: Theme.space.s3 }) {
        Column() {
          SolidButton({
            label: '取消',
            tone: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.confirmDelete = false })
        Column() {
          SolidButton({
            label: '确认删除',
            tone: 'danger',
            onTap: (): void => { void this.deleteCard() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deleteCard() })
      }
      .width('100%')
    } else {
      Column() {
        SolidButton({
          label: '编辑卡片',
          tone: 'primary',
          onTap: (): void => { this.openEdit() }
        })
      }
      .width('100%')
      .onClick((): void => { this.openEdit() })
      Column() {
        SolidButton({
          label: '删除卡片',
          tone: 'secondary',
          onTap: (): void => { this.confirmDelete = true }
        })
      }
      .width('100%')
      .onClick((): void => { this.confirmDelete = true })
    }
  }
}
