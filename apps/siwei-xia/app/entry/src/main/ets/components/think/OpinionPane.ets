import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { OpinionItem } from '../../models/ThinkModels'
import { ThinkStore } from '../../services/ThinkStore'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct OpinionPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onPaneReload') paneToken: number = 0
  @State items: OpinionItem[] = []
  @State editing: OpinionItem = new OpinionItem()
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onPaneReload(): void {
    this.showEdit = false
    this.confirmDelete = false
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ThinkStore.loadOpinions()
  }

  private openNew(): void {
    const it = new OpinionItem()
    it.id = ThinkStore.newId('op')
    it.createdAt = Date.now()
    it.updatedAt = it.createdAt
    this.editing = it
    this.confirmDelete = false
    this.showEdit = true
  }

  private async save(): Promise<void> {
    if (this.editing.title.trim().length === 0 || this.editing.viewpoint.trim().length === 0) {
      this.toastText = '标题和观点都需要填写'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await ThinkStore.saveOpinion(this.editing)
    this.showEdit = false
    await this.reload()
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ThinkStore.removeOpinion(this.editing.id)
    this.showEdit = false
    await this.reload()
  }

  build() {
    Column() {
      Row() {
        Text('观点卡片')
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
            TextInput({ text: this.editing.title, placeholder: '标题' })
              .height(44)
              .onChange((v: string) => { this.editing.title = v })
            TextArea({ text: this.editing.viewpoint, placeholder: '核心观点（一句话也可以）' })
              .height(120)
              .onChange((v: string) => { this.editing.viewpoint = v })
            TextArea({ text: this.editing.remark, placeholder: '备注 / 复盘时补上的新理解' })
              .height(88)
              .onChange((v: string) => { this.editing.remark = v })
            AppButton({ label: '保存观点', onTap: (): void => { void this.save() } })
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
              AppEmpty({ title: '还没有观点卡片', description: '把一句判断写成卡片，方便回头对照' })
            } else {
              ForEach(this.items, (it: OpinionItem) => {
                Column({ space: 6 }) {
                  Text(it.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.colors().textPrimary)
                    .width('100%')
                  Text(it.viewpoint)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(3)
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
                  this.editing = ThinkStore.cloneOpinion(it)
                  this.confirmDelete = false
                  this.showEdit = true
                })
              }, (it: OpinionItem) => `${it.id}|${it.updatedAt}`)
            }
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.On)
        .edgeEffect(EdgeEffect.Spring)
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.md)
      }
    }
    .width('100%')
    .height('100%')
  }
}
