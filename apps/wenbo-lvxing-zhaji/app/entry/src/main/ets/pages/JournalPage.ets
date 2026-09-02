import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { CoverPhotoField } from '../components/journal/CoverPhotoField'
import { JournalListCard } from '../components/journal/JournalListCard'
import { CreateDiaryRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onDiaryCreated: () => void = () => {}
  @State diaries: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDestination: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false

  aboutToAppear(): void {
    this.formDate = JournalPage.todayIso()
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      const all = await JournalBizService.loadDiaries(this.currentUsername)
      this.diaries = JournalBizService.filterJourneys(all)
    } else {
      this.diaries = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formDestination = ''
    this.formBody = ''
    this.formTags = ''
    this.formDate = JournalPage.todayIso()
    this.formCoverKey = ''
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async submitDiary(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写旅程名称'
      return
    }
    if (this.formDestination.trim().length === 0) {
      this.formError = '请填写目的地'
      return
    }
    if (this.formCoverKey.length === 0) {
      this.formError = '请选择封面图（推荐从手机相册导入）'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateDiaryRequest()
    req.title = this.formTitle.trim()
    req.subtitle = this.formDestination.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate.length > 0 ? this.formDate : JournalPage.todayIso()
    req.userId = this.currentUsername
    req.kind = 'journey'
    req.coverKey = this.formCoverKey
    req.imageKeys = [this.formCoverKey]
    const created = await JournalBizService.createDiary(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onDiaryCreated()
    } else {
      this.formError = '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '旅行日记', subtitle: '添加文字 · 图片 · 标签，记录旅途故事' })
        if (this.loading) {
          Column() {
            AppLoading({ label: '加载日记…' })
          }
          .layoutWeight(1)
        } else if (this.diaries.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有旅行日记',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，创建旅程并写下第一篇日记'
                : '登录后可创建并同步你的旅行日记',
              actionLabel: '创建旅程',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.diaries, (item: JournalItem) => {
                JournalListCard({
                  item: item,
                  onTap: (): void => { JournalDetailNav.openDiary(item.id) }
                })
              }, (item: JournalItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .shadow({ radius: 12, color: 'rgba(92,107,115,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.DiaryFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DiaryFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建旅程')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('旅程名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '例如：大理环海三日' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('目的地')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formDestination, placeholder: '例如：云南·大理' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formDestination = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '出发日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.formDate = v }
          })

          Column({ space: 6 }) {
            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下旅途见闻、心情与故事…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '自然, 海, 古城' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          CoverPhotoField({
            coverKey: this.formCoverKey,
            onCoverChange: (key: string): void => { this.formCoverKey = key },
            onPickError: (msg: string): void => { this.formError = msg }
          })

          AppButton({
            label: this.submitting ? '保存中…' : '保存旅程',
            disabled: this.submitting,
            onTap: (): void => { void this.submitDiary() }
          })
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
