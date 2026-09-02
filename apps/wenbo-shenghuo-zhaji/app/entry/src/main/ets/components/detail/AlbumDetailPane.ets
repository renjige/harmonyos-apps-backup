import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { AlbumPhotoGrid, AlbumPhotoTile } from '../journal/AlbumPhotoGrid'
import { JournalItem, UpdateAlbumRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { JournalImageCatalog, JournalImageOption } from '../../services/JournalImageCatalog'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AuthService } from '../../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct AlbumDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onCreateAlbum: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State showAddPresets: boolean = false
  @State addingPresets: boolean = false
  @State pickingPhotos: boolean = false
  @State toastText: string = ''
  @State selectedPresetKeys: string[] = []
  @StorageLink('currentUsername') currentUsername: string = ''
  private presetOptions: JournalImageOption[] = JournalImageCatalog.albumPresetOptions()

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await JournalBizService.findAlbum(this.itemId)
    this.loading = false
  }

  private photoKeys(): string[] {
    if (this.item === undefined) {
      return []
    }
    return JournalItem.displayPhotoKeys(this.item)
  }

  private isOwnAlbum(): boolean {
    if (this.item === undefined || !AuthService.isLoggedIn()) {
      return false
    }
    return this.item.userId.length > 0 &&
      this.item.userId === this.currentUsername &&
      !JournalItem.isShowcase(this.item)
  }

  private isShowcase(): boolean {
    if (this.item === undefined) {
      return false
    }
    return JournalItem.isShowcase(this.item)
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => { this.toastText = '' }, 2600)
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    JournalDetailNav.close()
    this.onCreateAlbum()
  }

  private togglePreset(key: string): void {
    const idx = this.selectedPresetKeys.indexOf(key)
    if (idx >= 0) {
      const next: string[] = []
      for (let i = 0; i < this.selectedPresetKeys.length; i++) {
        if (i !== idx) {
          next.push(this.selectedPresetKeys[i])
        }
      }
      this.selectedPresetKeys = next
    } else {
      const merged: string[] = []
      for (let i = 0; i < this.selectedPresetKeys.length; i++) {
        merged.push(this.selectedPresetKeys[i])
      }
      merged.push(key)
      this.selectedPresetKeys = merged
    }
  }

  private async handlePickGallery(): Promise<void> {
    if (!this.isOwnAlbum() || this.item === undefined) {
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    if (ctx === undefined || ctx === null) {
      this.showToast('无法打开相册，请稍后重试')
      return
    }
    this.pickingPhotos = true
    const uris = await PhotoPickService.pickImages(ctx, 9)
    if (uris.length === 0) {
      this.pickingPhotos = false
      if (PhotoPickService.lastError.length > 0) {
        this.showToast(PhotoPickService.lastError)
      }
      return
    }
    const req = new UpdateAlbumRequest()
    req.userId = this.currentUsername
    req.appendImageKeys = JournalImageCatalog.keysFromUris(uris)
    const updated = await JournalBizService.updateAlbum(this.item.id, req)
    this.pickingPhotos = false
    if (updated !== undefined) {
      this.item = updated
      this.showToast(`已添加 ${req.appendImageKeys.length} 张照片`)
    } else {
      this.showToast('添加失败，请稍后重试')
    }
  }

  private async handleAppendPresets(): Promise<void> {
    if (!this.isOwnAlbum() || this.item === undefined || this.selectedPresetKeys.length === 0) {
      return
    }
    this.addingPresets = true
    const req = new UpdateAlbumRequest()
    req.userId = this.currentUsername
    req.appendImageKeys = this.selectedPresetKeys
    const updated = await JournalBizService.updateAlbum(this.item.id, req)
    this.addingPresets = false
    if (updated !== undefined) {
      this.item = updated
      this.selectedPresetKeys = []
      this.showAddPresets = false
      this.showToast(`已添加 ${req.appendImageKeys.length} 张配图`)
    } else {
      this.showToast('添加失败，请稍后重试')
    }
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载相册…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '相册不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '相册详情',
          onClose: () => JournalDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({
            left: Theme.space.s4,
            right: Theme.space.s4,
            top: Theme.space.s2,
            bottom: Theme.space.s2
          })
          .backgroundColor('rgba(92,107,115,0.92)')
          .borderRadius(Theme.radius.pill)
          .position({ x: '10%', y: '6%' })
          .zIndex(30)
      }

      if (this.showAddPresets) {
        this.PresetPickerOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  PresetPickerOverlay() {
    Column() {
      Text('添加精选配图')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, top: Theme.space.s4 })
      Scroll() {
        Row({ space: Theme.space.s2 }) {
          ForEach(this.presetOptions, (opt: JournalImageOption) => {
            Column({ space: 4 }) {
              AlbumPhotoTile({ photoKey: opt.key, tileSize: 72 })
                .opacity(this.selectedPresetKeys.indexOf(opt.key) >= 0 ? 1 : 0.55)
                .border({
                  width: this.selectedPresetKeys.indexOf(opt.key) >= 0 ? 2 : 0,
                  color: Theme.colors().brandPrimary
                })
                .borderRadius(Theme.radius.md)
              Text(opt.label)
                .fontSize(Theme.type.overline)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width(72)
                .textAlign(TextAlign.Center)
            }
            .onClick((): void => { this.togglePreset(opt.key) })
          }, (opt: JournalImageOption) => opt.key)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .scrollable(ScrollDirection.Horizontal)
      .layoutWeight(1)
      Row({ space: Theme.space.s3 }) {
        AppButton({
          label: '取消',
          variant: 'secondary',
          onTap: (): void => { this.showAddPresets = false }
        }).layoutWeight(1)
        AppButton({
          label: this.addingPresets ? '添加中…' : '确认添加',
          disabled: this.addingPresets || this.selectedPresetKeys.length === 0,
          onTap: (): void => { void this.handleAppendPresets() }
        }).layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.pageX)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(28)
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(`${this.photoKeys().length > 0 ? this.photoKeys().length : this.item.photoCount} 张`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          AppCard({ title: '相册简介', variant: 'plain' }) {
            Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }

          AppCard({ title: '相册图片', variant: 'plain' }) {
            if (this.photoKeys().length === 0) {
              Text('暂无配图，创建相册时可从精选配图库中选择。')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              AlbumPhotoGrid({ photoKeys: this.photoKeys(), columns: 3 })
            }
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.isOwnAlbum()) {
          AppButton({
            label: this.pickingPhotos ? '添加中…' : '从相册添加照片',
            disabled: this.pickingPhotos,
            onTap: (): void => { void this.handlePickGallery() }
          })
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          AppButton({
            label: '添加精选配图',
            variant: 'secondary',
            onTap: (): void => {
              this.selectedPresetKeys = []
              this.showAddPresets = true
            }
          })
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        } else if (this.isShowcase()) {
          AppButton({
            label: '创建我的相册',
            variant: 'secondary',
            onTap: (): void => { this.handleCreateMine() }
          })
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
