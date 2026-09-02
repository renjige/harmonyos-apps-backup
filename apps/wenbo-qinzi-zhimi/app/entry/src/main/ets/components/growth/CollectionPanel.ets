import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { FavoriteCollection } from '../../models/GrowthModels'
import { ProgressStore } from '../../services/ProgressStore'

@Component
export struct CollectionPanel {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State collections: FavoriteCollection[] = []
  @State newTitle: string = ''
  @State newTag: string = ''
  @StorageLink('quizTick') @Watch('onTick') tick: number = 0
  onBack: () => void = () => {}

  aboutToAppear(): void {
    this.refresh()
  }

  onTick(): void {
    this.refresh()
  }

  private refresh(): void {
    this.collections = ProgressStore.collections()
  }

  private async createCollection(): Promise<void> {
    const title = this.newTitle.trim()
    if (title.length === 0) {
      return
    }
    await ProgressStore.addCollection(title, this.newTag.trim())
    this.newTitle = ''
    this.newTag = ''
    this.refresh()
  }

  build() {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Text('返回')
          .fontSize(15)
          .fontColor(Theme.colors().brandPrimary)
          .onClick(() => this.onBack())
        Blank()
        Text('收藏夹')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
        Blank()
      }
      .width('100%')

      Column({ space: 8 }) {
        TextInput({ text: this.newTitle, placeholder: '新建收藏夹名称' })
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 16, right: 16 })
          .onChange((v: string) => { this.newTitle = v })
        TextInput({ text: this.newTag, placeholder: '标签（可选，如「周末练」）' })
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.pill)
          .padding({ left: 16, right: 16 })
          .onChange((v: string) => { this.newTag = v })
        AppButton({ label: '创建收藏夹', onTap: (): void => { void this.createCollection() } })
      }
      .width('100%')

      if (this.collections.length === 0) {
        AppEmpty({
          title: '还没有收藏夹',
          description: '收藏题目时可归入文件夹，方便周末一起练',
          actionLabel: '去看收藏',
          onAction: () => {
            this.onBack()
            AppStorage.setOrCreate('mainTab', 4)
          }
        })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            ForEach(this.collections, (c: FavoriteCollection) => {
              Row({ space: 10 }) {
                Column({ space: 4 }) {
                  Text(c.title)
                    .fontSize(16)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  Text(`${c.puzzleIds.length} 题${c.tag.length > 0 ? ' · ' + c.tag : ''}`)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('删除')
                  .fontSize(13)
                  .fontColor(Theme.colors().danger)
                  .onClick((): void => { void ProgressStore.removeCollection(c.id).then(() => this.refresh()) })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(20)
            }, (c: FavoriteCollection) => c.id)
          }
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
    }
    .padding({ left: 20, right: 20, top: 16 })
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
