import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { DetailShell } from '../components/detail/DetailShell'
import { UserTopic } from '../models/ExplorationModels'
import { ExplorationStore } from '../services/ExplorationStore'
import { ExploreNav } from '../services/ExploreNav'
import { ExploreToast } from '../services/ExploreToast'

@Component
export struct TopicsOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('progressRev') @Watch('onRev') progressRev: number = 0
  @State topics: UserTopic[] = []
  @State titleInput: string = ''
  @State summaryInput: string = ''
  @State editing: boolean = false

  aboutToAppear(): void {
    ExplorationStore.touchTopicsPanel()
    this.reload()
  }

  onRev(): void {
    this.reload()
  }

  private reload(): void {
    this.topics = ExplorationStore.allTopics()
  }

  private async saveTopic(): Promise<void> {
    if (this.titleInput.trim().length < 2) {
      ExploreToast.show('专题名称至少 2 个字')
      return
    }
    const t = new UserTopic()
    t.title = this.titleInput.trim()
    t.summary = this.summaryInput.trim()
    t.discoveryIds = []
    t.atlasIds = []
    await ExplorationStore.saveTopic(t)
    this.titleInput = ''
    this.summaryInput = ''
    this.editing = false
    this.reload()
    ExploreToast.show('专题已创建')
  }

  private async removeTopic(id: string): Promise<void> {
    await ExplorationStore.deleteTopic(id)
    this.reload()
    ExploreToast.show('专题已删除')
  }

  build() {
    DetailShell({
      title: '探索专题',
      onClose: (): void => { ExploreNav.closeTopics() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('将图鉴与发现整理成专题，例如「城市观察」「身边的小科学」。')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.editing) {
            TextInput({ text: this.titleInput, placeholder: '专题名称' })
              .width('100%')
              .onChange((v: string): void => { this.titleInput = v })
            TextArea({ text: this.summaryInput, placeholder: '专题简介（可选）' })
              .width('100%')
              .height(72)
              .onChange((v: string): void => { this.summaryInput = v })
            Row({ space: Theme.space.s2 }) {
              Column() {
                AppButton({
                  label: '保存专题',
                  onTap: (): void => { void this.saveTopic() }
                })
              }
              .layoutWeight(1)
              .onClick((): void => { void this.saveTopic() })
              Column() {
                AppButton({
                  label: '取消',
                  variant: 'secondary',
                  onTap: (): void => { this.editing = false }
                })
              }
              .layoutWeight(1)
              .onClick((): void => { this.editing = false })
            }
            .width('100%')
          } else {
            Column() {
              AppButton({
                label: '新建专题',
                onTap: (): void => { this.editing = true }
              })
            }
            .width('100%')
            .onClick((): void => { this.editing = true })
          }

          if (this.topics.length === 0) {
            AppEmpty({
              title: '还没有专题',
              description: '创建第一个专题，整理你的探索主题',
              actionLabel: '新建专题',
              onAction: (): void => { this.editing = true }
            })
          } else {
            ForEach(this.topics, (topic: UserTopic) => {
              Column({ space: Theme.space.s2 }) {
                Text(topic.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                if (topic.summary.length > 0) {
                  Text(topic.summary)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().textSecondary)
                    .width('100%')
                }
                Text(`记录 ${topic.discoveryIds.length} · 图鉴 ${topic.atlasIds.length}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                Column() {
                  AppButton({
                    label: '删除专题',
                    variant: 'secondary',
                    onTap: (): void => { void this.removeTopic(topic.id) }
                  })
                }
                .width('100%')
                .onClick((): void => { void this.removeTopic(topic.id) })
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.md)
            }, (topic: UserTopic) => topic.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
  }
}
