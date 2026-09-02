import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchNote, ResearchTag } from '../../models/ResearchModels'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct SearchPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @State query: string = ''
  @State tagKey: string = ''
  @State tags: ResearchTag[] = []
  @State items: ResearchNote[] = []
  @State searched: boolean = false

  aboutToAppear(): void {
    void this.boot()
  }

  private async boot(): Promise<void> {
    this.tags = await ResearchStore.allTags()
    this.items = await ResearchStore.searchNotes('', '')
  }

  private async run(): Promise<void> {
    this.searched = true
    this.items = await ResearchStore.searchNotes(this.query, this.tagKey)
  }

  build() {
    Column() {
      ResearchBar({ title: '内容搜索' })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          TextInput({ text: this.query, placeholder: '关键词：标题、正文或观点' })
            .onChange((v: string) => { this.query = v })
          Flex({ wrap: FlexWrap.Wrap }) {
            Text('全部分类')
              .fontSize(Theme.type.caption)
              .fontColor(this.tagKey.length === 0 ?
                Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .margin({ right: 8, bottom: 8 })
              .backgroundColor(this.tagKey.length === 0 ?
                Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
              .borderRadius(Theme.radius.pill)
              .onClick((): void => {
                this.tagKey = ''
                void this.run()
              })
            ForEach(this.tags, (t: ResearchTag) => {
              Text(t.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.tagKey === t.key ?
                  Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .margin({ right: 8, bottom: 8 })
                .backgroundColor(this.tagKey === t.key ?
                  Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => {
                  this.tagKey = t.key
                  void this.run()
                })
            }, (t: ResearchTag) => t.key)
          }
          .width('100%')
          AppButton({ label: '搜索笔记', onTap: (): void => { void this.run() } })
          if (this.items.length === 0) {
            AppEmpty({
              title: this.searched ? '没有匹配内容' : '输入关键词或点标签',
              description: '可按待学习、已整理、重点关注等标签缩小范围。'
            })
          } else {
            ForEach(this.items, (n: ResearchNote) => {
              Column({ space: 4 }) {
                Text(n.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .width('100%')
                Text(n.viewpoint.length > 0 ? n.viewpoint : n.body)
                  .fontSize(Theme.type.footnote)
                  .fontColor(Theme.of(this.darkModeOn).textSecondary)
                  .maxLines(2)
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
  }
}
