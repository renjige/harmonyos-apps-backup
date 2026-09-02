import { Theme } from '../../components/design-system/Theme'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { TimelineEvent } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct TimelinePage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: TimelineEvent[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  onRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ResearchStore.listTimeline()
  }

  private openEvent(e: TimelineEvent): void {
    if (e.kind === '笔记') {
      ResearchNav.openNoteDetail(e.id)
    }
  }

  build() {
    Column() {
      ResearchBar({ title: '时间线整理' })
      Text('按时间回顾笔记、灵感、阅读与每日思考，看想法如何变化。')
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.of(this.darkModeOn).textSecondary)
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s3 })
        .width('100%')
      if (this.items.length === 0) {
        AppEmpty({
          title: '还没有可回顾的记录',
          description: '写下笔记、灵感或每日思考后，会按时间排列在这里。'
        })
          .layoutWeight(1)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (e: TimelineEvent) => {
              Row({ space: Theme.space.s3 }) {
                Column()
                  .width(8)
                  .height(8)
                  .borderRadius(4)
                  .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
                  .margin({ top: 6 })
                Column({ space: 4 }) {
                  Text(`${e.kind} · ${ResearchStore.timeLabel(e.at)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                    .width('100%')
                  Text(e.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  if (e.summary.length > 0) {
                    Text(e.summary)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.of(this.darkModeOn).textSecondary)
                      .maxLines(3)
                      .width('100%')
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
              .borderRadius(Theme.radius.md)
              .onClick((): void => { this.openEvent(e) })
            }, (e: TimelineEvent) => `${e.kind}_${e.id}_${e.at}`)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.of(this.darkModeOn).surfacePage)
  }
}
