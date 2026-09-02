import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchNote, ResearchTag } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct TagManagePage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State tags: ResearchTag[] = []
  @State label: string = ''
  @State filterKey: string = ''
  @State notes: ResearchNote[] = []
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
    this.tags = await ResearchStore.allTags()
    this.notes = await ResearchStore.searchNotes('', this.filterKey)
  }

  private async addTag(): Promise<void> {
    if (this.label.trim().length === 0) {
      this.showToast('请输入标签名')
      return
    }
    await ResearchStore.addCustomTag(this.label)
    this.label = ''
    this.showToast('已加入知识标签')
    await this.reload()
  }

  private async pick(key: string): Promise<void> {
    this.filterKey = this.filterKey === key ? '' : key
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '知识标签' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('预设 + 自定义标签，点选可筛选笔记。')
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.tags, (t: ResearchTag) => {
                Text(t.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.filterKey === t.key ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.filterKey === t.key ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.pick(t.key) })
              }, (t: ResearchTag) => t.key)
            }
            .width('100%')
            TextInput({ text: this.label, placeholder: '自定义标签，如：论文摘录' })
              .onChange((v: string) => { this.label = v })
            AppButton({
              label: '添加标签',
              variant: 'secondary',
              onTap: (): void => { void this.addTag() }
            })
            Text(this.filterKey.length > 0 ? '该标签下的笔记' : '全部笔记（点标签筛选）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.notes.length === 0) {
              AppEmpty({
                title: '没有匹配笔记',
                description: '写笔记时点选标签，即可按待学习 / 已整理 / 重点关注 / 灵感记录归类。'
              })
            } else {
              ForEach(this.notes, (n: ResearchNote) => {
                Column({ space: 4 }) {
                  Text(n.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Theme.of(this.darkModeOn).textPrimary)
                    .width('100%')
                  Text(n.tagKeys)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.of(this.darkModeOn).textSecondary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { ResearchNav.openNoteDetail(n.id) })
              }, (n: ResearchNote) => n.id)
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
