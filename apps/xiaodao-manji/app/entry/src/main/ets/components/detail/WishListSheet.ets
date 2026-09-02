import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { XdLabels, XdWishItem } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'
import { XdConfirmDialog } from '../xd/XdConfirmDialog'

@Component
export struct WishListSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('xdDataRev') @Watch('onDataRev') dataRev: number = 0
  onChanged: () => void = () => {}
  @State items: XdWishItem[] = []
  @State title: string = ''
  @State note: string = ''
  @State editingId: string = ''
  @State confirmDeleteId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onDataRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await XdStore.loadWishes()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2800)
  }

  private async saveWish(): Promise<void> {
    const t = this.title.trim()
    if (t.length === 0) {
      this.showToast('请填写想做的事')
      return
    }
    let w = XdWishItem.createNew(t)
    if (this.editingId.length > 0) {
      const found = await XdStore.findWish(this.editingId)
      if (found !== undefined) {
        w = found
      }
    }
    w.title = t
    w.note = this.note.trim()
    await XdStore.saveWish(w)
    this.title = ''
    this.note = ''
    this.editingId = ''
    await this.reload()
    this.onChanged()
    this.showToast('已保存')
  }

  private async cycleStatus(w: XdWishItem): Promise<void> {
    if (w.status === 'wish') {
      w.status = 'active'
    } else if (w.status === 'active') {
      w.status = 'done'
    } else {
      w.status = 'wish'
    }
    await XdStore.saveWish(w)
    await this.reload()
    this.onChanged()
  }

  private async removeWish(id: string): Promise<void> {
    await XdStore.deleteWish(id)
    this.confirmDeleteId = ''
    await this.reload()
    this.onChanged()
    this.showToast('已删除')
  }

  build() {
    Stack() {
      DetailShell({ title: '生活清单', onClose: (): void => { XdDetailNav.closeWishList() } }) {
        Column() {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Text('记录想完成的小事，不是待办打卡')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              TextInput({ text: this.title, placeholder: '想看的电影 / 想去的地方…' })
                .onChange((v: string): void => { this.title = v })
              TextInput({ text: this.note, placeholder: '备注（可选）' })
                .onChange((v: string): void => { this.note = v })
              AppButton({ label: this.editingId.length > 0 ? '更新' : '添加', variant: 'primary', onTap: (): void => { void this.saveWish() } })
              if (this.items.length === 0) {
                AppEmpty({ title: '清单还是空的', description: '写下一件想慢慢完成的事' })
              } else {
                ForEach(this.items, (w: XdWishItem) => {
                  Row({ space: 8 }) {
                    Column({ space: 4 }) {
                      Text(w.title)
                        .fontSize(Theme.type.subtitleS)
                        .fontColor(Theme.colors().textPrimary)
                      if (w.note.length > 0) {
                        Text(w.note)
                          .fontSize(Theme.type.caption)
                          .fontColor(Theme.colors().textSecondary)
                      }
                    }
                    .layoutWeight(1)
                    Text(XdLabels.wishStatusLabel(w.status))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .onClick((): void => { void this.cycleStatus(w) })
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => {
                    this.editingId = w.id
                    this.title = w.title
                    this.note = w.note
                  })
                  .gesture(
                    LongPressGesture().onAction((): void => { this.confirmDeleteId = w.id })
                  )
                }, (w: XdWishItem) => w.id)
              }
              Column().height(Theme.space.s10)
            }
            .padding(Theme.space.pageX)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(30)
      }
      if (this.confirmDeleteId.length > 0) {
        XdConfirmDialog({
          title: '删除这条心愿？',
          message: '删除后无法恢复',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.removeWish(this.confirmDeleteId) },
          onCancel: (): void => { this.confirmDeleteId = '' }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
