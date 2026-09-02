import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateFavoriteRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { CoverPhotoPicker } from '../components/inspiration/CoverPhotoPicker'
import { InspirationCoverImage } from '../components/inspiration/InspirationCoverImage'
import { common } from '@kit.AbilityKit'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State favorites: InspirationItem[] = []
  @State loading: boolean = true
  @State showAddForm: boolean = false
  @State formTitle: string = ''
  @State formContent: string = ''
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State pendingDeleteId: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.favorites = await InspirationBizService.loadFavorites(this.currentUsername)
    } else {
      this.favorites = []
    }
    this.loading = false
  }

  private openAddForm(): void {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formContent = ''
    this.formCoverKey = ''
    this.formError = ''
    this.showAddForm = true
  }

  private async submitFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.formContent.trim().length === 0 && this.formCoverKey.trim().length === 0) {
      this.formError = '请填写收藏内容或封面标识'
      return
    }
    this.submitting = true
    this.formError = ''
    try {
      const req = new CreateFavoriteRequest()
      req.kind = this.formCoverKey.trim().length > 0 ? 'image' : 'text'
      req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '灵感收藏'
      req.content = this.formContent.trim()
      req.coverKey = this.formCoverKey.trim()
      req.userId = this.currentUsername
      const created = await InspirationBizService.createFavorite(req)
      if (created !== undefined) {
        this.showAddForm = false
        await this.reload()
      } else {
        this.formError = '添加失败，请稍后重试'
      }
    } catch {
      this.formError = '添加失败，请稍后重试'
    }
    this.submitting = false
  }

  private async removeFavorite(id: string): Promise<void> {
    const ok = await InspirationBizService.deleteFavorite(id)
    if (ok) {
      await this.reload()
    }
    this.pendingDeleteId = ''
  }

  private toggleFormCover(key: string): void {
    if (this.formCoverKey === key) {
      this.formCoverKey = ''
    } else {
      this.formCoverKey = key
    }
  }

  private async pickFormCover(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const key = await PhotoPickService.pickOne(ctx)
    if (key.length > 0) {
      this.formCoverKey = key
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Text('灵感收藏')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.openAddForm() })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.loading) {
        AppLoading({ label: '加载收藏…' }).layoutWeight(1)
      } else if (this.favorites.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有收藏',
            description: AuthService.isLoggedIn()
              ? '收藏文字、图片或从推荐灵感详情页加入收藏'
              : '登录后可添加灵感收藏',
            actionLabel: '添加收藏',
            onAction: (): void => { this.openAddForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.favorites, (item: InspirationItem) => {
              Column({ space: 8 }) {
                Row() {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  Column() {
                    AppIcon({ name: 'close', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width(36)
                  .height(36)
                  .justifyContent(FlexAlign.Center)
                  .onClick((): void => { this.pendingDeleteId = item.id })
                }
                .width('100%')
                if (item.coverKey.length > 0) {
                  InspirationCoverImage({
                    coverKey: item.coverKey,
                    imageWidth: '100%',
                    imageHeight: 120,
                    useAspectRatio: false,
                    cornerRadius: Theme.radius.lg
                  })
                }
                if (item.content.length > 0 || item.summary.length > 0) {
                  Text(item.content.length > 0 ? item.content : item.summary)
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                    .lineHeight(22)
                }
                Text(item.kind === 'image' ? '图片收藏' : '文字收藏')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textTertiary)
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
              .border({ width: 1, color: Theme.colors().strokeHairline })
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
      }

      if (this.showAddForm) {
        this.AddFormOverlay()
      }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.pendingDeleteId.length > 0) {
        this.DeleteConfirmOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  AddFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.showAddForm = false })
        Text('添加收藏')
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
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          TextInput({ text: this.formTitle, placeholder: '标题（可选）' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
          TextArea({ text: this.formContent, placeholder: '写下想收藏的文字灵感…' })
            .width('100%')
            .height(160)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formContent = v })
          CoverPhotoPicker({
            selectedKeys: this.formCoverKey.length > 0 ? [this.formCoverKey] : [],
            maxCount: 1,
            showBuiltin: false,
            galleryLabel: '从相册选图',
            onToggle: (key: string): void => { this.toggleFormCover(key) },
            onPickGallery: (): void => { void this.pickFormCover() }
          })
          Text('可只填文字、只选相册图片，或两者都填。')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({
            label: this.submitting ? '保存中…' : '保存收藏',
            disabled: this.submitting,
            onTap: (): void => { void this.submitFavorite() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(30)
  }

  @Builder
  DeleteConfirmOverlay() {
    Column({ space: Theme.space.s4 }) {
      Text('确定删除这条收藏？')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.pendingDeleteId = '' }
          })
        }
        .layoutWeight(1)
        Column() {
          AppButton({
            label: '确认删除',
            onTap: (): void => { void this.removeFavorite(this.pendingDeleteId) }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('88%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .zIndex(40)
  }
}
