import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { PinBoardSheet } from '../inspiration/PinBoardSheet'
import { InspirationEditSheet } from '../inspiration/InspirationEditSheet'
import { CreateFavoriteRequest, CreatePlanRequest, InspirationItem, UpdateInspirationRequest } from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationMedia } from '../../services/InspirationMedia'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { AuthService } from '../../services/AuthService'
import { FavoriteSync } from '../../services/FavoriteSync'
import { DailyPromptService } from '../../services/DailyPromptService'
import { ClipService } from '../../services/ClipService'
import { InspirationConvertService } from '../../services/InspirationConvertService'
import { GrowthService } from '../../services/GrowthService'

@Component
export struct InspirationDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('currentUsername') currentUsername: string = ''
  @Prop @Watch('onItemIdChange') itemId: string = ''
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onContentChanged: () => void = () => {}
  onEditInspiration: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State loading: boolean = true
  @State toastText: string = ''
  @State favoritedId: string = ''
  @State showPin: boolean = false
  @State showEdit: boolean = false
  @State confirmDelete: boolean = false
  @State actionBusy: boolean = false
  @State editTitle: string = ''
  @State editBody: string = ''
  @State editTags: string = ''
  @State editDate: string = ''
  @State editCoverKey: string = ''
  @State editError: string = ''

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

  private failText(fallback: string): string {
    if (InspirationBizService.lastError.length > 0) {
      return InspirationBizService.lastError
    }
    return fallback
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findInspiration(this.itemId)
    await this.refreshFavoriteState()
    this.loading = false
    if (this.item !== undefined && AuthService.isLoggedIn()) {
      void GrowthService.recordBrowse(
        this.currentUsername, 'inspiration', this.item.id, this.item.title
      )
    }
  }

  private async refreshFavoriteState(): Promise<void> {
    this.favoritedId = ''
    if (this.item === undefined || !AuthService.isLoggedIn()) {
      return
    }
    const list = await InspirationBizService.loadFavorites(this.currentUsername)
    const found = FavoriteSync.findMatch(list, 'inspiration', this.item.id, this.item.title)
    if (found !== undefined) {
      this.favoritedId = found.id
    }
  }

  private async handleToggleFavorite(): Promise<void> {
    if (this.actionBusy) {
      return
    }
    if (!AuthService.requireAuth('add_favorite')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.actionBusy = true
    if (this.favoritedId.length > 0) {
      const ok = await InspirationBizService.deleteFavorite(this.favoritedId)
      this.actionBusy = false
      if (ok) {
        this.favoritedId = ''
        FavoriteSync.bump()
        this.showToast('已取消收藏')
      } else {
        this.showToast(this.failText('取消失败，请稍后重试'))
      }
      return
    }
    const req = new CreateFavoriteRequest()
    req.kind = 'text'
    req.title = this.item.title
    req.coverKey = this.item.coverKey
    const body = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.content = FavoriteSync.encodeContent(FavoriteSync.sourceKey('inspiration', this.item.id), body)
    const created = await InspirationBizService.createFavorite(req)
    this.actionBusy = false
    if (created !== undefined) {
      this.favoritedId = created.id
      FavoriteSync.bump()
      this.showToast('已加入灵感收藏')
      void GrowthService.afterEventAuto(
        this.currentUsername, 'favorite', this.item.title, 'inspiration', this.item.id
      )
    } else {
      this.showToast(this.failText('收藏失败，请稍后重试'))
    }
  }

  private openPin(): void {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.showPin = true
  }

  private openEdit(): void {
    if (this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    this.editTitle = this.item.title
    this.editBody = this.item.body
    this.editTags = this.item.tags.join(', ')
    this.editDate = this.item.recordDate.length > 0 ? this.item.recordDate : new Date().toISOString().slice(0, 10)
    this.editCoverKey = this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration'
    this.editError = ''
    this.showEdit = true
  }

  private parseTags(raw: string): string[] {
    const parts = raw.split(',')
    const out: string[] = []
    for (const p of parts) {
      const t = p.trim()
      if (t.length > 0) {
        out.push(t)
      }
    }
    return out
  }

  private async saveEdit(): Promise<void> {
    if (this.actionBusy || this.item === undefined) {
      return
    }
    if (this.editTitle.trim().length === 0) {
      this.editError = '请填写标题'
      return
    }
    this.actionBusy = true
    this.editError = ''
    const req = new UpdateInspirationRequest()
    req.title = this.editTitle.trim()
    req.body = this.editBody.trim()
    req.summary = req.body.length > 80 ? req.body.substring(0, 80) : req.body
    req.tags = this.parseTags(this.editTags)
    req.recordDate = this.editDate
    req.coverKey = this.editCoverKey.length > 0 ? this.editCoverKey : 'hero_latest_inspiration'
    const saved = await InspirationBizService.updateInspiration(this.item.id, req)
    this.actionBusy = false
    if (saved !== undefined) {
      if (saved.title.length > 0) {
        this.item = saved
      } else {
        const next = new InspirationItem()
        next.id = this.item.id
        next.title = req.title
        next.body = req.body
        next.summary = req.summary
        next.tags = req.tags
        next.recordDate = req.recordDate
        next.coverKey = req.coverKey
        next.userId = this.item.userId
        this.item = next
      }
      this.showEdit = false
      this.onContentChanged()
      this.showToast('已保存修改')
    } else {
      this.editError = this.failText('保存失败，请稍后重试')
    }
  }

  private async handleDelete(): Promise<void> {
    if (this.actionBusy || this.item === undefined) {
      return
    }
    this.actionBusy = true
    const ok = await InspirationBizService.deleteInspiration(this.item.id)
    this.actionBusy = false
    this.confirmDelete = false
    if (ok) {
      await GrowthService.purgeInspirationRefs(this.currentUsername, this.item.id)
      InspirationDetailNav.close()
      this.onContentChanged()
      return
    }
    this.showToast(this.failText('删除失败，请稍后重试'))
  }

  private async handleMakePlan(): Promise<void> {
    if (this.actionBusy) {
      return
    }
    if (!AuthService.requireAuth('create_plan')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.actionBusy = true
    this.showToast('正在做成创意计划…')
    const req = new CreatePlanRequest()
    req.title = this.item.title
    const body = this.item.body.length > 0 ? this.item.body : this.item.summary
    req.goal = InspirationConvertService.buildPlanGoal(this.item.title, body, this.item.id)
    req.summary = this.item.summary.length > 0 ? this.item.summary : this.item.title
    req.progress = 10
    req.userId = this.currentUsername
    const created = await InspirationBizService.createCreativePlan(req)
    this.actionBusy = false
    if (created !== undefined && created.id.length > 0) {
      // 先打开计划详情，避免成长统计 await 卡住；并强制卸掉灵感详情壳
      InspirationDetailNav.openPlan(created.id)
      this.onContentChanged()
      void GrowthService.afterEventAuto(
        this.currentUsername, 'plan', created.title, 'plan', created.id
      )
      return
    }
    this.showToast(this.failText('创建计划失败，请稍后重试'))
  }

  private async handleCopy(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    const text = `${this.item.title}\n${this.item.body.length > 0 ? this.item.body : this.item.summary}`
    const ok = await ClipService.copyText(text)
    this.showToast(ok ? '已复制到剪贴板' : '复制失败')
  }

  private handleVariant(): void {
    if (this.item === undefined) {
      return
    }
    if (!AuthService.requireAuth('create_inspiration')) {
      this.onRequireAuth()
      return
    }
    const tags = this.item.tags.join(', ')
    DailyPromptService.applyCustom(
      `${this.item.title}（变体）`,
      `原灵感要点：\n${this.item.body.length > 0 ? this.item.body : this.item.summary}\n\n这次我想改成：`,
      tags
    )
    InspirationDetailNav.close()
    this.onEditInspiration()
  }

  build() {
    Stack() {
      if (this.loading) {
        this.BlockedPane('加载灵感…', '正在从云端拉取这条灵感')
      } else if (this.item === undefined) {
        this.BlockedPane('灵感不存在', '可能已被删除或网络异常')
      } else {
        DetailShell({
          title: '我的灵感',
          onClose: () => InspirationDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.showPin && this.item !== undefined) {
        Column() {
          PinBoardSheet({
            pinTitle: this.item.title,
            pinBody: this.item.body.length > 0 ? this.item.body : this.item.summary,
            pinCoverKey: this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration',
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

      if (this.showEdit) {
        Column() {
          InspirationEditSheet({
            formTitle: this.editTitle,
            formBody: this.editBody,
            formTags: this.editTags,
            formDate: this.editDate,
            formCoverKey: this.editCoverKey,
            formError: this.editError,
            saving: this.actionBusy,
            onTitleChange: (v: string): void => { this.editTitle = v },
            onBodyChange: (v: string): void => { this.editBody = v },
            onTagsChange: (v: string): void => { this.editTags = v },
            onDateChange: (v: string): void => { this.editDate = v },
            onCoverChange: (v: string): void => { this.editCoverKey = v },
            onClose: (): void => { this.showEdit = false },
            onSave: (): void => { void this.saveEdit() }
          })
        }
        .width('100%')
        .height('100%')
        .zIndex(32)
      }

      if (this.confirmDelete) {
        Column() {
          this.DeleteConfirmCard()
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(27,42,65,0.45)')
        .zIndex(40)
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
  DeleteConfirmCard() {
    Column({ space: Theme.space.s4 }) {
      Text('删除这条灵感？')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text('删除后列表与空间会立刻更新，无法从这里恢复。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
      Row({ space: Theme.space.s3 }) {
        Column() {
          AppButton({
            label: '取消',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = false }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { this.confirmDelete = false })
        Column() {
          AppButton({
            label: this.actionBusy ? '删除中…' : '确认删除',
            variant: 'danger',
            disabled: this.actionBusy,
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.handleDelete() })
      }
      .width('100%')
    }
    .width('88%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .onClick((): void => {})
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
          Image(InspirationMedia.coverMedia(
            this.item.coverKey.length > 0 ? this.item.coverKey : 'hero_latest_inspiration'
          ))
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.recordDate.length > 0 ? this.item.recordDate : '灵感记录')
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

        if (this.item.summary.length > 0) {
          AppCard({ title: '摘要', variant: 'plain' }) {
            Text(this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
        }

        AppCard({ title: '正文', variant: 'plain' }) {
          Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
            .lineHeight(24)
        }

        Column() {
          AppButton({
            label: this.favoritedId.length > 0 ? '取消收藏' : '加入灵感收藏',
            variant: this.favoritedId.length > 0 ? 'secondary' : 'primary',
            onTap: (): void => { void this.handleToggleFavorite() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleToggleFavorite() })

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
            label: '编辑这条',
            variant: 'secondary',
            onTap: (): void => { this.openEdit() }
          })
        }
        .width('100%')
        .onClick((): void => { this.openEdit() })

        Column() {
          AppButton({
            label: this.actionBusy ? '处理中…' : '做成创意计划',
            variant: 'secondary',
            disabled: this.actionBusy,
            onTap: (): void => { void this.handleMakePlan() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleMakePlan() })

        Column() {
          AppButton({
            label: '再写一条变体',
            variant: 'secondary',
            onTap: (): void => { this.handleVariant() }
          })
        }
        .width('100%')
        .onClick((): void => { this.handleVariant() })

        Column() {
          AppButton({
            label: '复制正文',
            variant: 'ghost',
            onTap: (): void => { void this.handleCopy() }
          })
        }
        .width('100%')
        .onClick((): void => { void this.handleCopy() })

        Column() {
          AppButton({
            label: '删除灵感',
            variant: 'danger',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        .onClick((): void => { this.confirmDelete = true })
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
