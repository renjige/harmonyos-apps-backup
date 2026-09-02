import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { BoardPhotoPicker } from '../inspiration/BoardPhotoPicker'
import { InspirationCoverImage } from '../inspiration/InspirationCoverImage'
import { DetailShell } from './DetailShell'
import {
  BoardCard,
  BoardCardList,
  CreateBoardRequest,
  InspirationItem,
  UpdateBoardRequest
} from '../../models/InspirationModels'
import { InspirationBizService } from '../../services/InspirationBizService'
import { InspirationDetailNav } from '../../services/InspirationDetailNav'
import { PhotoPickService } from '../../services/PhotoPickService'
import { AuthService } from '../../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct BoardDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onCreateBoard: () => void = () => {}
  onBoardChanged: () => void = () => {}
  @State item: InspirationItem | undefined = undefined
  @State cards: BoardCard[] = []
  @State loading: boolean = true
  @State toastText: string = ''
  @State showAddPhotos: boolean = false
  @State addKeys: string[] = []
  @State addText: string = ''
  @State saving: boolean = false
  @State previewKey: string = ''
  @State confirmDelete: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2400)
  }

  private isMine(): boolean {
    if (this.item === undefined) {
      return false
    }
    return this.item.kind !== 'showcase' && this.item.userId === this.currentUsername && this.currentUsername.length > 0
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.item = await InspirationBizService.findMoodBoard(this.itemId)
    if (this.item !== undefined) {
      this.cards = BoardCardList.fromItem(this.item)
    } else {
      this.cards = []
    }
    this.loading = false
  }

  private openAddPhotos(): void {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.addKeys = []
    this.addText = ''
    this.showAddPhotos = true
  }

  private toggleAddKey(key: string): void {
    const next: string[] = []
    let found = false
    for (const k of this.addKeys) {
      if (k === key) {
        found = true
      } else {
        next.push(k)
      }
    }
    if (!found && next.length < 9) {
      next.push(key)
    }
    this.addKeys = next
  }

  private async pickAddFromGallery(): Promise<void> {
    const remain = 9 - this.addKeys.length
    if (remain <= 0) {
      this.showToast('最多再选 9 张')
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const keys = await PhotoPickService.pickMany(ctx, remain)
    const merged: string[] = []
    for (const k of this.addKeys) {
      merged.push(k)
    }
    for (const k of keys) {
      let exists = false
      for (const m of merged) {
        if (m === k) {
          exists = true
          break
        }
      }
      if (!exists && merged.length < 9) {
        merged.push(k)
      }
    }
    this.addKeys = merged
  }

  private cardKey(card: BoardCard, index: number): string {
    return `${card.type}_${card.imageKey}_${card.text}_${index}`
  }

  private async persistCards(next: BoardCard[], toast: string): Promise<boolean> {
    if (this.item === undefined) {
      return false
    }
    this.saving = true
    const json = BoardCardList.encode(next)
    const keys = BoardCardList.imageKeysOf(next)
    const req = new UpdateBoardRequest()
    req.title = this.item.title
    req.description = this.item.description
    req.coverKey = keys.length > 0 ? keys[0] : this.item.coverKey
    req.imageKeys = keys
    req.cardsJson = json
    req.body = json
    const updated = await InspirationBizService.updateMoodBoard(this.item.id, req)
    this.saving = false
    if (updated !== undefined) {
      this.item = updated
      this.cards = BoardCardList.fromItem(updated)
      this.onBoardChanged()
      this.showToast(toast)
      return true
    }
    const hint = InspirationBizService.lastError.length > 0 ? InspirationBizService.lastError : '请稍后重试'
    this.showToast(`保存失败：${hint}`)
    return false
  }

  private async saveAddedCards(): Promise<void> {
    if (this.addKeys.length === 0 && this.addText.trim().length === 0) {
      this.showToast('请选择相册图片或填写文字卡片')
      return
    }
    const next: BoardCard[] = []
    for (const c of this.cards) {
      next.push(c)
    }
    for (const key of this.addKeys) {
      const imageCard = new BoardCard()
      imageCard.type = 'image'
      imageCard.imageKey = key
      next.push(imageCard)
    }
    if (this.addText.trim().length > 0) {
      const textCard = new BoardCard()
      textCard.type = 'text'
      textCard.text = this.addText.trim()
      next.push(textCard)
    }
    const ok = await this.persistCards(next, '已加入画板')
    if (ok) {
      this.showAddPhotos = false
    }
  }

  private async removeCardAt(index: number): Promise<void> {
    const next: BoardCard[] = []
    for (let i = 0; i < this.cards.length; i++) {
      if (i !== index) {
        next.push(this.cards[i])
      }
    }
    await this.persistCards(next, '已移除')
  }

  private async deleteBoard(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    this.saving = true
    const ok = await InspirationBizService.deleteMoodBoard(this.item.id)
    this.saving = false
    if (ok) {
      this.onBoardChanged()
      InspirationDetailNav.close()
    } else {
      this.showToast('删除失败，请稍后重试')
    }
    this.confirmDelete = false
  }

  private async collectToMine(): Promise<void> {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    if (this.item === undefined) {
      return
    }
    this.saving = true
    const req = new CreateBoardRequest()
    req.title = this.item.title
    req.description = this.item.description.length > 0 ? this.item.description : this.item.summary
    req.coverKey = this.item.coverKey
    req.imageKeys = BoardCardList.imageKeysOf(this.cards)
    req.cardsJson = BoardCardList.encode(this.cards)
    req.body = req.cardsJson
    req.userId = this.currentUsername
    const created = await InspirationBizService.createMoodBoard(req)
    this.saving = false
    if (created !== undefined) {
      this.showToast('已收藏到我的画板')
    } else {
      this.showToast('收藏失败，请稍后重试')
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.loading) {
        AppLoading({ label: '加载画板…' })
      } else if (this.item === undefined) {
        AppEmpty({ title: '画板不存在', description: '可能已被删除或网络异常' })
      } else {
        DetailShell({
          title: '画板相册',
          onClose: () => InspirationDetailNav.close(),
          body: () => { this.DetailBody() }
        })
      }

      if (this.showAddPhotos) {
        this.AddPhotosOverlay()
      }

      if (this.previewKey.length > 0) {
        this.PreviewOverlay()
      }

      if (this.confirmDelete) {
        this.DeleteConfirmOverlay()
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
        .zIndex(40)
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
          InspirationCoverImage({
            coverKey: this.item.coverKey,
            imageWidth: '100%',
            imageHeight: 220,
            useAspectRatio: false,
            cornerRadius: Theme.radius.xl,
            imageFit: ImageFit.Cover
          })
          Column()
            .width('100%')
            .height(220)
            .linearGradient({
              angle: 180,
              colors: [['rgba(27,42,65,0)', 0], ['rgba(27,42,65,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            Text(this.item.kind === 'showcase' ? '精选画板' : '我的相册')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandAccent)
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            Text(`${this.cards.length} 项内容 · 点击缩略图可放大`)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textOnInverse)
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.description.length > 0 || this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '简介', variant: 'plain' }) {
              Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .lineHeight(24)
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column({ space: Theme.space.s3 }) {
          Text('相册内容')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          if (this.cards.length === 0) {
            Text('这本画板还是空的，点下方按钮从相册添加图片。')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          } else {
            Grid() {
              ForEach(this.cards, (card: BoardCard, index: number) => {
                GridItem() {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    if (card.type === 'image') {
                      InspirationCoverImage({
                        coverKey: card.imageKey,
                        useAspectRatio: true,
                        cornerRadius: Theme.radius.lg
                      })
                    } else {
                      Column() {
                        Text(card.text)
                          .fontSize(Theme.type.body)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .width('100%')
                      }
                      .width('100%')
                      .aspectRatio(1)
                      .padding(Theme.space.s4)
                      .justifyContent(FlexAlign.Center)
                      .backgroundColor(Theme.colors().warningContainer)
                      .borderRadius(Theme.radius.lg)
                    }
                    if (this.isMine()) {
                      Text('移除')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandOnPrimary)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .backgroundColor('rgba(27,42,65,0.72)')
                        .borderRadius(Theme.radius.pill)
                        .margin(8)
                        .onClick((): void => { void this.removeCardAt(index) })
                    }
                  }
                  .width('100%')
                  .onClick((): void => {
                    if (card.type === 'image') {
                      this.previewKey = card.imageKey
                    }
                  })
                }
              }, (card: BoardCard, index: number) => this.cardKey(card, index))
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(Theme.space.s3)
            .rowsGap(Theme.space.s3)
            .width('100%')
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          if (this.isMine()) {
            AppButton({
              label: '从相册添加图片',
              onTap: (): void => { this.openAddPhotos() }
            })
            AppButton({
              label: '删除画板',
              variant: 'secondary',
              disabled: this.saving,
              onTap: (): void => { this.confirmDelete = true }
            })
          } else {
            AppButton({
              label: this.saving ? '收藏中…' : '收藏到我的画板',
              disabled: this.saving,
              onTap: (): void => { void this.collectToMine() }
            })
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }

  @Builder
  AddPhotosOverlay() {
    Column() {
      Row() {
        Text('从相册添加')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('取消')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .onClick((): void => { this.showAddPhotos = false })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s4,
        bottom: Theme.space.s3
      })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          BoardPhotoPicker({
            selectedKeys: this.addKeys,
            onToggle: (key: string): void => { this.toggleAddKey(key) },
            onPickGallery: (): void => { void this.pickAddFromGallery() }
          })
          TextInput({ text: this.addText, placeholder: '可选：再加一张文字卡片' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.addText = v })
          AppButton({
            label: this.saving ? '保存中…' : '加入画板',
            disabled: this.saving,
            onTap: (): void => { void this.saveAddedCards() }
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
    .zIndex(30)
  }

  @Builder
  PreviewOverlay() {
    Column() {
      Row() {
        Text('图片预览')
          .fontSize(Theme.type.title3)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
        Text('关闭')
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.previewKey = '' })
      }
      .width('100%')
      .padding(Theme.space.pageX)
      InspirationCoverImage({
        coverKey: this.previewKey,
        imageWidth: '100%',
        imageHeight: 480,
        useAspectRatio: false,
        cornerRadius: Theme.radius.lg,
        imageFit: ImageFit.Contain
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(27,42,65,0.92)')
    .zIndex(35)
    .onClick((): void => { this.previewKey = '' })
  }

  @Builder
  DeleteConfirmOverlay() {
    Column({ space: Theme.space.s4 }) {
      Text('确定删除这本画板？')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text('删除后无法恢复，相册中的图片记录将一并移除。')
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
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
            label: this.saving ? '删除中…' : '确认删除',
            disabled: this.saving,
            onTap: (): void => { void this.deleteBoard() }
          })
        }
        .layoutWeight(1)
        .onClick((): void => { void this.deleteBoard() })
      }
      .width('100%')
    }
    .width('88%')
    .padding(Theme.space.s5)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .zIndex(45)
  }
}
