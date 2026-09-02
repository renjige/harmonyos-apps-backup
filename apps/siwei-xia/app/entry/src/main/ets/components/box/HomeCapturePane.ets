import { Theme } from '../design-system/Theme'
import { TagChipRow } from './TagChipRow'
import { ImagePathUtil } from '../../services/ImagePathUtil'

@Component
export struct HomeCapturePane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop draft: string = ''
  @Prop imagePath: string = ''
  @Prop pickTagsCsv: string = '工作,生活,灵感'
  @Prop pickedCsv: string = ''
  @Prop tagEpoch: number = 0
  onDraftChange: (v: string) => void = (_v: string) => {}
  onToggleTag: (name: string) => void = (_n: string) => {}
  onVoiceHint: () => void = () => {}
  onPickImage: () => void = () => {}
  onCapture: () => void = () => {}

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column()
          .width(36)
          .height(4)
          .backgroundColor(Theme.colors().brandAccent)
          .borderRadius(Theme.radius.pill)
        Blank()
      }
      .width('100%')
      Text('从匣口写下')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      TextArea({ text: this.draft, placeholder: '此刻在想什么？写下第一句…' })
        .height(96)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.onDraftChange(v) })
      TagChipRow({
        namesCsv: this.pickTagsCsv,
        selectedCsv: this.pickedCsv,
        chipEpoch: this.tagEpoch,
        onToggle: (name: string): void => { this.onToggleTag(name) }
      })
      Row({ space: Theme.space.s2 }) {
        Text('智慧语音')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .borderRadius(Theme.radius.pill)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .onClick((): void => { this.onVoiceHint() })
        Text('图片')
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .borderRadius(Theme.radius.pill)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .onClick((): void => { this.onPickImage() })
        Blank()
        Text(this.imagePath.length > 0 ? '收进匣子 · 已附图' : '收进匣子')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 18, right: 18, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.onCapture() })
      }
      .width('100%')
      if (this.imagePath.length > 0 && ImagePathUtil.isReadable(this.imagePath)) {
        Image(ImagePathUtil.toDisplayUri(this.imagePath))
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)
      }
    }
    .width('100%')
    .padding(Theme.space.s5)
    .backgroundColor(Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
