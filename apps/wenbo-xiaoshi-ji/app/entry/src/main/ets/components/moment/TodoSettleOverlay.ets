import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MomentStore } from '../../services/MomentStore'

@Component
export struct TodoSettleOverlay {
  @Prop todoId: string = ''
  @Prop preview: string = ''
  onClosed: (saved: boolean) => void = (saved: boolean) => {
    if (saved) {
      return
    }
  }
  @State feeling: string = ''

  private async save(): Promise<void> {
    const ok = await MomentStore.settleTodoAsNote(this.todoId, this.feeling)
    this.onClosed(ok)
  }

  build() {
    Column() {
      Column({ space: Theme.space.s3 }) {
        Text('做成了这件事')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .width('100%')
        Text(this.preview)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text('用一句话记下做成的感觉（可选）')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.feeling, placeholder: '轻松了一点 / 比想象中快 / 想再做一次…' })
          .height(72)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .placeholderColor(Theme.colors().textTertiary)
          .caretColor(Theme.colors().brandPrimary)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(12)
          .onChange((v: string): void => { this.feeling = v })
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppButton({
              label: '跳过',
              variant: 'secondary',
              onTap: (): void => this.onClosed(false)
            })
          }.layoutWeight(1)
          Column() {
            AppButton({
              label: '记入时间线',
              onTap: (): void => { void this.save() }
            })
          }.layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(16)
      .shadow({ radius: 16, color: 'rgba(44,44,44,0.16)', offsetY: 6 })
    }
    .width('100%')
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 56 })
  }
}
