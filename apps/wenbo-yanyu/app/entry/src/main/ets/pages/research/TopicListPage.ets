import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { AppEmpty } from '../../components/design-system/AppEmpty'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchNote, ResearchTopic } from '../../models/ResearchModels'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct TopicListPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchRefresh') @Watch('onRefresh') refreshToken: number = 0
  @State items: ResearchTopic[] = []
  @State title: string = ''
  @State summary: string = ''
  @State category: string = '读书笔记'
  @State cats: string[] = ResearchStore.topicCategories()
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
    this.items = await ResearchStore.listTopics()
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.showToast('请填写专题名称')
      return
    }
    const t = ResearchTopic.create()
    t.title = this.title.trim()
    t.summary = this.summary.trim()
    t.category = this.category
    if (this.category === '历史研究') {
      t.coverKey = 'cover_academic'
    } else if (this.category === '行业观察') {
      t.coverKey = 'cover_workplace'
    } else if (this.category === '兴趣收藏') {
      t.coverKey = 'cover_story'
    } else {
      t.coverKey = 'cover_essay'
    }
    await ResearchStore.saveTopic(t)
    this.title = ''
    this.summary = ''
    this.showToast('专题已创建')
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '专题资料库' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Text('新建个人专题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            TextInput({ text: this.title, placeholder: '专题名，如：晚清报刊阅读' })
              .onChange((v: string) => { this.title = v })
            TextArea({ text: this.summary, placeholder: '这个专题要集中管理哪些材料' })
              .height(64)
              .onChange((v: string) => { this.summary = v })
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.cats, (c: string) => {
                Text(c)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.category === c ?
                    Theme.of(this.darkModeOn).brandOnPrimary : Theme.of(this.darkModeOn).textPrimary)
                  .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(this.category === c ?
                    Theme.of(this.darkModeOn).brandPrimary : Theme.of(this.darkModeOn).surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.category = c })
              }, (c: string) => c)
            }
            .width('100%')
            AppButton({ label: '创建专题', onTap: (): void => { void this.save() } })

            Text('我的专题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.items.length === 0) {
              AppEmpty({
                title: '还没有专题',
                description: '用专题把历史研究、读书笔记、行业观察或兴趣收藏集中起来。'
              })
            } else {
              ForEach(this.items, (t: ResearchTopic) => {
                Row({ space: Theme.space.s3 }) {
                  Image(LanguageCraftMedia.cover(t.coverKey))
                    .width(72)
                    .height(72)
                    .borderRadius(Theme.radius.sm)
                    .objectFit(ImageFit.Cover)
                  Column({ space: 4 }) {
                    Text(t.category)
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                      .width('100%')
                    Text(t.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.of(this.darkModeOn).textPrimary)
                      .width('100%')
                    Text(t.summary)
                      .fontSize(Theme.type.footnote)
                      .fontColor(Theme.of(this.darkModeOn).textSecondary)
                      .maxLines(2)
                      .width('100%')
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.of(this.darkModeOn).surfaceCard)
                .borderRadius(Theme.radius.md)
                .border({ width: 1, color: Theme.of(this.darkModeOn).strokeHairline })
                .onClick((): void => { ResearchNav.openTopicDetail(t.id) })
              }, (t: ResearchTopic) => t.id)
            }
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
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

@Component
export struct TopicDetailPage {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchItemId') @Watch('onItem') itemId: string = ''
  @State topic: ResearchTopic = new ResearchTopic()
  @State notes: ResearchNote[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  onItem(): void {
    void this.load()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async load(): Promise<void> {
    this.confirmDelete = false
    const found = await ResearchStore.findTopic(this.itemId)
    if (found !== undefined) {
      this.topic = found
    }
    this.notes = await ResearchStore.notesInTopic(this.itemId)
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除该专题（笔记仍保留）')
      return
    }
    await ResearchStore.deleteTopic(this.itemId)
    ResearchNav.open('topics')
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '专题详情' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Image(LanguageCraftMedia.cover(this.topic.coverKey.length > 0 ? this.topic.coverKey : 'cover_academic'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Text(this.topic.category)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).brandPrimary)
              .width('100%')
            Text(this.topic.title)
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
            Text(this.topic.summary)
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')
            AppButton({
              label: '在此专题下写笔记',
              onTap: (): void => { ResearchNav.openNoteEditor('', this.topic.id) }
            })
            Text(`收录笔记 ${this.notes.length} 条`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')
            if (this.notes.length === 0) {
              AppEmpty({
                title: '专题还是空的',
                description: '写笔记时选择本专题，材料会集中到这里。'
              })
            } else {
              ForEach(this.notes, (n: ResearchNote) => {
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
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除专题' : '删除专题',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
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
