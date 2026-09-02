import { ReadingRecord, LabelOption, KnowledgeCard } from '../../models/SilanModels'
import { SilanStore } from '../../services/SilanStore'
import { SilanNav } from '../../services/SilanNav'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct ReadingDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('silanDataRev') silanDataRev: number = 0
  @Prop itemId: string = ''
  @State item: ReadingRecord = new ReadingRecord()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await SilanStore.findReading(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await SilanStore.saveReading(this.item)
    await this.reload()
  }

  private async toCard(): Promise<void> {
    const c = KnowledgeCard.createNew(this.item.title)
    c.content = this.item.corePoints
    c.myUnderstanding = this.item.myUnderstanding
    c.tags = this.item.tags
    c.themeIds = this.item.themeIds
    c.sourceType = 'reading'
    c.sourceId = this.item.id
    await SilanStore.saveCard(c)
    this.toastText = '已沉淀为知识卡片'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    await SilanStore.deleteReading(this.item.id)
    this.confirmDelete = false
    SilanNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'reading',
        title: this.item.title,
        meta: `${LabelOption.labelOf(LabelOption.sources(), this.item.sourceType)} · ${this.item.readAt}`,
        summary: this.item.corePoints,
        body: this.item.myUnderstanding,
        extra: this.item.harvest,
        favorite: this.item.favorite,
        extraActionLabel: '沉淀为知识卡片',
        onEdit: (): void => { SilanNav.openEditor('reading', this.item.id) },
        onFavorite: (): void => { void this.toggleFav() },
        onDelete: (): void => { this.confirmDelete = true },
        onExtraAction: (): void => { void this.toCard() }
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条阅读沉淀？')
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
