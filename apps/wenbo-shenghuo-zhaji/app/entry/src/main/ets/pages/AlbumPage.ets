import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AlbumPhotoTile } from '../components/journal/AlbumPhotoGrid'
import { CreateAlbumRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalImageCatalog, JournalImageOption } from '../services/JournalImageCatalog'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onAlbumCreated: () => void = () => {}
  @State showcaseAlbums: JournalItem[] = []
  @State myAlbums: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formSelectedKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @State pickingPhotos: boolean = false
  @State showShowcase: boolean = false
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

  private async reload(): Promise<void> {
    this.loading = true
    if (this.showShowcase) {
      this.showcaseAlbums = await JournalBizService.loadAlbumShowcase()
    } else {
      this.showcaseAlbums = []
    }
    if (AuthService.isLoggedIn()) {
      this.myAlbums = await JournalBizService.loadMyAlbums(this.currentUsername)
    } else {
      this.myAlbums = []
    }
    this.loading = false
  }

  private async pickFromGallery(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    if (ctx === undefined || ctx === null) {
      this.formError = '无法打开相册，请稍后重试'
      return
    }
    this.pickingPhotos = true
    const remain = 12 - this.formSelectedKeys.length
    const uris = await PhotoPickService.pickImages(ctx, remain > 0 ? remain : 1)
    if (uris.length > 0) {
      const merged: string[] = []
      for (let i = 0; i < this.formSelectedKeys.length; i++) {
        merged.push(this.formSelectedKeys[i])
      }
      const newKeys = JournalImageCatalog.keysFromUris(uris)
      for (let j = 0; j < newKeys.length; j++) {
        merged.push(newKeys[j])
      }
      this.formSelectedKeys = merged
      this.formError = ''
    } else if (PhotoPickService.lastError.length > 0) {
      this.formError = PhotoPickService.lastError
    }
    this.pickingPhotos = false
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
    const idx = this.formSelectedKeys.indexOf(key)
    if (idx >= 0) {
      const next: string[] = []
      for (let i = 0; i < this.formSelectedKeys.length; i++) {
        if (i !== idx) {
          next.push(this.formSelectedKeys[i])
        }
      }
      this.formSelectedKeys = next
    } else {
      const merged: string[] = []
      for (let i = 0; i < this.formSelectedKeys.length; i++) {
        merged.push(this.formSelectedKeys[i])
      }
      merged.push(key)
      this.formSelectedKeys = merged
    }
  }

  private isPresetSelected(key: string): boolean {
    return this.formSelectedKeys.indexOf(key) >= 0
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
      this.formError = '请从相册选择照片，或搭配精选配图'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateAlbumRequest()
    req.title = this.formTitle.trim()
    req.description = this.formDescription.trim()
    req.imageKeys = this.formSelectedKeys
    req.coverKey = this.formSelectedKeys[0]
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
        Text('暂无内容')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .padding({ top: Theme.space.s2, bottom: Theme.space.s2 })
      } else {
        Grid() {
          ForEach(items, (item: JournalItem) => {
            GridItem() {
              Column({ space: 8 }) {
                AlbumPhotoTile({ photoKey: item.coverKey, tileSize: 140 })
                  .width('100%')
                  .aspectRatio(1)
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(`${JournalItem.displayPhotoKeys(item).length > 0 ?
                  JournalItem.displayPhotoKeys(item).length : item.photoCount} 张`)
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
        AppHeader({ title: '相册', subtitle: '从相册选图 · 记录生活瞬间' })
        if (this.loading) {
          AppLoading({ label: '加载相册…' }).layoutWeight(1)
        } else if (!AuthService.isLoggedIn()) {
          Column() {
            AppEmpty({
              title: '登录后创建相册',
              description: '从系统相册选择您的照片，按主题整理生活瞬间',
              actionLabel: '',
              onAction: (): void => {}
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.myAlbums.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有相册',
              description: '点击右下角按钮，从相册选择照片创建第一本相册',
              actionLabel: '创建相册',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s6 }) {
              this.AlbumGridSection('我的相册', '个人照片与主题整理', this.myAlbums)
              if (this.showShowcase) {
                this.AlbumGridSection('示例相册', '官方创作示例，非个人数据', this.showcaseAlbums)
              } else {
                AppButton({
                  label: '浏览示例相册（官方示例）',
                  variant: 'secondary',
                  onTap: (): void => {
                    this.showShowcase = true
                    void this.reload()
                  }
                })
              }
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
            TextInput({ text: this.formTitle, placeholder: '例如：四季餐桌' })
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
            TextArea({ text: this.formDescription, placeholder: '描述这个相册…' })
              .width('100%')
              .height(100)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formDescription = v })
          }
          .width('100%')

          Column({ space: Theme.space.s3 }) {
            Text('添加照片')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            AppButton({
              label: this.pickingPhotos ? '打开相册…' : '从相册选择照片',
              disabled: this.pickingPhotos,
              onTap: (): void => { void this.pickFromGallery() }
            })
            if (this.formSelectedKeys.length > 0) {
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.formSelectedKeys, (key: string) => {
                    AlbumPhotoTile({ photoKey: key, tileSize: 72 })
                  }, (key: string) => key)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
            Text('或选用精选配图（可选）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.presetOptions, (opt: JournalImageOption) => {
                  Column({ space: 4 }) {
                    AlbumPhotoTile({
                      photoKey: opt.key,
                      tileSize: 72
                    })
                    .opacity(this.isPresetSelected(opt.key) ? 1 : 0.55)
                    .border({
                      width: this.isPresetSelected(opt.key) ? 2 : 0,
                      color: Theme.colors().brandPrimary
                    })
                    .borderRadius(Theme.radius.md)
                    Text(opt.label)
                      .fontSize(Theme.type.overline)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .maxLines(1)
                      .width(72)
                      .textAlign(TextAlign.Center)
                  }
                  .onClick((): void => { this.togglePreset(opt.key) })
                }, (opt: JournalImageOption) => opt.key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            if (this.formSelectedKeys.length > 0) {
              Text(`已选 ${this.formSelectedKeys.length} 张`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
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
