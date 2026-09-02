import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { ThemeTopic } from '../models/LifeGrowthModels'
import { JournalItem } from '../models/JournalModels'
import { LifeDates, LifeTag } from '../models/LifeHubModels'
import { LifeGrowthStore } from '../services/LifeGrowthStore'
import { LifeHubStore } from '../services/LifeHubStore'
import { LifeHubNav } from '../services/LifeHubNav'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct TopicPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  onRequireAuth: () => void = () => {}
  @State topics: ThemeTopic[] = []
  @State tags: LifeTag[] = []
  @State diaries: JournalItem[] = []
  @State formTitle: string = ''
  @State formTag: string = ''
  @State formNote: string = ''
  @State openId: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2000)
  }

  private async reload(): Promise<void> {
    this.topics = await LifeGrowthStore.loadTopics()
    this.tags = await LifeHubStore.loadTags()
    if (AuthService.isLoggedIn()) {
      this.diaries = await JournalBizService.loadDiaries(this.currentUsername)
    }
    if (this.formTag.length === 0 && this.tags.length > 0) {
      this.formTag = this.tags[0].name
    }
  }

  private openTitle(): string {
    const t = this.openTopic()
    return t !== undefined ? t.title : ''
  }

  private openNote(): string {
    const t = this.openTopic()
    return t !== undefined ? t.note : ''
  }

  private openTopic(): ThemeTopic | undefined {
    for (const t of this.topics) {
      if (t.id === this.openId) {
        return t
      }
    }
    return undefined
  }

  private topicDiaries(): JournalItem[] {
    const topic = this.openTopic()
    const out: JournalItem[] = []
    if (topic === undefined) {
      return out
    }
    for (const d of this.diaries) {
      for (const tag of d.tags) {
        if (tag === topic.tagName) {
          out.push(d)
          break
        }
      }
    }
    return out
  }

  private async addTopic(): Promise<void> {
    if (!AuthService.requireAuth('life_write')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0 || this.formTag.trim().length === 0) {
      this.showToast('请填写专题名称并选择标签')
      return
    }
    const row = new ThemeTopic()
    row.id = LifeHubStore.newId('topic')
    row.title = this.formTitle.trim()
    row.tagName = this.formTag.trim()
    row.note = this.formNote.trim()
    row.createdAt = LifeDates.todayIso()
    await LifeGrowthStore.upsertTopic(row)
    this.formTitle = ''
    this.formNote = ''
    this.showToast('专题已建立，带该标签的笺语会汇进来')
    await this.reload()
  }

  private async confirmDelete(): Promise<void> {
    await LifeGrowthStore.removeTopic(this.confirmId)
    this.confirmId = ''
    this.openId = ''
    await this.reload()
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => {
            if (this.openId.length > 0) {
              this.openId = ''
              return
            }
            LifeHubNav.backOrClose()
          })
          Column({ space: 2 }) {
            Text(this.openId.length > 0 ? '专题详情' : '生活专题')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('按标签把笺语收成自己的主题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.openId.length === 0) {
              this.ListBody()
            } else {
              this.DetailBody()
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.confirmId.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('删除这个专题？笺语本身不会被删。')
            .fontSize(Theme.type.subhead)
            .fontColor(Theme.colors().textPrimary)
          AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.confirmDelete() } })
          AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.confirmId = '' } })
        }
        .width('80%')
        .padding(Theme.space.s5)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  ListBody() {
    Column({ space: Theme.space.s3 }) {
      TextInput({ text: this.formTitle, placeholder: '专题名称，如「厨房里的周末」' })
        .width('100%')
        .height(44)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.formTitle = v })
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tags, (t: LifeTag) => {
          Text(t.name)
            .fontSize(Theme.type.caption)
            .fontColor(this.formTag === t.name ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.formTag === t.name ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.formTag = t.name })
        }, (t: LifeTag) => t.id)
      }
      .width('100%')
      TextInput({ text: this.formNote, placeholder: '一句话说明这个专题（可选）' })
        .width('100%')
        .height(44)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onChange((v: string) => { this.formNote = v })
      AppButton({ label: '建立专题', onTap: (): void => { void this.addTopic() } })

      if (this.topics.length === 0) {
        AppEmpty({
          title: '还没有专题',
          description: '用标签把旅行、家庭或美食的笺语收成一本小册子。',
          actionLabel: '',
          onAction: (): void => {}
        })
      }
      ForEach(this.topics, (t: ThemeTopic) => {
        Column({ space: 4 }) {
          Text(t.title)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')
          Text(`标签 · ${t.tagName}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)
        .onClick((): void => { this.openId = t.id })
      }, (t: ThemeTopic) => t.id)
    }
    .width('100%')
  }

  @Builder
  DetailBody() {
    Column({ space: Theme.space.s3 }) {
      Text(this.openTitle())
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(Theme.colors().textPrimary)
        .width('100%')
      Text(this.openNote())
        .fontSize(Theme.type.footnote)
        .fontColor(Theme.colors().textSecondary)
        .width('100%')
      if (this.topicDiaries().length === 0) {
        AppEmpty({
          title: '这个专题还是空的',
          description: '写一页时打上对应标签，就会出现在这里。',
          actionLabel: '',
          onAction: (): void => {}
        })
      }
      ForEach(this.topicDiaries(), (item: JournalItem) => {
        JournalListCard({
          item: item,
          compact: true,
          onTap: (): void => { JournalDetailNav.openDiary(item.id) }
        })
      }, (item: JournalItem) => item.id)
      AppButton({
        label: '删除专题',
        variant: 'danger',
        onTap: (): void => { this.confirmId = this.openId }
      })
    }
    .width('100%')
  }
}
