import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { AlbumPhotoGrid, AlbumPhotoTile, PresetPhotoPicker } from '../journal/AlbumPhotoGrid'
import { JournalItem, UpdateAlbumRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog, JournalImageOption } from '../../services/JournalImageCatalog'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'
import { PhotoPickService } from '../../services/PhotoPickService'
import { common } from '@kit.AbilityKit'

@Component
export struct AlbumDetailPane {
  @Prop @Watch('onItemIdChanged') itemId: string = ''
  onRequireAuth: () => void = () => {}
  onCreateAlbum: () => void = () => {}
  onDataChanged: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State displayKeys: string[] = []
  @State heroCoverKey: string = ''
  @State photoCount: number = 0
  @State activePhotoKey: string = ''
  @State previewKey: string = ''
  @State showManage: boolean = false
  @State managePickKeys: string[] = []
  @State saving: boolean = false
  @State toastText: string = ''
  @State uiRevision: number = 0
  @State editingDesc: boolean = false
  @State descDraft: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''
  private presetOptions: JournalImageOption[] = JournalImageCatalog.albumPresetOptions()

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChanged(): void {
    void this.loadItem(true)
  }

  private syncFromItem(source: JournalItem): void {
    this.item = source
    this.heroCoverKey = source.coverKey
    if (source.imageKeys.length > 0) {
      this.displayKeys = [...source.imageKeys]
    } else if (JournalItem.isShowcase(source)) {
      this.displayKeys = [...JournalMedia.showcasePhotos(source.coverKey)]
    } else {
      this.displayKeys = [...JournalItem.displayPhotoKeys(source)]
    }
    this.photoCount = this.displayKeys.length > 0 ? this.displayKeys.length : source.photoCount
    if (this.activePhotoKey.length === 0 && this.displayKeys.length > 0) {
      this.activePhotoKey = this.displayKeys[0]
    } else if (this.activePhotoKey.length > 0) {
      let stillExists = false
      for (const k of this.displayKeys) {
        if (k === this.activePhotoKey) {
          stillExists = true
          break
        }
      }
      if (!stillExists && this.displayKeys.length > 0) {
        this.activePhotoKey = this.displayKeys[0]
      }
    }
    this.uiRevision += 1
  }

  private async loadItem(showBlockingLoader: boolean = true): Promise<void> {
    if (showBlockingLoader) {
      this.loading = true
    }
    const loaded = await JournalBizService.findAlbum(this.itemId)
    if (showBlockingLoader) {
      this.loading = false
    }
    if (loaded !== undefined) {
      this.syncFromItem(loaded)
    } else if (showBlockingLoader) {
      this.item = undefined
      this.displayKeys = []
      this.photoCount = 0
    }
  }

  private applyRequestLocally(req: UpdateAlbumRequest): void {
    if (this.item === undefined) {
      return
    }
    const next = new JournalItem()
    next.id = this.item.id
    next.title = this.item.title
    next.subtitle = this.item.subtitle
    next.summary = this.item.summary
    next.body = this.item.body
    next.description = req.description.length > 0 ? req.description : this.item.description
    next.tags = this.item.tags
    next.recordDate = this.item.recordDate
    next.kind = this.item.kind
    next.content = this.item.content
    next.userId = this.item.userId
    next.category = this.item.category
    next.color = this.item.color
    next.createdAt = this.item.createdAt
    let keys: string[] = []
    if (req.imageKeys.length > 0) {
      keys = [...req.imageKeys]
    } else {
      keys = [...this.displayKeys]
      if (req.appendImageKeys.length > 0) {
        for (const k of req.appendImageKeys) {
          let exists = false
          for (const existing of keys) {
            if (existing === k) {
              exists = true
              break
            }
          }
          if (!exists) {
            keys.push(k)
          }
        }
      }
    }
    next.imageKeys = keys
    next.coverKey = req.coverKey.length > 0 ? req.coverKey : this.heroCoverKey
    if (next.coverKey.length === 0 && keys.length > 0) {
      next.coverKey = keys[0]
    }
    next.photoCount = keys.length
    this.syncFromItem(next)
  }

  private isShowcase(): boolean {
    if (this.item === undefined) {
      return false
    }
    return JournalItem.isShowcase(this.item)
  }

  private isOwner(): boolean {
    if (this.item === undefined || this.isShowcase()) {
      return false
    }
    return this.item.userId.length > 0 && this.item.userId === this.currentUsername
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async pickFromGallery(maxCount: number): Promise<void> {
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const picked = await PhotoPickService.pickImages(ctx, maxCount)
    if (picked.length === 0) {
      if (PhotoPickService.lastError.length > 0) {
        this.showToast(PhotoPickService.lastError)
      }
      return
    }
    const merged = this.mergePhotoKeys(this.displayKeys, picked)
    const req = new UpdateAlbumRequest()
    req.imageKeys = merged
    if (this.heroCoverKey.length === 0 && picked.length > 0) {
      req.coverKey = picked[0]
    }
    await this.persistAlbum(req, `已从相册添加 ${picked.length} 张照片`)
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

  private toggleManagePick(key: string): void {
    const next: string[] = []
    let found = false
    for (const k of this.managePickKeys) {
      if (k === key) {
        found = true
      } else {
        next.push(k)
      }
    }
    if (!found) {
      next.push(key)
    }
    this.managePickKeys = next
  }


  private mergePhotoKeys(base: string[], extra: string[]): string[] {
    const merged: string[] = []
    for (const k of base) {
      merged.push(k)
    }
    for (const k of extra) {
      let exists = false
      for (const m of merged) {
        if (m === k) {
          exists = true
          break
        }
      }
      if (!exists) {
        merged.push(k)
      }
    }
    return merged
  }

  /** 避免向服务端发送 imageKeys:[] 导致覆盖旧照片 */
  private prepareAlbumRequest(req: UpdateAlbumRequest): void {
    if (req.appendImageKeys.length > 0) {
      const base = req.imageKeys.length > 0 ? req.imageKeys : this.displayKeys
      req.imageKeys = this.mergePhotoKeys(base, req.appendImageKeys)
      req.appendImageKeys = []
    }
    if (req.imageKeys.length === 0 && this.displayKeys.length > 0) {
      req.imageKeys = [...this.displayKeys]
    }
  }

  private async persistAlbum(req: UpdateAlbumRequest, okMsg: string): Promise<boolean> {
    if (this.item === undefined) {
      return false
    }
    this.prepareAlbumRequest(req)
    this.applyRequestLocally(req)
    this.saving = true
    req.userId = this.currentUsername
    const updated = await JournalBizService.updateAlbum(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.syncFromItem(updated)
      this.onDataChanged()
      this.showToast(okMsg)
      return true
    }
    void this.loadItem(false)
    this.showToast('保存失败，请稍后重试')
    return false
  }

  private async appendPhotos(): Promise<void> {
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    if (this.managePickKeys.length === 0) {
      this.showToast('请先选择要添加的照片')
      return
    }
    const picked = [...this.managePickKeys]
    const merged = this.mergePhotoKeys(this.displayKeys, picked)
    const req = new UpdateAlbumRequest()
    req.imageKeys = merged
    this.managePickKeys = []
    this.showManage = false
    await this.persistAlbum(req, `已添加 ${picked.length} 张照片`)
  }

  private async handleSetCoverFromPreview(): Promise<void> {
    const key = this.previewKey
    if (key.length === 0) {
      this.showToast('请先选择一张照片')
      return
    }
    const ok = await this.setCover(key)
    if (ok) {
      this.previewKey = ''
    }
  }

  private async setCover(key: string): Promise<boolean> {
    if (key.length === 0) {
      this.showToast('请先点选一张照片')
      return false
    }
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return false
    }
    this.activePhotoKey = key
    const req = new UpdateAlbumRequest()
    req.coverKey = key
    return await this.persistAlbum(req, '封面已更新')
  }

  private async removePhoto(key: string): Promise<void> {
    if (key.length === 0) {
      this.showToast('请先点选一张照片')
      return
    }
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    const next: string[] = []
    for (const k of this.displayKeys) {
      if (k !== key) {
        next.push(k)
      }
    }
    if (next.length === 0) {
      this.showToast('相册至少保留一张照片')
      return
    }
    const req = new UpdateAlbumRequest()
    req.imageKeys = next
    if (this.heroCoverKey === key) {
      req.coverKey = next[0]
    }
    await this.persistAlbum(req, '照片已移除')
    if (this.activePhotoKey === key) {
      this.activePhotoKey = next[0]
    }
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    JournalDetailNav.close()
    this.onCreateAlbum()
  }

  private selectPhoto(key: string): void {
    this.activePhotoKey = key
  }

  private openPreview(): void {
    if (this.activePhotoKey.length > 0) {
      this.previewKey = this.activePhotoKey
    } else {
      this.showToast('请先点选一张照片')
    }
  }

  private startEditDesc(): void {
    if (this.item === undefined) {
      return
    }
    this.descDraft = this.item.description.length > 0 ? this.item.description : this.item.summary
    this.editingDesc = true
  }

  private async saveDesc(): Promise<void> {
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    const req = new UpdateAlbumRequest()
    req.description = this.descDraft.trim()
    await this.persistAlbum(req, '简介已保存')
    this.editingDesc = false
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载相册…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '相册不存在', description: '可能已被删除或网络异常' })
      } else {
        this.DetailContent()
      }

      if (this.previewKey.length > 0) {
        Column() {
          Row() {
            Column() {
              AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textOnInverse })
            }
            .width(44)
            .height(44)
            .justifyContent(FlexAlign.Center)
            .onClick((): void => { this.previewKey = '' })
            Blank()
            if (this.isOwner()) {
              Row() {
                Text('设为封面')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().brandPrimary)
                  .textAlign(TextAlign.Center)
              }
              .width(120)
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(Theme.colors().brandPrimaryContainer)
              .borderRadius(Theme.radius.lg)
              .onClick((): void => { void this.handleSetCoverFromPreview() })
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
          Image(JournalMedia.resolveImage(this.previewKey))
            .width('92%')
            .layoutWeight(1)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: Theme.space.s6 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.92)')
        .zIndex(40)
      }

      if (this.showManage) {
        this.ManageOverlay()
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
        .zIndex(50)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ManageOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => {
          this.showManage = false
          this.managePickKeys = []
        })
        Text('添加照片')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Row() {
            AppButton({
              label: '从手机相册选择',
              onTap: (): void => { void this.pickFromGallery(9) }
            })
          }
          .width('100%')
          .onClick((): void => { void this.pickFromGallery(9) })

          Text('或从旅行图库素材中选择（可多选）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          PresetPhotoPicker({
            options: this.presetKeys(),
            optionLabels: this.presetLabels(),
            selectedKeys: this.managePickKeys,
            onToggle: (key: string): void => { this.toggleManagePick(key) }
          })

          Row() {
            AppButton({
              label: this.saving ? '保存中…' : '确认添加',
              disabled: this.saving,
              onTap: (): void => { void this.appendPhotos() }
            })
          }
          .width('100%')
          .onClick((): void => {
            if (!this.saving) {
              void this.appendPhotos()
            }
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
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(35)
  }

  @Builder
  DetailContent() {
    if (this.item === undefined) {
      Column()
    } else {
      DetailShell({
        title: this.isShowcase() ? '示例相册' : '相册详情',
        onClose: () => JournalDetailNav.close(),
        body: () => { this.DetailBody() }
      })
    }
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        if (this.isShowcase()) {
          Text('平台示例内容 · 非您的个人相册')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JournalMedia.resolveImage(this.heroCoverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
            .key(`album_hero_${this.uiRevision}_${this.heroCoverKey}`)
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(92,107,115,0)', 0], ['rgba(92,107,115,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(`${this.photoCount} 张`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
              .key(`album_count_${this.uiRevision}_${this.photoCount}`)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.heroCoverKey === this.activePhotoKey && this.isOwner()) {
              Text('当前封面')
                .fontSize(Theme.type.overline)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          AppCard({ title: '相册简介', variant: 'plain' }) {
            if (this.isOwner() && this.editingDesc) {
              Column({ space: Theme.space.s3 }) {
                TextArea({ text: this.descDraft, placeholder: '写一段相册说明…' })
                  .width('100%')
                  .height(100)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.sm)
                  .onChange((v: string) => { this.descDraft = v })
                Row({ space: Theme.space.s2 }) {
                  AppButton({
                    label: '取消',
                    variant: 'ghost',
                    onTap: (): void => { this.editingDesc = false }
                  })
                    .layoutWeight(1)
                  AppButton({
                    label: this.saving ? '保存中…' : '保存',
                    disabled: this.saving,
                    onTap: (): void => { void this.saveDesc() }
                  })
                    .layoutWeight(1)
                }
                .width('100%')
              }
              .width('100%')
            } else {
              Column({ space: Theme.space.s2 }) {
                Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                  .lineHeight(24)
                if (this.isOwner()) {
                  AppButton({
                    label: '编辑简介',
                    variant: 'ghost',
                    onTap: (): void => { this.startEditDesc() }
                  })
                }
              }
              .width('100%')
            }
          }

          AppCard({ title: '相册图片', variant: 'plain' }) {
            if (this.displayKeys.length === 0) {
              Text('暂无配图，可从手机相册或旅行图库添加。')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            } else {
              Column({ space: Theme.space.s3 }) {
                AlbumPhotoGrid({
                  photoKeys: this.displayKeys,
                  columns: 3,
                  activeKey: this.activePhotoKey,
                  gridRevision: this.uiRevision,
                  onPhotoTap: (key: string): void => { this.selectPhoto(key) }
                })
                if (this.isOwner()) {
                  Text('点选照片后可设为封面、查看大图或移除；支持本机相册与旅行素材')
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().textTertiary)
                    .width('100%')
                }
              }
              .width('100%')
            }
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.isOwner()) {
          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: '从手机相册添加',
              onTap: (): void => { void this.pickFromGallery(9) }
            })
            Row() {
              AppButton({
                label: '旅行图库素材',
                variant: 'secondary',
                onTap: (): void => { this.showManage = true }
              })
            }
            .width('100%')
            .onClick((): void => { this.showManage = true })
            Row({ space: Theme.space.s2 }) {
              Row() {
                AppButton({
                  label: '查看大图',
                  variant: 'secondary',
                  onTap: (): void => { this.openPreview() }
                })
              }
              .layoutWeight(1)
              .onClick((): void => { this.openPreview() })
              Row() {
                AppButton({
                  label: '设为封面',
                  variant: 'secondary',
                  disabled: this.activePhotoKey.length === 0 || this.saving,
                  onTap: (): void => { void this.setCover(this.activePhotoKey) }
                })
              }
              .layoutWeight(1)
              .onClick((): void => {
                if (this.activePhotoKey.length > 0 && !this.saving) {
                  void this.setCover(this.activePhotoKey)
                }
              })
            }
            .width('100%')
            if (this.displayKeys.length > 1) {
              AppButton({
                label: '移除选中照片',
                variant: 'ghost',
                onTap: (): void => { void this.removePhoto(this.activePhotoKey) }
              })
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        if (this.isShowcase()) {
          Column() {
            AppButton({
              label: '创建我的相册',
              variant: 'secondary',
              onTap: (): void => { this.handleCreateMine() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
      }
    }
  }
}
