import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { RenoDates, RenoNote } from '../../models/RenoModels'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RenoNote = new RenoNote()
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}

  build() {
    DetailShell({
      title: this.item.title,
      coverKey: RenoDates.coverOf(this.item.stage),
      onBack: () => this.onClose()
    }) {
      Column({ space: Theme.space.s4 }) {
        Text(`${RenoDates.displayDate(this.item.date)} · ${this.item.kind} · ${this.item.stage}`)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        Column({ space: 8 }) {
          Text('记录内容')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Text(this.item.body.length > 0 ? this.item.body : '暂无正文')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        if (this.item.photoUri.length > 0) {
          Image(this.item.photoUri)
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.md)
            .objectFit(ImageFit.Cover)
        }
        if (this.item.remark.length > 0) {
          Text(this.item.remark)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        AppButton({ label: '编辑记录', onTap: () => this.onEdit() })
        AppButton({ label: '删除记录', variant: 'danger', onTap: () => this.onDelete() })
      }
      .width('100%')
    }
  }
}
