import { StudyLog } from '../../models/BowenModels'
import { BowenStore } from '../../services/BowenStore'
import { BowenNav } from '../../services/BowenNav'
import { GenericDetailPane } from './GenericDetailPane'
import { AppButton } from '../design-system/AppButton'
import { Theme } from '../design-system/Theme'

@Component
export struct StudyLogDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('bowenDataRev') bowenDataRev: number = 0
  @Prop itemId: string = ''
  @State item: StudyLog = new StudyLog()
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await BowenStore.findStudyLog(this.itemId)
    if (t !== undefined) {
      this.item = t
    }
  }

  private async doDelete(): Promise<void> {
    await BowenStore.deleteStudyLog(this.item.id)
    this.confirmDelete = false
    BowenNav.closeDetails()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      GenericDetailPane({
        kind: 'study',
        title: this.item.topic,
        meta: this.item.studyDate.length > 0 ? `学习记录 · ${this.item.studyDate}` : '学习记录',
        summary: this.item.content,
        body: this.item.harvest,
        extra: this.item.summary,
        favorite: false,
        onEdit: (): void => { BowenNav.openEditor('study', this.item.id) },
        onFavorite: (): void => {},
        onDelete: (): void => { this.confirmDelete = true }
      })
      if (this.confirmDelete) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这条学习记录？')
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
