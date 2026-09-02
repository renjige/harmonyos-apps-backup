import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { RmCheckItem, RmDateUtil, RmLabels } from '../../models/RmModels'
import { RmStore } from '../../services/RmStore'
import { RmDetailNav } from '../../services/RmDetailNav'
import { RmMedia } from '../../services/RmMedia'
import { RmConfirmDialog } from '../rm/RmConfirmDialog'

@Component
export struct CheckItemDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onItemIdChange') itemId: string = ''
  onChanged: () => void = () => {}
  @State item: RmCheckItem = new RmCheckItem()
  @State feeling: string = ''
  @State harvest: string = ''
  @State note: string = ''
  @State confirmDel: boolean = false
  @State toastText: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onItemIdChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async reload(): Promise<void> {
    if (this.itemId.length === 0) {
      return
    }
    const found = await RmStore.findItem(this.itemId)
    if (found !== undefined) {
      this.item = found
      this.feeling = found.feeling
      this.harvest = found.harvest
      this.note = found.note
    }
  }

  private async saveRecord(): Promise<void> {
    if (this.saving) {
      return
    }
    if (this.itemId.length === 0) {
      this.showToast('记录无效，请返回重试')
      return
    }
    this.saving = true
    const found = await RmStore.findItem(this.itemId)
    if (found === undefined) {
      this.saving = false
      this.showToast('记录不存在，请返回重试')
      return
    }
    found.feeling = this.feeling
    found.harvest = this.harvest
    found.note = this.note
    if (found.status !== 'done') {
      found.status = 'done'
      found.completedAt = Date.now()
    }
    await RmStore.saveItem(found)
    this.item = found
    this.saving = false
    this.onChanged()
    this.showToast('体验记录已保存')
  }

  private async toggleStar(): Promise<void> {
    if (this.itemId.length === 0) {
      return
    }
    const found = await RmStore.findItem(this.itemId)
    if (found === undefined) {
      return
    }
    found.feeling = this.feeling
    found.harvest = this.harvest
    found.note = this.note
    found.starred = !found.starred
    await RmStore.saveItem(found)
    this.item = found
    this.onChanged()
    this.showToast(found.starred ? '已收藏这次体验' : '已取消收藏')
  }

  private async remove(): Promise<void> {
    await RmStore.deleteItem(this.itemId)
    this.confirmDel = false
    this.onChanged()
    RmDetailNav.closeItem()
  }

  private handleSaveTap(): void {
    void this.saveRecord()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(RmMedia.paperBanner())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(90)
              .linearGradient({ angle: 180, colors: [['rgba(12,74,110,0)', 0], ['rgba(12,74,110,0.82)', 1]] })
            Text(this.item.title.length > 0 ? this.item.title : '体验记录')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F8FAFC')
              .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.md)

          Text(`${RmLabels.itemStatusLabel(this.item.status)}${this.item.completedAt > 0 ? ' · ' + RmDateUtil.displayDate(RmDateUtil.keyFromDate(new Date(this.item.completedAt))) : ''}`)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('过程感受')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.feeling, placeholder: '完成时的感受…' })
              .height(88)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string): void => { this.feeling = v })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s2 }) {
            Text('收获总结')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.harvest, placeholder: '这次体验带来了什么…' })
              .height(88)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string): void => { this.harvest = v })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Column({ space: Theme.space.s2 }) {
            Text('备注')
              .fontSize(Theme.type.subtitleS)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '可选备注…' })
              .height(72)
              .width('100%')
              .backgroundColor(Theme.colors().surfaceSubtle)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string): void => { this.note = v })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Row() {
            AppButton({
              label: this.item.status !== 'done' ? '标记完成并保存' : '保存体验记录',
              disabled: this.saving,
              onTap: (): void => { this.handleSaveTap() }
            })
          }
          .width('100%')
          .onClick((): void => { this.handleSaveTap() })

          Row() {
            AppButton({
              label: this.item.starred ? '取消收藏' : '收藏这次体验',
              variant: 'secondary',
              onTap: (): void => { void this.toggleStar() }
            })
          }
          .width('100%')
          .onClick((): void => { void this.toggleStar() })

          Row() {
            AppButton({
              label: '删除清单项',
              variant: 'danger',
              onTap: (): void => { this.confirmDel = true }
            })
          }
          .width('100%')
          .onClick((): void => { this.confirmDel = true })

          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)

      if (this.confirmDel) {
        RmConfirmDialog({
          title: '删除这个清单项？',
          message: '体验记录将一并删除。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.sm)
          .margin({ top: 8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
