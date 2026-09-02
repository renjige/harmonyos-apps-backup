import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { OverlayShell } from './OverlayShell'
import { TopicShelf } from '../../models/StudyModels'
import { StudyStore } from '../../services/StudyStore'

@Component
export struct TopicListPane {
  @StorageLink('studyEpoch') @Watch('onChange') studyEpoch: number = 0
  @State topics: TopicShelf[] = []
  onClose: () => void = () => {}
  onOpenTopic: (id: string) => void = (_id: string) => {}
  onCreateTopic: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.topics = await StudyStore.loadTopics()
  }

  build() {
    OverlayShell({
      title: '专题书架',
      onClose: (): void => { this.onClose() },
      body: (): void => { this.Body() }
    })
  }

  @Builder
  Body() {
    Column({ space: Theme.space.s3 }) {
      AppButton({
        label: '新建专题',
        onTap: (): void => { this.onCreateTopic() }
      })
      if (this.topics.length === 0) {
        AppEmpty({
          title: '还没有专题',
          description: '把相关书摘整理成「哲学书单」「职场进阶」等专题吧',
          actionLabel: '新建专题',
          onAction: (): void => { this.onCreateTopic() }
        })
      } else {
        ForEach(this.topics, (t: TopicShelf) => {
          Column({ space: 6 }) {
            Text(t.title)
              .fontSize(Theme.type.bodyM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            if (t.summary.length > 0) {
              Text(t.summary)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .maxLines(2)
                .width('100%')
            }
            Text(`${t.noteCount()} 条书摘`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(12)
          .onClick((): void => { this.onOpenTopic(t.id) })
        }, (t: TopicShelf) => `${t.id}_${t.updatedAt}`)
      }
    }
    .width('100%')
  }
}
