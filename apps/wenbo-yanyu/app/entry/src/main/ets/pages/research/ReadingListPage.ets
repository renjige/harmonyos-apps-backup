import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ReadingRecord } from '../../models/ResearchModels'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct ReadingListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: ReadingRecord[] = []
  @State title: string = ''
  @State progress: string = ''
  @State thought: string = ''
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
    this.items = await ResearchStore.listReadings()
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写在读内容')
      return
    }
    const r = ReadingRecord.create()
    r.title = this.title.trim()
    r.progress = this.progress.trim()
    r.thought = this.thought.trim()
    await ResearchStore.saveReading(r)
    this.title = ''
    this.progress = ''
    this.thought = ''
    this.showToast('阅读记录已保存')
    await this.reload()
  }

  private async remove(id: string): Promise<void> {
    if (this.pendingId !== id) {
      this.pendingId = id
      this.showToast('再点一次确认删除')
      return
    }
    await ResearchStore.deleteReading(id)
    this.pendingId = ''
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '阅读记录' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextInput({ text: this.title, placeholder: '书名 / 论文 / 文章标题' })
              .onChange((v: string) => { this.title = v })
            TextInput({ text: this.progress, placeholder: '进度，如：第 3 章 / 62 页 / 已读完' })
              .onChange((v: string) => { this.progress = v })
            TextArea({ text: this.thought, placeholder: '读后感想、想继续追问的问题' })
              .height(80)
              .onChange((v: string) => { this.thought = v })
            AppButton({ label: '保存阅读记录', onTap: (): void => { void this.save() } })
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有阅读记录',
                description: '记下正在读的内容、进度和感想，方便回头接着读。'
              })
            } else {
              ForEach(this.items, (r: ReadingRecord) => {
                Column({ space: 6 }) {
                  Text(r.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(r.progress.length > 0 ? `进度：${r.progress}` : '未填写进度')
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                    .width('100%')
                  Text(r.thought)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                  Text(this.pendingId === r.id ? '再点确认删除' : '删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).danger)
                    .onClick((): void => { void this.remove(r.id) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
              }, (r: ReadingRecord) => r.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
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
