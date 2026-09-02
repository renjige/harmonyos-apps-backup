import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { PinBoardSheet } from '../inspiration/PinBoardSheet'
import { CompareWriteSheet } from '../inspiration/CompareWriteSheet'
import { CreateFavoriteRequest, InspirationItem } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationMedia } from '../../services/InspirationMedia'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'
import { FavoriteSync } from '../../services/FavoriteSync'
import { DailyPromptService } from '../../services/DailyPromptService'
import { ClipService } from '../../services/ClipService'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct FeaturedDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onContentChanged: () => void = () => {}
  onWriteLike: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State favoritedId: string = ''
  @State showPin: boolean = false
  @State showCompare: boolean = false

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  onTokenChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findFeatured(this.itemId)
    await this.refreshFavoriteState()
    this.loading = false
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      void GrowthService.recordBrowse(
        this.currentUsername, 'featured', this.item.id, this.item.title
      )
    }
  }

  private async refreshFavoriteState(): Promise<void> {
    this.favoritedId = ''
    if (this.item === undefined || !AuthService.isLoggedIn()) {
      return
    }
    const list = await InspirationBizService.loadFavorites(this.currentUsername)
    const found = FavoriteSync.findMatch(list, 'featured', this.item.id, this.item.title)
    if (found !== undefined) {
      this.favoritedId = found.id
    }
  }

  private async handleToggleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    if (this.favoritedId.length > 0) {
      const ok = await InspirationBizService.deleteFavorite(this.favoritedId)
      if (ok) {
        this.favoritedId = ''
        FavoriteSync.bump()
        this.showToast('已取消收藏')
      } else {
        this.showToast('取消失败，请稍后重试')
      }
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.coverKey = this.item.coverKey
    const body = this.item.summary.length > 0 ? this.item.summary : this.item.body
    req.content = FavoriteSync.encodeContent(FavoriteSync.sourceKey('featured', this.item.id), body)
    const created = await InspirationBizService.createFavorite(req)
    if (created !== undefined) {
      this.favoritedId = created.id
      FavoriteSync.bump()
      this.showToast('已加入灵感收藏')
      void GrowthService.afterEventAuto(
        this.currentUsername, 'favorite', this.item.title, 'featured', this.item.id
      )
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  private openPin(): void {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.showPin = true
  }

  private openCompare(): void {
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.showCompare = true
  }

  private handleWriteLike(): void {
    if (this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    const tags = this.item.tags.join(', ')
    DailyPromptService.applyCustom(
      this.item.title,
      `参考这篇精选：\n${this.item.summary.length > 0 ? this.item.summary : this.item.body}\n\n我的版本：`,
      tags
    )
    InspirationDetailNav.close()
    this.onWriteLike()
  }

  private async handleCopy(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const text = `${this.item.title}\n${this.item.body.length > 0 ? this.item.body : this.item.summary}`
    const ok = await ClipService.copyText(text)
    this.showToast(ok ? '已复制到剪贴板' : '复制失败')
  }

  build() {
    Stack() {
      if (this.loading) {
        this.BlockedPane('加载推荐灵感…', '正在拉取精选内容')
      } else if (this.item === undefined) {
        this.BlockedPane('灵感不存在', '可能已被删除或网络异常')
      } else {
        DetailShell({
          title: '推荐灵感',
          onClose: () => InspirationDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.showPin && this.item !== undefined) {
        Column() {
          PinBoardSheet({
            pinTitle: this.item.title,
            pinBody: this.item.summary.length > 0 ? this.item.summary : this.item.body,
            pinCoverKey: this.item.coverKey,
            onClose: (): void => { this.showPin = false },
            onPinned: (): void => {
              this.onContentChanged()
              if (this.item !== undefined) {
                void GrowthService.afterEventAuto(
                  this.currentUsername, 'pin', this.item.title, 'board', this.item.id
                )
              }
              this.showToast('已钉到画板')
            },
            onRequireAuth: (): void => this.onRequireAuth()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(28)
      }

      if (this.showCompare && this.item !== undefined) {
        Column() {
          CompareWriteSheet({
            sourceTitle: this.item.title,
            sourceBody: this.item.body.length > 0 ? this.item.body : this.item.summary,
            sourceCoverKey: this.item.coverKey,
            onClose: (): void => { this.showCompare = false },
            onSaved: (): void => {
              this.onContentChanged()
              this.showToast('已生成对照备忘')
            },
            onRequireAuth: (): void => this.onRequireAuth()
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(32)
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
  BlockedPane(title: string, description: string) {
    Column({ space: Theme.space.s4 }) {
      Row() {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { InspirationDetailNav.close() })
        Blank()
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })
      Column() {
        AppEmpty({
          title: title,
          description: description,
          actionLabel: '关闭',
          onAction: (): void => { InspirationDetailNav.close() }
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .onClick((): void => { InspirationDetailNav.close() })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  DetailBody() {
    if (this.item === undefined) {
      Column()
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(InspirationMedia.coverMedia(this.item.coverKey))
            .width('100%')
            .height(220)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (this.item.recordDate.length > 0) {
              Text(this.item.recordDate)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        if (this.item.tags.length > 0) {
          Row({ space: 8 }) {
            ForEach(this.item.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
            }, (tag: string) => tag)
          }
          .width('100%')
        }

        AppCard({ title: '摘要', variant: 'plain' }) {
          Text(this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }

        AppCard({ title: '正文', variant: 'plain' }) {
          Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }

        AppButton({
          label: this.favoritedId.length > 0 ? '取消收藏' : '收藏这段灵感',
          variant: this.favoritedId.length > 0 ? 'secondary' : 'primary',
          onTap: (): void => { void this.handleToggleFavorite() }
        })
        Column() {
          AppButton({
            label: '钉到画板',
            variant: 'secondary',
            onTap: (): void => { this.openPin() }
          })
        }
        .width('100%')
        .onClick((): void => { this.openPin() })
        Column() {
          AppButton({
            label: '对照写备忘',
            variant: 'secondary',
            onTap: (): void => { this.openCompare() }
          })
        }
        .width('100%')
        .onClick((): void => { this.openCompare() })
        Column() {
          AppButton({
            label: '按这篇写一条',
            variant: 'secondary',
            onTap: (): void => { this.handleWriteLike() }
          })
        }
        .width('100%')
        .onClick((): void => { this.handleWriteLike() })
        Column() {
          AppButton({
            label: '复制正文',
            variant: 'ghost',
            onTap: (): void => { void this.handleCopy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleCopy() })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        bottom: Theme.space.s10
      })
    }
  }
}
