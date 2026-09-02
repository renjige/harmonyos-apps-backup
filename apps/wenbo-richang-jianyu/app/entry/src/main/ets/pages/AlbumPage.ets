import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { AlbumCoverImage, AlbumPhotoTile } from '../components/journal/AlbumPhotoGrid'
import { CreateAlbumRequest, JournalItem } from '../models/JournalModels'
import { JournalBizService } from '../services/JournalBizService'
import { JournalDetailNav } from '../services/JournalDetailNav'
import { JournalImageCatalog, JournalImageOption } from '../services/JournalImageCatalog'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { LifeHubNav } from '../services/LifeHubNav'
import { common } from '@kit.AbilityKit'

@Component
export struct AlbumPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop asOverlay: boolean = false
  onRequireAuth: () => void = () => {}
  onAlbumCreated: () => void = () => {}
  onClose: () => void = () => {}
  @State showcaseAlbums: JournalItem[] = []
  @State myAlbums: JournalItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formSelectedKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @State formPicking: boolean = false
  @State formPickHint: string = ''
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
    this.showcaseAlbums = await JournalBizService.loadAlbumShowcase()
    if (AuthService.isLoggedIn()) {
      this.myAlbums = await JournalBizService.loadMyAlbums(this.currentUsername)
    } else {
      this.myAlbums = []
    }
    this.loading = false
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
    this.formPickHint = ''
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
    return this.formSelectedKeys.indexOf(key) >= 0
  }

  private async pickFromGallery(): Promise<void> {
    if (this.formPicking) {
      return
    }
    this.formPicking = true
    this.formPickHint = ''
    const ctx = getContext(this) as common.UIAbilityContext
    const remain = 12 - this.formSelectedKeys.length
    const keys = await PhotoPickService.pickAlbumPhotos(ctx, remain > 0 ? remain : 1)
    this.formPicking = false
    if (keys.length === 0) {
      this.formPickHint = '未选择图片'
      return
    }
    const next: string[] = []
    for (const k of this.formSelectedKeys) {
      next.push(k)
    }
    for (const k of keys) {
      if (next.indexOf(k) < 0) {
        next.push(k)
      }
    }
    this.formSelectedKeys = next
    this.formPickHint = `已从相册添加 ${keys.length} 张`
  }

  private removeSelectedKey(key: string): void {
    const next: string[] = []
    for (const k of this.formSelectedKeys) {
      if (k !== key) {
        next.push(k)
      }
    }
    this.formSelectedKeys = next
  }

  private localLabel(key: string): string {
    if (JournalImageCatalog.isLocalKey(key)) {
      return '我的照片'
    }
    for (const opt of this.presetOptions) {
      if (opt.key === key) {
        return opt.label
      }
    }
    return '配图'
  }

  private photoCountLabel(item: JournalItem): string {
    const n = JournalItem.displayPhotoKeys(item).length
    if (n > 0) {
      return `${n} 张`
    }
    return `${item.photoCount} 张`
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
    let cover = 'hero_morning_coffee'
    for (const k of this.formSelectedKeys) {
      cover = k
      break
    }
    req.coverKey = cover
    req.userId = this.currentUsername
    try {
      const created = await JournalBizService.createAlbum(req)
      if (created !== undefined) {
        this.closeForm()
        await this.reload()
        this.onAlbumCreated()
        JournalDetailNav.openAlbum(created.id)
      } else {
        this.formError = JournalBizService.lastError.length > 0
          ? JournalBizService.lastError
          : '创建失败，请稍后重试'
      }
    } catch {
      this.formError = '创建失败，请稍后重试'
    }
    this.submitting = false
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
              Column({ space: Theme.space.s2 }) {
                AlbumCoverImage({
                  photoKey: item.coverKey,
                  fallbackKey: 'album_default'
                })
                Text(item.title)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                Text(this.photoCountLabel(item))
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
                  .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .onClick((): void => { JournalDetailNav.openAlbum(item.id) })
            }
          }, (item: JournalItem) => item.id)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(Theme.space.s3)
        .rowsGap(Theme.space.s4)
        .width('100%')
        .padding({ top: Theme.space.s1 })
      }
    }
    .width('100%')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        if (this.asOverlay) {
          Row({ space: Theme.space.s2 }) {
            Column() {
              AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .rotate({ angle: 180 })
            .onClick((): void => { this.onClose() })
            Text('返回')
              .fontSize(Theme.type.subhead)
              .fontColor(Theme.colors().textPrimary)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })
        }
        AppHeader({ title: '美好相册', subtitle: '选图建册 · 收藏生活里的光影' })
        if (this.loading) {
          AppLoading({ label: '加载相册…' }).layoutWeight(1)
        } else if (this.showcaseAlbums.length === 0 && this.myAlbums.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无相册',
              description: '浏览精选相册，或登录后选择配图创建自己的相册',
              actionLabel: AuthService.isLoggedIn() ? '创建相册' : '',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: Theme.space.s6 }) {
              AppButton({
                label: '打开照片时光册',
                variant: 'secondary',
                onTap: (): void => { LifeHubNav.open('photos', false) }
              })
              if (AuthService.isLoggedIn()) {
                this.AlbumGridSection('我的相册', '选择配图后即可创建，首张作为封面', this.myAlbums)
              }
              this.AlbumGridSection('精选相册', '机构示例，游客可浏览', this.showcaseAlbums)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10 + 72
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
        .shadow({ radius: 12, color: 'rgba(92,107,115,0.24)', offsetY: 4 })
        .margin({ right: Theme.space.pageX, bottom: Theme.space.s8 })
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
            Row({ space: Theme.space.s2 }) {
              Text('选择配图（可多选，首张为封面）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .layoutWeight(1)
              AppButton({
                label: this.formPicking ? '选择中…' : '从相册选择',
                variant: 'secondary',
                disabled: this.formPicking,
                onTap: (): void => { void this.pickFromGallery() }
              })
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            if (this.formPickHint.length > 0) {
              Text(this.formPickHint)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.presetOptions, (opt: JournalImageOption) => {
                  Column({ space: 4 }) {
                    Column() {
                      AlbumPhotoTile({
                        photoKey: opt.key,
                        tileSize: 72
                      })
                    }
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
              Scroll() {
                Row({ space: Theme.space.s2 }) {
                  ForEach(this.formSelectedKeys, (key: string) => {
                    Column({ space: 4 }) {
                      Stack({ alignContent: Alignment.TopEnd }) {
                        AlbumPhotoTile({ photoKey: key, tileSize: 72 })
                        Column() {
                          AppIcon({ name: 'close', iconSize: 12, color: Theme.colors().brandOnPrimary })
                        }
                        .width(22)
                        .height(22)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor('rgba(61,58,54,0.72)')
                        .borderRadius(Theme.radius.pill)
                        .onClick((): void => { this.removeSelectedKey(key) })
                      }
                      Text(this.localLabel(key))
                        .fontSize(Theme.type.overline)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                        .maxLines(1)
                        .width(72)
                        .textAlign(TextAlign.Center)
                    }
                  }, (key: string) => key)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
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
