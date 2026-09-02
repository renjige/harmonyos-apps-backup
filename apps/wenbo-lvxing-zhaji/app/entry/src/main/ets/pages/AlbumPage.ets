import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { PresetPhotoPicker } from '../components/journal/AlbumPhotoGrid'
import { CreateAlbumRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalMedia } from '../services/JournalMedia'
import { JournalImageCatalog, JournalImageOption } from '../services/JournalImageCatalog'
import { AuthService } from '../services/AuthService'
import { PhotoPickService } from '../services/PhotoPickService'
import { common } from '@kit.AbilityKit'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onAlbumCreated: () => void = () => {}
  @State showcaseAlbums: JournalItem[] = []
  @State myAlbums: JournalItem[] = []
  @State loading: boolean = true
  @State showShowcaseExamples: boolean = false
  @State showcaseLoading: boolean = false
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formSelectedKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''
  private presetOptions: JournalImageOption[] = JournalImageCatalog.albumPresetOptions()

  aboutToAppear(): void {
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

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.myAlbums = await JournalBizService.loadMyAlbums(this.currentUsername)
    } else {
      this.myAlbums = []
    }
    this.loading = false
  }

  private async loadShowcaseExamples(): Promise<void> {
    this.showcaseLoading = true
    this.showcaseAlbums = await JournalBizService.loadAlbumShowcase()
    this.showShowcaseExamples = true
    this.showcaseLoading = false
  }

  private photoCountOf(item: JournalItem): number {
    const keys = JournalItem.displayPhotoKeys(item)
    if (keys.length > 0) {
      return keys.length
    }
    return item.photoCount
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formDescription = ''
    this.formSelectedKeys = []
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private togglePreset(key: string): void {
    const next: string[] = []
    let found = false
    for (const k of this.formSelectedKeys) {
      if (k === key) {
        found = true
      } else {
        next.push(k)
      }
    }
    if (!found) {
      next.push(key)
    }
    this.formSelectedKeys = next
  }

  private isPresetSelected(key: string): boolean {
    for (const k of this.formSelectedKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  private firstSelectedKey(): string {
    for (const key of this.formSelectedKeys) {
      return key
    }
    return 'hero_travel_home'
  }

  private presetKeys(): string[] {
    const keys: string[] = []
    for (const opt of this.presetOptions) {
      keys.push(opt.key)
    }
    return keys
  }

  private presetLabels(): string[] {
    const labels: string[] = []
    for (const opt of this.presetOptions) {
      labels.push(opt.label)
    }
    return labels
  }

  private async pickLocalPhotos(): Promise<void> {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const picked = await PhotoPickService.pickImages(ctx, 12)
    if (picked.length === 0) {
      if (PhotoPickService.lastError.length > 0) {
        this.formError = PhotoPickService.lastError
      }
      return
    }
    this.formError = ''
    const merged: string[] = [...this.formSelectedKeys]
    for (const path of picked) {
      let exists = false
      for (const k of merged) {
        if (k === path) {
          exists = true
          break
        }
      }
      if (!exists) {
        merged.push(path)
      }
    }
    this.formSelectedKeys = merged
  }

  private async submitAlbum(): Promise<void> {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写相册名称'
      return
    }
    if (this.formSelectedKeys.length === 0) {
      this.formError = '请至少选择一张配图'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateAlbumRequest()
    req.title = this.formTitle.trim()
    req.description = this.formDescription.trim()
    req.imageKeys = this.formSelectedKeys
    req.coverKey = this.firstSelectedKey()
    req.userId = this.currentUsername
    const created = await JournalBizService.createAlbum(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onAlbumCreated()
      JournalDetailNav.openAlbum(created.id)
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  @Builder
  AlbumGridSection(title: string, subtitle: string, items: JournalItem[]) {
    Column({ space: Theme.space.s3 }) {
      Column({ space: 4 }) {
        Text(title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text(subtitle)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      }
      .width('100%')

      if (items.length === 0) {
        Text('暂无内容，点右下角创建相册并添加照片')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else {
        Grid() {
          ForEach(items, (item: JournalItem) => {
            GridItem() {
              Column({ space: 8 }) {
                Image(JournalMedia.resolveImage(item.coverKey))
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(Theme.radius.lg)
                  .objectFit(ImageFit.Cover)
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${this.photoCountOf(item)} 张`)
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .width('100%')
              .onClick((): void => { JournalDetailNav.openAlbum(item.id) })
            }
          }, (item: JournalItem) => item.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(Theme.space.s3)
        .rowsGap(Theme.space.s4)
        .width('100%')
      }
    }
    .width('100%')
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '旅行相册', subtitle: '选择配图 · 创建相册 · 浏览精选' })
        if (this.loading) {
          Column() {
            AppLoading({ label: '加载相册…' })
          }
          .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s6 }) {
              if (AuthService.isLoggedIn()) {
                this.AlbumGridSection('我的相册', '支持手机相册与旅行图库素材，创建后可随时追加', this.myAlbums)
              } else {
                Text('登录后可创建相册，并从手机相册或旅行图库添加照片')
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }

              Column({ space: Theme.space.s3 }) {
                Text('示例相册')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                if (!this.showShowcaseExamples) {
                  Column({ space: Theme.space.s3 }) {
                    Text('首次使用暂无个人相册。如需参考排版，可浏览平台示例相册（非您的数据）。')
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    AppButton({
                      label: this.showcaseLoading ? '加载中…' : '浏览示例相册（平台示例）',
                      variant: 'secondary',
                      disabled: this.showcaseLoading,
                      onTap: (): void => { void this.loadShowcaseExamples() }
                    })
                  }
                  .width('100%')
                } else {
                  this.AlbumGridSection('平台示例', '仅供浏览参考，创建后可继续添加照片', this.showcaseAlbums)
                }
              }
              .width('100%')
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

      if (!this.showForm && AuthService.isLoggedIn()) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.AlbumFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AlbumFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建相册')
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
            Text('相册名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '例如：川西自驾精选' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('简介')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formDescription, placeholder: '这段旅途想记住什么…' })
              .width('100%')
              .height(88)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formDescription = v })
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('添加照片（可多选，第一张为封面）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row() {
              AppButton({
                label: '从手机相册选择',
                onTap: (): void => { void this.pickLocalPhotos() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.pickLocalPhotos() })

            Text('或选择旅行图库素材')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            PresetPhotoPicker({
              options: this.presetKeys(),
              optionLabels: this.presetLabels(),
              selectedKeys: this.formSelectedKeys,
              onToggle: (key: string): void => { this.togglePreset(key) }
            })

            if (this.formSelectedKeys.length > 0) {
              Text(`已选 ${this.formSelectedKeys.length} 张 · 再次点按素材可取消`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '创建中…' : '创建相册',
            disabled: this.submitting,
            onTap: (): void => { void this.submitAlbum() }
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
