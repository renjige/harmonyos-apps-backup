import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { PolishChange } from '../../models/LanguageCraftModels'

@Component
export struct PolishResultBlock {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop note: string = ''
  @Prop originalText: string = ''
  @Prop polishedText: string = ''
  @Prop changes: PolishChange[] = []
  @Prop rewriteLevel: string = ''
  @Prop origLen: number = 0
  @Prop polishedLen: number = 0
  onCopy: () => void = () => {}
  onSave: () => void = () => {}
  onSaveManuscript: () => void = () => {}

  private levelColor(): string {
    if (this.rewriteLevel === '高') {
      return Theme.of(this.darkModeOn).brandPrimary
    }
    if (this.rewriteLevel === '中') {
      return Theme.of(this.darkModeOn).warning
    }
    return Theme.of(this.darkModeOn).textSecondary
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row({ space: Theme.space.s2 }) {
        Column({ space: 2 }) {
          Text(`${this.origLen}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
          Text('原文字数')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textTertiary)
        }
        .layoutWeight(1)
        Column({ space: 2 }) {
          Text(`${this.polishedLen}`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
          Text('润色后')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textTertiary)
        }
        .layoutWeight(1)
        Column({ space: 2 }) {
          Text(this.rewriteLevel.length > 0 ? this.rewriteLevel : '—')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.levelColor())
          Text('改写幅度')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textTertiary)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
      .borderRadius(Theme.radius.lg)

      Text(this.note)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.of(this.darkModeOn).brandPrimary)
        .width('100%')
      if (this.changes.length > 0) {
        Column({ space: 4 }) {
          Text('本次改动')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).textSecondary)
            .width('100%')
          ForEach(this.changes, (row: PolishChange) => {
            Text(`· ${row.label}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
          }, (row: PolishChange) => row.id)
        }
        .width('100%')
      }
      Column({ space: 6 }) {
        Text('原文')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.of(this.darkModeOn).textTertiary)
          .width('100%')
        Text(this.originalText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
          .lineHeight(22)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.of(this.darkModeOn).surfaceSubtle)
      .borderRadius(Theme.radius.lg)

      Column({ space: 6 }) {
        Row({ space: 6 }) {
          AppIcon({ name: 'sparkle', iconSize: Theme.icon.sm, color: Theme.of(this.darkModeOn).brandPrimary })
          Text('润色后（可直接复制发送）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.of(this.darkModeOn).brandPrimary)
        }
        Text(this.polishedText)
          .fontSize(Theme.type.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.of(this.darkModeOn).textPrimary)
          .lineHeight(26)
          .width('100%')
      }
      .width('100%')
      .padding(Theme.space.s4)
      .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
      .borderRadius(Theme.radius.lg)
      .border({ width: 1, color: Theme.of(this.darkModeOn).brandPrimaryContainer })

      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '复制',
            variant: 'secondary',
            onTap: (): void => { this.onCopy() }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '存稿本',
            variant: 'secondary',
            onTap: (): void => { this.onSaveManuscript() }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '存历史',
            onTap: (): void => { this.onSave() }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }
}
