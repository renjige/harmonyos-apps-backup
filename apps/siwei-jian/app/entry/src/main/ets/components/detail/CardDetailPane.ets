import { KnowledgeCard } from '../../models/JianModels'
import { JianStore } from '../../services/JianStore'
import { JianNav } from '../../services/JianNav'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('jianDataRev') jianDataRev: number = 0
  @Prop itemId: string = ''
  @State item: KnowledgeCard = new KnowledgeCard()
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await JianStore.findCard(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await JianStore.saveCard(this.item)
    await this.reload()
  }

  private async doDelete(): Promise<void> {
    await JianStore.deleteCard(this.item.id)
    this.confirmDelete = false
    JianNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'card',
        title: this.item.title,
        meta: '观点卡片',
        summary: this.item.content,
        body: this.item.myUnderstanding,
        extra: this.item.tags.join(' · '),
        favorite: this.item.favorite,
        onEdit: (): void => { JianNav.openEditor('card', this.item.id) },
        onFavorite: (): void => { void this.toggleFav() },
        onDelete: (): void => { this.confirmDelete = true }
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这张观点卡片？')
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmDelete = false } })
        }
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .margin({ top: 120, left: 24, right: 24 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
