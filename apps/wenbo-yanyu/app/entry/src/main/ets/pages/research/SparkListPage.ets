import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { SparkItem } from '../../models/ResearchModels'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct SparkListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: SparkItem[] = []
  @State text: string = ''
  @State remark: string = ''
  @State toastText: string = ''
  @State pendingId: string = ''

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
    this.items = await ResearchStore.listSparks()
  }

  private async save(): Promise<void> {
    if (this.text.trim().length === 0) {
      this.showToast('先写下灵感内容')
      return
    }
    const s = SparkItem.create()
    s.text = this.text.trim()
    s.remark = this.remark.trim()
    await ResearchStore.saveSpark(s)
    this.text = ''
    this.remark = ''
    this.showToast('已收入灵感库')
    await this.reload()
  }

  private async remove(id: string): Promise<void> {
    if (this.pendingId !== id) {
      this.pendingId = id
      this.showToast('再点删除确认')
      return
    }
    await ResearchStore.deleteSpark(id)
    this.pendingId = ''
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '灵感收集' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            TextArea({ text: this.text, placeholder: '突然想到的句子、线索、问题' })
              .height(80)
              .onChange((v: string) => { this.text = v })
            TextArea({ text: this.remark, placeholder: '备注（出处、后续想查什么）' })
              .height(56)
              .onChange((v: string) => { this.remark = v })
            AppButton({ label: '收入灵感库', onTap: (): void => { void this.save() } })
            if (this.items.length === 0) {
              AppEmpty({
                title: '灵感库是空的',
                description: '走路、阅读时想到的内容可以先扔进来，之后再整理成笔记。'
              })
            } else {
              ForEach(this.items, (s: SparkItem) => {
                Column({ space: 6 }) {
                  Text(s.text)
                    .fontSize(Theme.type.body)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  if (s.remark.length > 0) {
                    Text(s.remark)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.of(this.darkModeOn).textSecondary)
                      .width('100%')
                  }
                  Text(ResearchStore.timeLabel(s.createdAt))
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                  Text(this.pendingId === s.id ? '再点确认删除' : '删除')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).danger)
                    .onClick((): void => { void this.remove(s.id) })
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
              }, (s: SparkItem) => s.id)
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
