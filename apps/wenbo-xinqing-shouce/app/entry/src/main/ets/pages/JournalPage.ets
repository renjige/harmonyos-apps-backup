import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { JournalListCard } from '../components/journal/JournalListCard'
import { JournalCoverImage } from '../components/journal/JournalCoverImage'
import { CreateDiaryRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { JournalImageCatalog, JournalImageOption } from '../services/JournalImageCatalog'
import { PhotoPickService } from '../services/PhotoPickService'
import { MoodCatalog, MoodOption } from '../services/MoodCatalog'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onDiaryCreated: () => void = () => {}
  @State diaries: JournalItem[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formMoodId: string = 'calm'
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State pickingPhoto: boolean = false
  @State pickHint: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private presetImages: JournalImageOption[] = JournalImageCatalog.presetOptions()

  aboutToAppear(): void {
    this.formDate = JournalPage.todayIso()
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async removeDiary(id: string): Promise<void> {
    const ok = await JournalBizService.deleteDiary(id)
    if (ok) {
      await this.reload()
      this.showToast('已删除这条心情记录')
    } else {
      this.showToast('删除失败，请稍后重试')
    }
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.diaries = await JournalBizService.loadDiaries(this.currentUsername)
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
    this.formBody = ''
    this.formTags = ''
    this.formDate = JournalPage.todayIso()
    this.formMoodId = 'calm'
    this.formCoverKey = ''
    this.formError = ''
    this.pickHint = ''
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

  private async pickFromGallery(): Promise<void> {
    if (this.pickingPhoto) {
      return
    }
    this.pickingPhoto = true
    this.pickHint = ''
    const ctx = getContext(this) as common.UIAbilityContext
    const key = await PhotoPickService.pickMoodPhoto(ctx)
    this.pickingPhoto = false
    if (key.length > 0) {
      this.formCoverKey = key
      this.pickHint = '已选择相册图片'
    } else {
      this.pickHint = '未选择图片'
    }
  }

  private async submitDiary(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写一句话标题'
      return
    }
    if (this.formMoodId.length === 0) {
      this.formError = '请选择今日心情'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateDiaryRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 0 ? req.body : req.title
    req.tags = this.parseTags(this.formTags)
    req.recordDate = this.formDate.length > 0 ? this.formDate : JournalPage.todayIso()
    req.userId = this.currentUsername
    req.kind = this.formMoodId
    req.coverKey = this.formCoverKey
    if (this.formCoverKey.length > 0) {
      req.imageKeys = [this.formCoverKey]
    }
    const created = await JournalBizService.createDiary(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onDiaryCreated()
    } else {
      this.formError = JournalBizService.lastError.length > 0
        ? JournalBizService.lastError
        : '保存失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '心情记录', subtitle: '选择状态 · 写下文字 · 添加标签与图片' })
        if (this.loading) {
          AppLoading({ label: '加载记录…' }).layoutWeight(1)
        } else if (this.diaries.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有心情记录',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，写下第一条心情'
                : '登录后可创建并同步你的心情记录',
              actionLabel: '写记录',
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
                  showDelete: true,
                  onTap: (): void => { JournalDetailNav.openDiary(item.id) },
                  onDelete: (): void => { void this.removeDiary(item.id) }
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
        .shadow({ radius: 12, color: 'rgba(107,95,120,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.DiaryFormOverlay()
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  MoodPicker() {
    Column({ space: Theme.space.s2 }) {
      Text('今日心情')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(MoodCatalog.all(), (m: MoodOption) => {
          Text(m.label)
            .fontSize(Theme.type.caption)
            .fontColor(this.formMoodId === m.id ?
              MoodCatalog.chipTextColor(m.id) : Theme.colors().textSecondary)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .backgroundColor(this.formMoodId === m.id ? m.color : Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.pill)
            .margin({ right: 8, bottom: 8 })
            .onClick((): void => { this.formMoodId = m.id })
        }, (m: MoodOption) => m.id)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  CoverPicker() {
    Column({ space: Theme.space.s3 }) {
      Text('添加图片（可选）')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')

      Row({ space: Theme.space.s2 }) {
        Column({ space: 4 }) {
          Column() {
            AppIcon({
              name: 'add',
              iconSize: Theme.icon.md,
              color: Theme.colors().brandPrimary
            })
          }
          .width(72)
          .height(72)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.md)
          .border({
            width: JournalImageCatalog.isLocalKey(this.formCoverKey) ? 2 : 1,
            color: Theme.colors().brandPrimary
          })
          Text(this.pickingPhoto ? '打开中…' : '从相册选')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .onClick((): void => { void this.pickFromGallery() })

        if (this.formCoverKey.length > 0) {
          Column({ space: 4 }) {
            JournalCoverImage({
              coverKey: this.formCoverKey,
              imageSize: 72,
              cornerRadius: Theme.radius.md
            })
            Text(JournalImageCatalog.isLocalKey(this.formCoverKey) ? '相册' : '已选')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          }
          .onClick((): void => { this.formCoverKey = '' })
        }
      }
      .width('100%')

      if (this.pickHint.length > 0) {
        Text(this.pickHint)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }

      Text('精选配图')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')

      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.presetImages, (opt: JournalImageOption) => {
            Column({ space: 4 }) {
              Image(JournalMedia.coverMedia(opt.key))
                .width(72)
                .height(72)
                .borderRadius(Theme.radius.md)
                .objectFit(ImageFit.Cover)
                .border({
                  width: this.formCoverKey === opt.key ? 2 : 0,
                  color: Theme.colors().brandPrimary
                })
                .onClick((): void => {
                  this.formCoverKey = this.formCoverKey === opt.key ? '' : opt.key
                  this.pickHint = ''
                })
              Text(opt.label)
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width(72)
                .textAlign(TextAlign.Center)
            }
          }, (opt: JournalImageOption) => opt.key)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
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
        Text('写心情')
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
          this.MoodPicker()

          Column({ space: 6 }) {
            Text('一句话标题')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '用一句话概括此刻…' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          AppDatePickerField({
            label: '记录日期',
            value: this.formDate,
            minDaysFromToday: -3650,
            maxDaysFromToday: 0,
            onChange: (v: string) => { this.formDate = v }
          })

          Column({ space: 6 }) {
            Text('详细文字')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下今天的故事与感受…' })
              .width('100%')
              .height(140)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          this.CoverPicker()

          Column({ space: 6 }) {
            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '日常, 治愈, 成长' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '保存中…' : '保存心情',
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
