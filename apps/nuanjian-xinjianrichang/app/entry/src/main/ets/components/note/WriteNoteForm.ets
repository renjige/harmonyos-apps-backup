import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MoodSelector } from './MoodSelector'
import { TagChipBar } from './TagChipBar'

@Component
export struct WriteNoteForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link titleText: string
  @Link bodyText: string
  @Link mood: string
  @Link customTag: string
  @Link photo0: string
  @Link photo1: string
  @Link photo2: string
  @Prop tagChoices: string[] = []
  @Prop selectedCsv: string = ''
  onToggleTag: (tag: string) => void = (_tag: string) => {}
  onAddTag: () => void = () => {}
  onPickPhoto: () => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      TextInput({ text: this.titleText, placeholder: '今天的小确幸' })
        .width('100%')
        .height(48)
        .fontSize(Theme.type.title3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onChange((v: string) => { this.titleText = v })
      TextArea({ text: this.bodyText, placeholder: '写下今天想留下的话……' })
        .width('100%')
        .height(180)
        .fontSize(Theme.type.body)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onChange((v: string) => { this.bodyText = v })
      Text('心情').fontSize(Theme.type.subhead).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      MoodSelector({ selected: this.mood, onSelect: (id: string) => { this.mood = id } })
      Text('标签').fontSize(Theme.type.subhead).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).width('100%')
      TagChipBar({
        choices: this.tagChoices,
        selectedCsv: this.selectedCsv,
        onToggle: (tag: string): void => { this.onToggleTag(tag) }
      })
      Row({ space: 8 }) {
        TextInput({ text: this.customTag, placeholder: '自定义标签' })
          .layoutWeight(1)
          .height(40)
          .onChange((v: string) => { this.customTag = v })
        AppButton({ label: '加入', variant: 'secondary', onTap: (): void => { this.onAddTag() } })
      }
      .width('100%')
      AppButton({
        label: '添加图片',
        variant: 'secondary',
        onTap: (): void => { this.onPickPhoto() }
      })
      if (this.photo0.length > 0) {
        Row({ space: 8 }) {
          Image(this.photo0).width(72).height(72).objectFit(ImageFit.Cover).borderRadius(10)
          if (this.photo1.length > 0) {
            Image(this.photo1).width(72).height(72).objectFit(ImageFit.Cover).borderRadius(10)
          }
          if (this.photo2.length > 0) {
            Image(this.photo2).width(72).height(72).objectFit(ImageFit.Cover).borderRadius(10)
          }
        }
        .width('100%')
      }
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 120 })
    .width('100%')
  }
}
