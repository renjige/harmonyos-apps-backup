import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateFavoriteRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationMedia } from '../services/InspirationMedia'
import { AuthService } from '../services/AuthService'
import { FavoriteSync } from '../services/FavoriteSync'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State favorites: InspirationItem[] = []
  @State loading: boolean = true
  @State kindFilter: string = 'all'
  @State showAddForm: boolean = false
  @State formTitle: string = ''
  @State formContent: string = ''
  @State formCoverKey: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private shownFavorites(): InspirationItem[] {
    if (this.kindFilter === 'all') {
      return this.favorites
    }
    const out: InspirationItem[] = []
    for (const item of this.favorites) {
      if (item.kind === this.kindFilter) {
        out.push(item)
      }
    }
    return out
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
    const req = new CreateFavoriteRequest()
    req.kind = this.formCoverKey.trim().length > 0 ? 'image' : 'text'
    req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '灵感收藏'
    req.content = this.formContent.trim()
    req.coverKey = this.formCoverKey.trim()
    req.userId = this.currentUsername
    const created = await InspirationBizService.createFavorite(req)
    this.submitting = false
    if (created !== undefined) {
      this.showAddForm = false
      FavoriteSync.bump()
      await this.reload()
    } else {
      this.formError = '添加失败，请稍后重试'
    }
  }

  private async removeFavorite(id: string): Promise<void> {
    const ok = await InspirationBizService.deleteFavorite(id)
    if (ok) {
      FavoriteSync.bump()
      await this.reload()
    }
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => {
          FavoriteSync.bump()
          this.onClose()
        })
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

      Row({ space: Theme.space.s2 }) {
        Text('全部')
          .fontSize(Theme.type.caption)
          .fontColor(this.kindFilter === 'all' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.kindFilter === 'all' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.kindFilter = 'all' })
        Text('文字')
          .fontSize(Theme.type.caption)
          .fontColor(this.kindFilter === 'text' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.kindFilter === 'text' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.kindFilter = 'text' })
        Text('图片')
          .fontSize(Theme.type.caption)
          .fontColor(this.kindFilter === 'image' ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.kindFilter === 'image' ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .onClick((): void => { this.kindFilter = 'image' })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

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
            if (this.shownFavorites().length === 0) {
              AppEmpty({
                title: '这一类还没有收藏',
                description: '切换筛选，或从详情页加入对应类型'
              })
            }
            ForEach(this.shownFavorites(), (item: InspirationItem) => {
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
                  .onClick((): void => { void this.removeFavorite(item.id) })
                }
                .width('100%')
                if (item.coverKey.length > 0) {
                  Image(InspirationMedia.coverMedia(item.coverKey))
                    .width('100%')
                    .height(120)
                    .borderRadius(Theme.radius.lg)
                    .objectFit(ImageFit.Cover)
                }
                if (item.content.length > 0 || item.summary.length > 0) {
                  Text(FavoriteSync.displayContent(item.content.length > 0 ? item.content : item.summary))
                    .fontSize(Theme.type.body)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
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
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX })

      if (this.formError.length > 0) {
        Text(this.formError)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().danger)
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }

      Column({ space: Theme.space.s4 }) {
        TextInput({ text: this.formTitle, placeholder: '标题（可选）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formTitle = v })
        TextArea({ text: this.formContent, placeholder: '写下想收藏的文字灵感…' })
          .width('100%')
          .height(120)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formContent = v })
        TextInput({ text: this.formCoverKey, placeholder: '图片 coverKey（可选）' })
          .width('100%')
          .height(44)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.sm)
          .onChange((v: string) => { this.formCoverKey = v })
        AppButton({
          label: this.submitting ? '保存中…' : '保存收藏',
          disabled: this.submitting,
          onTap: (): void => { void this.submitFavorite() }
        })
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(30)
  }
}
