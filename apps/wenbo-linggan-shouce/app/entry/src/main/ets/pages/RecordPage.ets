import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppDatePickerField } from '../components/design-system/AppDatePickerField'
import { AppIcon } from '../components/design-system/AppIcon'
import { InspirationListCard } from '../components/inspiration/InspirationListCard'
import { CoverPhotoPicker } from '../components/inspiration/CoverPhotoPicker'
import { CreateInspirationRequest, InspirationItem, TagPresetItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct RecordPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onInspirationCreated: () => void = () => {}
  @State inspirations: InspirationItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formTags: string = ''
  @State formDate: string = ''
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State tagPresets: TagPresetItem[] = []
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    this.formDate = RecordPage.todayIso()
    void this.reload()
    void this.loadTagPresets()
  }

  private async loadTagPresets(): Promise<void> {
    this.tagPresets = await InspirationBizService.loadTagPresets()
  }

  private togglePresetTag(title: string): void {
    const tags = this.parseTags(this.formTags)
    let found = false
    const next: string[] = []
    for (const t of tags) {
      if (t === title) {
        found = true
      } else {
        next.push(t)
      }
    }
    if (!found) {
      next.push(title)
    }
    this.formTags = next.join(', ')
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private static todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.inspirations = await InspirationBizService.loadInspirations(this.currentUsername)
    } else {
      this.inspirations = []
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formBody = ''
    this.formTags = ''
    this.formCoverKey = 'hero_latest_inspiration'
    this.formDate = RecordPage.todayIso()
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

  private toggleCover(key: string): void {
    if (this.formCoverKey === key) {
      this.formCoverKey = ''
    } else {
      this.formCoverKey = key
    }
  }

  private async pickCoverFromGallery(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const key = await PhotoPickService.pickOne(ctx)
    if (key.length > 0) {
      this.formCoverKey = key
    }
  }

  private applyQuickTemplate(kind: string): void {
    if (kind === 'visual') {
      this.formTitle = '视觉观察笔记'
      this.formBody = '今天注意到：\n· 色彩/构图：\n· 材质与光影：\n· 可借鉴到项目：'
      this.formTags = '视觉, 观察'
      this.formCoverKey = 'hero_latest_inspiration'
    } else if (kind === 'copy') {
      this.formTitle = '文案灵感草稿'
      this.formBody = '核心一句话：\n受众场景：\n语气关键词：\n可延展标题：'
      this.formTags = '文案, 品牌'
      this.formCoverKey = 'banner_creative_flow'
    } else {
      this.formTitle = '产品创意点子'
      this.formBody = '用户痛点：\n解决思路：\n最小可行版本：\n下一步验证：'
      this.formTags = '产品, 创意'
      this.formCoverKey = 'case_brand_refresh'
    }
  }

  private async submitInspiration(): Promise<void> {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写标题'
      return
    }
    this.submitting = true
    this.formError = ''
    try {
      const req = new CreateInspirationRequest()
      req.title = this.formTitle.trim()
      req.body = this.formBody.trim()
      req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
      req.tags = this.parseTags(this.formTags)
      req.recordDate = this.formDate.length > 0 ? this.formDate : RecordPage.todayIso()
      req.coverKey = this.formCoverKey.length > 0 ? this.formCoverKey : 'hero_latest_inspiration'
      req.userId = this.currentUsername
      const created = await InspirationBizService.createInspiration(req)
      if (created !== undefined) {
        this.closeForm()
        await this.reload()
        this.onInspirationCreated()
      } else {
        this.formError = '保存失败，请稍后重试'
      }
    } catch {
      this.formError = '保存失败，请稍后重试'
    }
    this.submitting = false
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '记录', subtitle: '捕捉创意碎片与灵感瞬间' })
        if (this.loading) {
          AppLoading({ label: '加载灵感…' }).layoutWeight(1)
        } else if (this.inspirations.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有灵感',
              description: AuthService.isLoggedIn()
                ? '点击右下角按钮，开始记录第一条灵感'
                : '登录后可创建并同步你的灵感',
              actionLabel: '记录灵感',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.inspirations, (item: InspirationItem) => {
                InspirationListCard({
                  item: item,
                  onTap: (): void => { InspirationDetailNav.openInspiration(item.id) }
                })
              }, (item: InspirationItem) => item.id)
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
        .shadow({ radius: 12, color: 'rgba(27,42,65,0.2)', offsetY: 4 })
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.InspirationFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  InspirationFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('记录灵感')
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
          Column({ space: Theme.space.s2 }) {
            Text('灵感模板（一键填充，可再修改）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row({ space: Theme.space.s2 }) {
              Text('视觉观察')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.applyQuickTemplate('visual') })
              Text('文案草稿')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.applyQuickTemplate('copy') })
              Text('产品创意')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .onClick((): void => { this.applyQuickTemplate('product') })
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标题')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '给灵感起个名字…' })
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
            TextArea({ text: this.formBody, placeholder: '写下创意想法、观察与灵感…' })
              .width('100%')
              .height(160)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('标签')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            if (this.tagPresets.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.tagPresets, (tag: TagPresetItem) => {
                  Text(tag.title)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.formTags.indexOf(tag.title) >= 0 ?
                      Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(this.formTags.indexOf(tag.title) >= 0 ?
                      Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                    .onClick((): void => { this.togglePresetTag(tag.title) })
                }, (tag: TagPresetItem) => tag.id)
              }
              .width('100%')
            }
            TextInput({ text: this.formTags, placeholder: '或手动输入，逗号分隔' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTags = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('封面图片')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            CoverPhotoPicker({
              selectedKeys: this.formCoverKey.length > 0 ? [this.formCoverKey] : [],
              maxCount: 1,
              showBuiltin: true,
              galleryLabel: '从相册选封面',
              onToggle: (key: string): void => { this.toggleCover(key) },
              onPickGallery: (): void => { void this.pickCoverFromGallery() }
            })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '保存中…' : '保存灵感',
            disabled: this.submitting,
            onTap: (): void => { void this.submitInspiration() }
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
