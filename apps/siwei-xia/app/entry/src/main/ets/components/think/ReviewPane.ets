import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ReviewItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ReviewPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State items: ReviewItem[] = []
  @State editing: ReviewItem = new ReviewItem()
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    this.showEdit = false
    this.confirmDelete = false
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ThinkStore.loadReviews()
  }

  private openNew(): void {
    const it = new ReviewItem()
    it.id = ThinkStore.newId('rv')
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.confirmDelete = false
    this.showEdit = true
  }

  private async save(): Promise<void> {
    if (this.editing.title.trim().length === 0) {
      return
    }
    await ThinkStore.saveReview(this.editing)
    this.showEdit = false
    await this.reload()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeReview(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('思考复盘')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('新建')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.openNew() })
      }
      .width('100%')
      if (this.showEdit) {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.editing.title, placeholder: '复盘标题' })
              .height(44)
              .onChange((v: string) => { this.editing.title = v })
            TextInput({ text: this.editing.subject, placeholder: '复盘主题（项目/学习/生活）' })
              .height(44)
              .onChange((v: string) => { this.editing.subject = v })
            TextArea({ text: this.editing.beforeText, placeholder: '当时的理解或做法' })
              .height(100)
              .onChange((v: string) => { this.editing.beforeText = v })
            TextArea({ text: this.editing.afterText, placeholder: '现在的新理解' })
              .height(100)
              .onChange((v: string) => { this.editing.afterText = v })
            AppButton({ label: '保存复盘', onTap: (): void => { void this.save() } })
            AppButton({ label: '返回列表', variant: 'secondary', onTap: (): void => { this.showEdit = false } })
            AppButton({
              label: this.confirmDelete ? '再点一次删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.items.length === 0) {
              AppEmpty({ title: '还没有复盘', description: '对照旧记录，写下新的收获' })
            } else {
              ForEach(this.items, (it: ReviewItem) => {
                Column({ space: 6 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.afterText.length > 0 ? it.afterText : '新理解待写')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                  Text(DateHelper.formatShort(it.updatedAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  this.editing = ThinkStore.cloneReview(it)
                  this.confirmDelete = false
                  this.showEdit = true
                })
              }, (it: ReviewItem) => `${it.id}|${it.updatedAt}`)
            }
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
  }
}
