import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { CourtyardLocalStore } from '../../services/CourtyardLocalStore'
import { WorkItem } from '../../models/CourtyardModels'
import { DetailShell } from './DetailShell'

@Component
export struct WorkDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop workId: string = ''
  @State item: WorkItem = new WorkItem()
  @State confirm: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}

  aboutToAppear(): void {
    const row = CourtyardLocalStore.findWork(this.workId)
    if (row !== undefined) {
      this.item = row
    }
  }

  private async remove(): Promise<void> {
    if (!this.confirm) {
      this.confirm = true
      this.toastText = '再点一次确认删除'
      setTimeout((): void => { this.toastText = '' }, 2000)
      return
    }
    await CourtyardLocalStore.removeWork(this.workId)
    this.onClose()
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.title.length > 0 ? this.item.title : '作品',
        onClose: (): void => { this.onClose() }
      }) {
        Column({ space: Theme.space.s4 }) {
          AppCard({ title: '正文' }) {
            Text(this.item.body)
              .fontSize(Theme.type.bodyL)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '格律摘记' }) {
            Text(this.item.meterSummary.length > 0 ? this.item.meterSummary : '未保存检测结果')
              .fontSize(Theme.type.bodyM)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          AppButton({
            label: this.confirm ? '确认删除此篇' : '删除作品',
            variant: 'danger',
            onTap: (): void => { void this.remove() }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding(12)
          .backgroundColor('rgba(44,24,16,0.92)')
          .borderRadius(8)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
