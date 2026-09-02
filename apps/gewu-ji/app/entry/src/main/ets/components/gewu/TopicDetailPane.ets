import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from '../detail/DetailShell'
import { KnowledgeListCard } from './KnowledgeListCard'
import { GewuTopic } from '../../models/FieldModels'
import { KnowledgeObject } from '../../models/KnowledgeModels'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'

@Component
export struct TopicDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('practiceFocusId') @Watch('onFocusChange') focusId: string = ''
  onChanged: () => void = () => {}
  @State topic: GewuTopic = new GewuTopic()
  @State items: KnowledgeObject[] = []
  @State confirmDel: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onFocusChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const t = await FieldStore.findTopic(this.focusId)
    if (t === undefined) {
      this.topic = new GewuTopic()
      this.items = []
      return
    }
    this.topic = t
    const out: KnowledgeObject[] = []
    for (const id of t.objectIds) {
      const obj = KnowledgeCatalog.resolveById(id)
      if (obj !== undefined) {
        out.push(obj)
      }
    }
    this.items = out
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async remove(): Promise<void> {
    await FieldStore.deleteTopic(this.topic.id)
    this.onChanged()
    this.showToast('专题册已删除')
    setTimeout((): void => { GewuDetailNav.closePractice() }, 400)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.topic.title.length > 0 ? this.topic.title : '专题册',
        onClose: (): void => { GewuDetailNav.closePractice() },
        body: (): void => { this.Body() }
      })
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .position({ x: '50%', y: 48 })
          .translate({ x: '-50%' })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Body() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Text(`收录 ${this.items.length} 件知识物`)
          .fontSize(Theme.type.bodyS)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        AppButton({
          label: '编辑收录',
          variant: 'secondary',
          onTap: (): void => { GewuDetailNav.openPractice('topic', this.topic.id) }
        })
        if (this.items.length === 0) {
          AppEmpty({
            title: '专题还是空的',
            description: '编辑专题，从预置图鉴里挑选你想集中研读的物件。',
            actionLabel: '去收录',
            onAction: (): void => { GewuDetailNav.openPractice('topic', this.topic.id) }
          })
        } else {
          ForEach(this.items, (item: KnowledgeObject) => {
            KnowledgeListCard({
              item: item,
              onTap: (): void => {
                GewuDetailNav.closePractice()
                GewuDetailNav.open(item.id)
              }
            })
          }, (item: KnowledgeObject) => item.id)
        }
        if (!this.confirmDel) {
          AppButton({
            label: '删除专题册',
            variant: 'ghost',
            onTap: (): void => { this.confirmDel = true }
          })
        } else {
          Text('删除专题不会删除图鉴与观察，确认删除？')
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: Theme.space.s3 }) {
            Column() {
              AppButton({
                label: '取消',
                variant: 'ghost',
                onTap: (): void => { this.confirmDel = false }
              })
            }
            .layoutWeight(1)
            Column() {
              AppButton({
                label: '确认删除',
                variant: 'danger',
                onTap: (): void => { void this.remove() }
              })
            }
            .layoutWeight(1)
          }
          .width('100%')
        }
        Row().height(Theme.space.s10)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
