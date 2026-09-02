import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { AlbumPhotoGrid } from '../journal/AlbumPhotoGrid'
import { JournalHeroImage } from '../journal/JournalHeroImage'
import { JournalItem, UpdateAlbumRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalDetailNav } from '../../services/JournalDetailNav'
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
  @State appending: boolean = false
  @State toastText: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

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

  private isShowcase(): boolean {
    if (this.item === undefined) {
      return false
    }
    return JournalItem.isShowcase(this.item)
  }

  private handleCreateMine(): void {
    if (!AuthService.requireAuth('create_album')) {
      this.onRequireAuth()
      return
    }
    JournalDetailNav.close()
    this.onCreateAlbum()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async appendFromGallery(): Promise<void> {
    if (this.item === undefined || this.appending) {
      return
    }
    if (!AuthService.requireAuth('edit_album')) {
      this.onRequireAuth()
      return
    }
    this.appending = true
    const ctx = getContext(this) as common.UIAbilityContext
    const keys = await PhotoPickService.pickAlbumPhotos(ctx, 9)
    this.appending = false
    if (keys.length === 0) {
      this.showToast('未选择图片')
      return
    }
    const existing = JournalItem.displayPhotoKeys(this.item)
    const merged: string[] = []
    for (const k of existing) {
      merged.push(k)
    }
    for (const k of keys) {
      let dup = false
      for (const m of merged) {
        if (m === k) {
          dup = true
          break
        }
      }
      if (!dup) {
        merged.push(k)
      }
    }
    const req = new UpdateAlbumRequest()
    req.userId = this.currentUsername
    req.imageKeys = merged
    if (this.item.coverKey.length > 0) {
      req.coverKey = this.item.coverKey
    } else if (merged.length > 0) {
      req.coverKey = merged[0]
    }
    const updated = await JournalBizService.updateAlbum(this.item.id, req)
    if (updated !== undefined) {
      this.item = updated
      this.showToast(`已添加 ${keys.length} 张图片`)
    } else {
      this.showToast(JournalBizService.lastError.length > 0
        ? JournalBizService.lastError
        : '添加失败，请稍后重试')
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
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          JournalHeroImage({
            coverKey: this.item.coverKey,
            fallbackKey: 'album_default',
            heroHeight: 220
          })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(166,123,91,0.08)', 0], ['rgba(61,58,54,0.78)', 1]]
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

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandAccent)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

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
              Text('暂无配图，可从相册添加或使用精选图库创建。')
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

        if (this.isShowcase()) {
          Column() {
            AppButton({
              label: '创建我的相册',
              variant: 'secondary',
              onTap: (): void => { this.handleCreateMine() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        } else if (AuthService.isLoggedIn()) {
          Column() {
            AppButton({
              label: this.appending ? '添加中…' : '从相册添加图片',
              variant: 'secondary',
              disabled: this.appending,
              onTap: (): void => { void this.appendFromGallery() }
            })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
        }
      }
    }
  }
}
