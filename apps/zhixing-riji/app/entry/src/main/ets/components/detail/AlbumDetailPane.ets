import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { AppIcon } from '../design-system/AppIcon'
import { DetailShell } from './DetailShell'
import { AlbumPhotoGrid, AlbumPhotoTile } from '../journal/AlbumPhotoGrid'
import { JournalItem, UpdateAlbumRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalMedia } from '../../services/JournalMedia'
import { JournalImageCatalog, JournalImageOption } from '../../services/JournalImageCatalog'
import { JournalDetailNav } from '../../services/JournalDetailNav'
import { AuthService } from '../../services/AuthService'

@Component
export struct AlbumDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onCreateAlbum: () => void = () => {}
  @State item: JournalItem | undefined = undefined
  @State loading: boolean = true
  @State previewKey: string = ''
  @State showManage: boolean = false
  @State managePickKeys: string[] = []
  @State saving: boolean = false
  @State toastText: string = ''
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
    if (this.item.imageKeys.length > 0) {
      return this.item.imageKeys
    }
    if (JournalItem.isShowcase(this.item)) {
      return JournalMedia.showcasePhotos(this.item.coverKey)
    }
    return JournalItem.displayPhotoKeys(this.item)
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

  private isManagePick(key: string): boolean {
    for (const k of this.managePickKeys) {
      if (k === key) {
        return true
      }
    }
    return false
  }

  private async persistAlbum(req: UpdateAlbumRequest, okMsg: string): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.saving = true
    req.userId = this.currentUsername
    const updated = await JournalBizService.updateAlbum(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.item = updated
      this.showToast(okMsg)
    } else {
      this.showToast('保存失败，请稍后重试')
    }
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
    const req = new UpdateAlbumRequest()
    req.appendImageKeys = this.managePickKeys
    await this.persistAlbum(req, `已添加 ${this.managePickKeys.length} 张照片`)
    this.managePickKeys = []
    this.showManage = false
  }

  private async setCover(key: string): Promise<void> {
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    const req = new UpdateAlbumRequest()
    req.coverKey = key
    await this.persistAlbum(req, '封面已更新')
  }

  private async removePhoto(key: string): Promise<void> {
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    const keys = this.photoKeys()
    const next: string[] = []
    for (const k of keys) {
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
    if (this.item !== undefined && this.item.coverKey === key) {
      req.coverKey = next[0]
    }
    await this.persistAlbum(req, '照片已移除')
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    JournalDetailNav.close()
    this.onCreateAlbum()
  }

  build() {
    Stack() {
      if (this.loading) {
        AppLoading({ label: '加载相册…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '相册不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: this.isShowcase() ? '示例相册' : '相册详情',
          onClose: () => JournalDetailNav.close(),
          body: () => { this.DetailBody() }
        })
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
          }
          .width('100%')
          .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
          Image(JournalMedia.coverMedia(this.previewKey))
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
        Text('添加旅行照片')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('从旅行图库选择照片加入相册（可多选）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          Grid() {
            ForEach(this.presetOptions, (opt: JournalImageOption) => {
              GridItem() {
                AlbumPhotoTile({
                  photoKey: opt.key,
                  tileSize: 96,
                  selected: this.isManagePick(opt.key),
                  onTap: (): void => { this.toggleManagePick(opt.key) }
                })
              }
            }, (opt: JournalImageOption) => opt.key)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .columnsGap(Theme.space.s2)
          .rowsGap(Theme.space.s3)
          .width('100%')

          AppButton({
            label: this.saving ? '保存中…' : '确认添加',
            disabled: this.saving,
            onTap: (): void => { void this.appendPhotos() }
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
    .zIndex(35)
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
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

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
              Text('暂无配图，创建相册时可从图库中选择。')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              Column({ space: Theme.space.s3 }) {
                AlbumPhotoGrid({
                  photoKeys: this.photoKeys(),
                  columns: 3,
                  onPhotoTap: (key: string): void => { this.previewKey = key }
                })
                if (this.isOwner()) {
                  Text('点击照片可全屏查看；下方可管理相册')
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
              label: '添加照片',
              onTap: (): void => { this.showManage = true }
            })
            if (this.photoKeys().length > 1) {
              AppButton({
                label: '将当前预览图设为封面',
                variant: 'secondary',
                disabled: this.previewKey.length === 0,
                onTap: (): void => { void this.setCover(this.previewKey) }
              })
            }
            if (this.previewKey.length > 0 && this.photoKeys().length > 1) {
              AppButton({
                label: '移除当前预览图',
                variant: 'ghost',
                onTap: (): void => { void this.removePhoto(this.previewKey) }
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
