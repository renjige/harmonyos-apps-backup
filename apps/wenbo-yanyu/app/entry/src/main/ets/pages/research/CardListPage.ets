import { Theme } from '../../components/design-system/Theme'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ViewpointCard } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct CardListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: ViewpointCard[] = []
  @State pendingId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async reload(): Promise<void> {
    this.items = await ResearchStore.listCards()
  }

  private async remove(id: string): Promise<void> {
    if (this.pendingId !== id) {
      this.pendingId = id
      this.showToast('再点一次确认删除卡片')
      return
    }
    await ResearchStore.deleteCard(id)
    this.pendingId = ''
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '观点卡片' })
        Text('在笔记详情里把核心观点生成卡片，方便快速翻看。')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.of(this.darkModeOn).textSecondary)
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
          .width('100%')
        if (this.items.length === 0) {
          AppEmpty({
            title: '还没有观点卡',
            description: '打开一条研究笔记，点「生成观点卡片」。',
            actionLabel: '去写笔记',
            onAction: (): void => { ResearchNav.open('notes') }
          })
            .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.items, (c: ViewpointCard) => {
                Column({ space: 8 }) {
                  Text(c.quote)
                    .fontSize(Theme.type.body)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(ResearchStore.timeLabel(c.createdAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                  Text(this.pendingId === c.id ? '再点确认删除' : '删除卡片')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).danger)
                    .onClick((): void => { void this.remove(c.id) })
                }
                .width('100%')
                .padding(Theme.space.s5)
                .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
                .borderRadius(Theme.radius.lg)
                .onClick((): void => {
                  if (c.sourceId.length > 0) {
                    ResearchNav.openNoteDetail(c.sourceId)
                  }
                })
              }, (c: ViewpointCard) => c.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
