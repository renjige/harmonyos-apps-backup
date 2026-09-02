import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AlbumPhotoTile } from './AlbumPhotoGrid'
import { CreateDiaryRequest } from '../../models/JournalModels'
import { JournalBizService } from '../../services/JournalBizService'
import { JournalImageCatalog } from '../../services/JournalImageCatalog'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AuthService } from '../../services/AuthService'
import { common } from '@kit.AbilityKit'

/** 首页快捷 — 记录生活瞬间（照片 + 短述） */
@Component
export struct MomentCaptureSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onSaved: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formPhotoKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @State picking: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  private todayIso(): string {
    return new Date().toISOString().slice(0, 10)
  }

  private mergePhotoKeys(newKeys: string[]): void {
    const merged: string[] = []
    for (let i = 0; i < this.formPhotoKeys.length; i++) {
      merged.push(this.formPhotoKeys[i])
    }
    for (let j = 0; j < newKeys.length; j++) {
      merged.push(newKeys[j])
    }
    this.formPhotoKeys = merged
  }

  private async pickPhotos(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    if (ctx === undefined || ctx === null) {
      this.formError = '无法打开相册，请稍后重试'
      return
    }
    this.picking = true
    const remain = 9 - this.formPhotoKeys.length
    const uris = await PhotoPickService.pickImages(ctx, remain > 0 ? remain : 1)
    if (uris.length > 0) {
      this.mergePhotoKeys(JournalImageCatalog.keysFromUris(uris))
      this.formError = ''
    } else if (PhotoPickService.lastError.length > 0) {
      this.formError = PhotoPickService.lastError
    }
    this.picking = false
  }

  private async submit(): Promise<void> {
    if (!AuthService.requireAuth('create_diary')) {
      this.onRequireAuth()
      return
    }
    if (this.formPhotoKeys.length === 0) {
      this.formError = '请至少选择一张生活照片'
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写瞬间标题'
      return
    }
    this.submitting = true
    this.formError = ''
    const req = new CreateDiaryRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.length > 0 ? req.body : req.title
    req.recordDate = this.todayIso()
    req.userId = this.currentUsername
    req.imageKeys = this.formPhotoKeys
    req.coverKey = this.formPhotoKeys[0]
    req.tags = ['生活瞬间']
    req.kind = 'moment'
    const created = await JournalBizService.createDiary(req)
    this.submitting = false
    if (created !== undefined) {
      this.onSaved()
      this.onClose()
    } else {
      this.formError = '保存失败，请稍后重试'
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.onClose() })
        Text('记录生活瞬间')
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
          AppButton({
            label: this.picking ? '打开相册…' : '从相册选择照片',
            onTap: (): void => { void this.pickPhotos() }
          })

          if (this.formPhotoKeys.length > 0) {
            Scroll() {
              Row({ space: Theme.space.s2 }) {
                ForEach(this.formPhotoKeys, (key: string) => {
                  AlbumPhotoTile({ photoKey: key, tileSize: 72 })
                }, (key: string) => key)
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
            Text(`已选 ${this.formPhotoKeys.length} 张（首张为封面）`)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')
          }

          TextInput({ text: this.formTitle, placeholder: '给这个瞬间起个名字…' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })

          TextArea({ text: this.formBody, placeholder: '补充一两句当时的心情（可选）' })
            .width('100%')
            .height(100)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formBody = v })

          AppButton({
            label: this.submitting ? '保存中…' : '保存到我的札记',
            disabled: this.submitting,
            onTap: (): void => { void this.submit() }
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
    .zIndex(26)
  }
}
