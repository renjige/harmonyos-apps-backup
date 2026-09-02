import { KnowledgeCard, LabelOption } from '../../models/BowenModels'
import { BowenStore } from '../../services/BowenStore'
import { BowenNav } from '../../services/BowenNav'
import { BowenQuery } from '../../services/BowenQuery'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct CardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('bowenDataRev') bowenDataRev: number = 0
  @Prop itemId: string = ''
  @State item: KnowledgeCard = new KnowledgeCard()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await BowenStore.findCard(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private isFavorited(): boolean {
    return this.item.favoriteTier !== 'none' && this.item.favoriteTier.length > 0
  }

  private tierMeta(): string {
    const cat = LabelOption.labelOf(LabelOption.categories(), this.item.categoryKey)
    const tier = BowenQuery.favoriteTierLabel(this.item.favoriteTier)
    if (this.item.favoriteTier === 'none') {
      return `知识卡片 · ${cat}`
    }
    return `知识卡片 · ${cat} · ${tier}`
  }

  private async toggleFav(): Promise<void> {
    this.item.favoriteTier = BowenQuery.cycleFavoriteTier(this.item.favoriteTier)
    await BowenStore.saveCard(this.item)
    await this.reload()
    this.toastText = BowenQuery.favoriteTierLabel(this.item.favoriteTier)
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async doDelete(): Promise<void> {
    await BowenStore.deleteCard(this.item.id)
    this.confirmDelete = false
    BowenNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'card',
        title: this.item.title,
        meta: this.tierMeta(),
        summary: this.item.content,
        body: this.item.myUnderstanding,
        extra: this.item.sourceNote.length > 0 ? this.item.sourceNote : this.item.tags.join(' · '),
        favorite: this.isFavorited(),
        onEdit: (): void => { BowenNav.openEditor('card', this.item.id) },
        onFavorite: (): void => { void this.toggleFav() },
        onDelete: (): void => { this.confirmDelete = true }
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这张知识卡片？')
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
        Text(`收藏层级：${this.toastText}`)
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
