import { Spark, Thought, LabelOption } from '../../models/BowenModels'
import { BowenStore } from '../../services/BowenStore'
import { BowenNav } from '../../services/BowenNav'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct SparkDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('bowenDataRev') bowenDataRev: number = 0
  @Prop itemId: string = ''
  @State item: Spark = new Spark()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await BowenStore.findSpark(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await BowenStore.saveSpark(this.item)
    await this.reload()
  }

  private async toThought(): Promise<void> {
    const t = Thought.createNew(this.item.title)
    t.body = this.item.body
    t.kind = 'viewpoint'
    t.tags = this.item.tags
    t.themeIds = this.item.themeIds
    t.status = 'draft'
    await BowenStore.saveThought(t)
    this.item.promotedThoughtId = t.id
    await BowenStore.saveSpark(this.item)
    this.toastText = '已升级为思考札记'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    await BowenStore.deleteSpark(this.item.id)
    this.confirmDelete = false
    BowenNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'spark',
        title: this.item.title,
        meta: LabelOption.labelOf(LabelOption.sparkKinds(), this.item.kind),
        summary: this.item.body,
        body: this.item.promotedThoughtId.length > 0 ? '已升级为思考札记' : '',
        extra: this.item.tags.join(' · '),
        favorite: this.item.favorite,
        extraActionLabel: '升级为思考札记',
        onEdit: (): void => { BowenNav.openEditor('spark', this.item.id) },
        onFavorite: (): void => { void this.toggleFav() },
        onDelete: (): void => { this.confirmDelete = true },
        onExtraAction: (): void => { void this.toThought() }
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条灵感？')
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
