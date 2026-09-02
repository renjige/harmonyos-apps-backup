import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { AlbumPhotoTile } from '../components/journal/AlbumPhotoGrid'
import { JournalListCard } from '../components/journal/JournalListCard'
import { CreateDiaryRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { JournalImageCatalog, JournalImageOption } from '../services/JournalImageCatalog'
import { MoodCatalog, MoodOption } from '../services/MoodCatalog'
import { JournalTemplate, JournalTemplateCatalog } from '../services/JournalTemplateCatalog'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct JournalPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop templateKey: string = ''
  onRequireAuth: () => void = () => {}
  onDiaryCreated: () => void = () => {}
  @State diaries: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCity: string = ''
  @State formMood: string = ''
  @State formKind: string = ''
  @State formClass: string = ''
  @State formCoverKey: string = ''
  @State formPhotoKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @State pickingPhotos: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  private coverOptions: JournalImageOption[] = JournalImageCatalog.albumPresetOptions().slice(0, 6)
  private moodOptions: MoodOption[] = MoodCatalog.options()

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
    this.formCity = ''
    this.formMood = ''
    this.formKind = ''
    this.formClass = ''
    this.formCoverKey = ''
    this.formPhotoKeys = []
    this.formDate = JournalPage.todayIso()
    this.formError = ''
    this.applyTemplate(this.templateKey)
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private applyTemplate(key: string): void {
    const tpl = JournalTemplateCatalog.find(key)
    if (tpl === undefined) {
      return
    }
    this.formKind = tpl.key
    this.formClass = tpl.lifeClass
    this.formTags = tpl.tags.join(', ')
    if (this.formTitle.length === 0) {
      this.formTitle = tpl.titleHint
    }
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
    const ctx = getContext(this) as common.UIAbilityContext
    if (ctx === undefined || ctx === null) {
      this.formError = '无法打开相册，请稍后重试'
      return
    }
    this.pickingPhotos = true
    const remain = 9 - this.formPhotoKeys.length
    const uris = await PhotoPickService.pickImages(ctx, remain > 0 ? remain : 1)
    if (uris.length > 0) {
      const merged: string[] = []
      for (let i = 0; i < this.formPhotoKeys.length; i++) {
        merged.push(this.formPhotoKeys[i])
      }
      const newKeys = JournalImageCatalog.keysFromUris(uris)
      for (let j = 0; j < newKeys.length; j++) {
        merged.push(newKeys[j])
      }
      this.formPhotoKeys = merged
      this.formError = ''
    } else if (PhotoPickService.lastError.length > 0) {
      this.formError = PhotoPickService.lastError
    }
    this.pickingPhotos = false
  }

  private async submitDiary(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateDiaryRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.recordDate = this.formDate.length > 0 ? this.formDate : JournalPage.todayIso()
    req.userId = this.currentUsername
    req.subtitle = this.formCity.trim()
    req.category = this.formMood
    req.kind = this.formKind
    const tags = this.parseTags(this.formTags)
    if (this.formClass.length > 0) {
      let hasClass = false
      for (let t = 0; t < tags.length; t++) {
        if (tags[t] === this.formClass) {
          hasClass = true
        }
      }
      if (!hasClass) {
        tags.unshift(this.formClass)
      }
    }
    req.tags = tags
    const keys: string[] = []
    for (let i = 0; i < this.formPhotoKeys.length; i++) {
      keys.push(this.formPhotoKeys[i])
    }
    if (keys.length > 0) {
      req.coverKey = keys[0]
      if (this.formCoverKey.length > 0 && keys.indexOf(this.formCoverKey) < 0) {
        keys.push(this.formCoverKey)
      }
      req.imageKeys = keys
    } else if (this.formCoverKey.length > 0) {
      req.coverKey = this.formCoverKey
      req.imageKeys = [this.formCoverKey]
    }
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
        AppHeader({ title: '记录', subtitle: '写札记 · 从相册记录生活瞬间' })
        if (this.loading) {
          AppLoading({ label: '加载札记…' }).layoutWeight(1)
        } else if (this.diaries.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有札记',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，开始记录第一篇'
                : '登录后可创建并同步你的札记',
              actionLabel: '写札记',
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
        Text('写札记')
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
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '给今天起个名字…' })
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
            Text('正文')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formBody, placeholder: '写下此刻的心情与故事…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('生活主题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(JournalTemplateCatalog.all(), (tpl: JournalTemplate) => {
                Text(tpl.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formKind === tpl.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.formKind === tpl.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => { this.applyTemplate(tpl.key) })
              }, (tpl: JournalTemplate) => tpl.key)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('札记分类')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(JournalTemplateCatalog.lifeClasses(), (cls: string) => {
                Text(cls)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formClass === cls ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.formClass === cls ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.formClass = this.formClass === cls ? '' : cls
                  })
              }, (cls: string) => cls)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签（逗号分隔）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTags, placeholder: '日常, 治愈, 周末' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('所在城市（可选，用于生活足迹）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formCity, placeholder: '例如：杭州' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formCity = v })
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('今日心情')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.moodOptions, (m: MoodOption) => {
                Text(m.label)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formMood === m.key ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.formMood === m.key ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .margin({ right: 8, bottom: 8 })
                  .onClick((): void => {
                    this.formMood = this.formMood === m.key ? '' : m.key
                  })
              }, (m: MoodOption) => m.key)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('生活瞬间配图')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppButton({
              label: this.pickingPhotos ? '打开相册…' : '从相册选择照片',
              disabled: this.pickingPhotos,
              onTap: (): void => { void this.pickFromGallery() }
            })
            if (this.formPhotoKeys.length > 0) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.formPhotoKeys, (key: string) => {
                    AlbumPhotoTile({ photoKey: key, tileSize: 64 })
                  }, (key: string) => key)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            Text('或选用精选封面（可选）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.coverOptions, (opt: JournalImageOption) => {
                  AlbumPhotoTile({
                    photoKey: opt.key,
                    tileSize: 64
                  })
                    .opacity(this.formCoverKey === opt.key ? 1 : 0.55)
                    .border({
                      width: this.formCoverKey === opt.key ? 2 : 0,
                      color: Theme.colors().brandPrimary
                    })
                    .borderRadius(Theme.radius.md)
                    .onClick((): void => {
                      this.formCoverKey = this.formCoverKey === opt.key ? '' : opt.key
                    })
                }, (opt: JournalImageOption) => opt.key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '保存中…' : '保存札记',
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
