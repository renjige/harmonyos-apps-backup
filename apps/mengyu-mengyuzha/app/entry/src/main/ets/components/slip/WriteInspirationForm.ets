import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MoodSelector } from './MoodSelector'
import { TagChipBar } from './TagChipBar'

@Component
export struct WriteInspirationForm {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Link titleText: string
  @Link bodyText: string
  @Link mood: string
  @Link customTag: string
  @Link favorited: boolean
  @Prop tagChoices: string[] = []
  @Prop selectedCsv: string = ''
  onToggleTag: (tag: string) => void = (_tag: string) => {}
  onAddTag: () => void = () => {}
  onToggleFav: () => void = () => {}

  build() {
    Column({ space: Theme.space.s5 }) {
      TextInput({ text: this.titleText, placeholder: '给这条灵感起个名字（可选）' })
        .width('100%')
        .height(48)
        .fontSize(Theme.type.title3)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .onChange((v: string) => { this.titleText = v })
      TextArea({ text: this.bodyText, placeholder: '今天想到什么？' })
        .width('100%')
        .height(200)
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
        Text('加入')
          .fontSize(Theme.type.subhead)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.md)
          .onClick((): void => { this.onAddTag() })
      }
      .width('100%')
      Row({ space: 8 }) {
        AppIcon({
          name: 'bookmark',
          iconSize: Theme.icon.md,
          color: this.favorited ? Theme.colors().brandAccent : Theme.colors().textTertiary
        })
        Text(this.favorited ? '已收藏' : '收藏这条灵感')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      }
      .width('100%')
      .padding(Theme.space.s3)
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.md)
      .onClick((): void => { this.onToggleFav() })
    }
    .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 120 })
    .width('100%')
  }
}
