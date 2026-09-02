import { Thought, LabelOption, KnowledgeCard } from '../../models/SilanModels'
import { SilanStore } from '../../services/SilanStore'
import { SilanNav } from '../../services/SilanNav'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct ThoughtDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('silanDataRev') silanDataRev: number = 0
  @Prop itemId: string = ''
  @State item: Thought = new Thought()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await SilanStore.findThought(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await SilanStore.saveThought(this.item)
    await this.reload()
  }

  private async toCard(): Promise<void> {
    const c = KnowledgeCard.createNew(this.item.title)
    c.content = this.item.body
    c.myUnderstanding = LabelOption.labelOf(LabelOption.thoughtKinds(), this.item.kind)
    c.tags = this.item.tags
    c.themeIds = this.item.themeIds
    c.sourceType = 'thought'
    c.sourceId = this.item.id
    await SilanStore.saveCard(c)
    this.toastText = '已沉淀为知识卡片'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    await SilanStore.deleteThought(this.item.id)
    this.confirmDelete = false
    SilanNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'thought',
        title: this.item.title,
        meta: `${LabelOption.labelOf(LabelOption.categories(), this.item.categoryKey)} · ${LabelOption.labelOf(LabelOption.statuses(), this.item.status)}`,
        summary: LabelOption.labelOf(LabelOption.thoughtKinds(), this.item.kind),
        body: this.item.body,
        extra: this.item.tags.join(' · '),
        favorite: this.item.favorite,
        extraActionLabel: '沉淀为知识卡片',
        onEdit: (): void => { SilanNav.openEditor('thought', this.item.id) },
        onFavorite: (): void => { void this.toggleFav() },
        onDelete: (): void => { this.confirmDelete = true },
        onExtraAction: (): void => { void this.toCard() }
      })

      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条思考？不可恢复。')
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .margin({ top: 120, left: 24, right: 24 })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .margin({ top: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
      }
    }
    .width('100%')
    .height('100%')
  }
}
