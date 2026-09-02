import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { TopicItem } from '../models/GrowthModels'
import { GrowthStore } from '../services/GrowthStore'
import { GrowthService } from '../services/GrowthService'
import { AuthService } from '../services/AuthService'

@Component
export struct TopicListPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('growthEpoch') @Watch('onGrowthChange') growthEpoch: number = 0
  @Prop @Watch('onListRefresh') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onOpenTopic: (id: string) => void = (_id: string) => {}
  @State topics: TopicItem[] = []
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formSummary: string = ''
  @State formError: string = ''
  @State saving: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onGrowthChange(): void {
    void this.reload()
  }

  onListRefresh(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.topics = []
      return
    }
    const data = await GrowthStore.load(this.currentUsername)
    this.topics = data.topics
  }

  private openForm(): void {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formSummary = ''
    this.formError = ''
    this.showForm = true
  }

  private async submit(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写专题名称'
      return
    }
    this.saving = true
    const data = await GrowthStore.load(this.currentUsername)
    const created = GrowthService.addTopic(data, this.formTitle.trim(), this.formSummary.trim())
    GrowthService.pushActivity(data, 'topic', created.title, 'topic', created.id)
    await GrowthService.persist(this.currentUsername, data)
    this.saving = false
    this.showForm = false
    await this.reload()
    this.onOpenTopic(created.id)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('灵感专题')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (!AuthService.isLoggedIn()) {
          AppEmpty({
            title: '登录后建立专题',
            description: '把多条灵感收成「配色研究」「包装节奏」这样的主题夹',
            actionLabel: '去登录',
            onAction: (): void => { this.onRequireAuth() }
          })
        } else if (this.topics.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有专题',
              description: '专题用来收纳一组相关灵感，不是又一个空白笔记列表',
              actionLabel: '新建专题',
              onAction: (): void => { this.openForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              Text('把散落的备忘收成可回看的主题。点进去可加入或移出灵感。')
                .fontSize(Theme.type.footnote)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              ForEach(this.topics, (t: TopicItem) => {
                Column({ space: 6 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(t.summary.length > 0 ? t.summary : '暂无说明')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                    .maxLines(2)
                  Text(`含 ${t.inspirationIds.length} 条灵感`)
                    .fontSize(Theme.type.footnote)
                    .fontColor(Theme.colors().brandPrimary)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .alignItems(HorizontalAlign.Start)
                .onClick((): void => { this.onOpenTopic(t.id) })
              }, (t: TopicItem) => `${t.id}_${t.inspirationIds.length}`)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')

      if (AuthService.isLoggedIn() && !this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openForm() })
      }

      if (this.showForm) {
        Column() {
          Row() {
            Text('新建专题')
              .fontSize(Theme.type.title3)
              .fontWeight(FontWeight.Medium)
              .layoutWeight(1)
            Text('取消')
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .onClick((): void => { this.showForm = false })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          if (this.formError.length > 0) {
            Text(this.formError)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .padding({ left: Theme.space.pageX })
          }
          TextInput({ text: this.formTitle, placeholder: '例如：配色研究' })
            .width('100%')
            .height(44)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .onChange((v: string) => { this.formTitle = v })
          TextArea({ text: this.formSummary, placeholder: '这个专题想解决什么画面或文案问题' })
            .width('100%')
            .height(100)
            .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .onChange((v: string) => { this.formSummary = v })
          Column() {
            AppButton({
              label: this.saving ? '创建中…' : '创建并打开',
              disabled: this.saving,
              onTap: (): void => { void this.submit() }
            })
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .onClick((): void => { void this.submit() })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
