import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { SparkItem } from '../../models/KnowledgeModels'
import { KnowledgeStore } from '../../services/KnowledgeStore'
import { KnowledgeNav } from '../../services/KnowledgeNav'

@Component
export struct WriteSparkPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @Prop @Watch('onToken') refreshToken: number = 0
  @State title: string = ''
  @State body: string = ''
  @State tags: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.hydrate()
  }

  onToken(): void {
    this.hydrate()
  }

  private hydrate(): void {
    this.title = ''
    this.body = ''
    this.tags = ''
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.toastText = '请写下一个标题'
      setTimeout(() => { this.toastText = '' }, 2200)
      return
    }
    const item = new SparkItem()
    item.id = KnowledgeStore.newSparkId()
    item.title = this.title.trim()
    item.body = this.body.trim()
    item.tags = this.tags.trim()
    item.createdAt = Date.now()
    await KnowledgeStore.saveSpark(item)
    this.toastText = '已经收进轻知阁'
    setTimeout(() => {
      this.toastText = ''
      KnowledgeNav.closeSpark()
    }, 700)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column({ space: Theme.space.s4 }) {
        Row() {
          Column() {
            AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { KnowledgeNav.closeSpark() })
          Text('灵感记录')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        }
        .width('100%')
        .padding({ left: 12, right: Theme.space.pageX, top: 8 })

        Text('读书时的想法、突然想到的观点、值得记住的一句话，都可以轻轻记下。')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.title, placeholder: '标题' })
            .onChange((v: string) => { this.title = v })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          TextArea({ text: this.body, placeholder: '内容' })
            .onChange((v: string) => { this.body = v })
            .height(140)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          TextInput({ text: this.tags, placeholder: '标签，用逗号分开' })
            .onChange((v: string) => { this.tags = v })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          AppButton({
            label: '保存',
            variant: 'primary',
            onTap: (): void => { void this.save() }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
