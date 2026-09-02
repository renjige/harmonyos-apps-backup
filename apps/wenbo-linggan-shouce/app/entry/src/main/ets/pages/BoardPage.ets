import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { BoardPhotoPicker } from '../components/inspiration/BoardPhotoPicker'
import { InspirationCoverImage } from '../components/inspiration/InspirationCoverImage'
import { BoardCard, BoardCardList, CreateBoardRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { PhotoPickService } from '../services/PhotoPickService'
import { AuthService } from '../services/AuthService'
import { common } from '@kit.AbilityKit'

@Component
export struct BoardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onRequireAuth: () => void = () => {}
  onBoardCreated: () => void = () => {}
  @State boards: InspirationItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formTextCard: string = ''
  @State formImageKeys: string[] = []
  @State formError: string = ''
  @State submitting: boolean = false
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.boards = await InspirationBizService.loadMoodBoards(this.currentUsername)
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formDescription = ''
    this.formTextCard = ''
    this.formImageKeys = []
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private toggleImage(key: string): void {
    const next: string[] = []
    let found = false
    for (const k of this.formImageKeys) {
      if (k === key) {
        found = true
      } else {
        next.push(k)
      }
    }
    if (!found) {
      if (next.length >= 9) {
        this.formError = '最多选择 9 张图片'
        return
      }
      next.push(key)
    }
    this.formImageKeys = next
    this.formError = ''
  }

  private async pickFromGallery(): Promise<void> {
    const remain = 9 - this.formImageKeys.length
    if (remain <= 0) {
      this.formError = '最多选择 9 张图片'
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const keys = await PhotoPickService.pickMany(ctx, remain)
    if (keys.length === 0) {
      return
    }
    const merged: string[] = []
    for (const k of this.formImageKeys) {
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
    this.formImageKeys = merged
    this.formError = ''
  }

  private buildCards(): BoardCard[] {
    const cards: BoardCard[] = []
    for (const key of this.formImageKeys) {
      const imageCard = new BoardCard()
      imageCard.type = 'image'
      imageCard.imageKey = key
      cards.push(imageCard)
    }
    if (this.formTextCard.trim().length > 0) {
      const textCard = new BoardCard()
      textCard.type = 'text'
      textCard.text = this.formTextCard.trim()
      cards.push(textCard)
    }
    return cards
  }

  private async submitBoard(): Promise<void> {
    if (!AuthService.requireAuth('create_board')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写画板名称'
      return
    }
    if (this.formImageKeys.length === 0) {
      this.formError = '请至少选择一张图片，画板才能作为相册使用'
      return
    }
    this.submitting = true
    this.formError = ''
    try {
      const cards = this.buildCards()
      const cardsJson = BoardCardList.encode(cards)
      const req = new CreateBoardRequest()
      req.title = this.formTitle.trim()
      req.description = this.formDescription.trim()
      req.coverKey = this.formImageKeys[0]
      req.imageKeys = this.formImageKeys
      req.cardsJson = cardsJson
      req.body = cardsJson
      req.userId = this.currentUsername
      const created = await InspirationBizService.createMoodBoard(req)
      if (created !== undefined) {
        this.closeForm()
        await this.reload()
        this.onBoardCreated()
        InspirationDetailNav.openBoard(created.id)
      } else {
        const msg = InspirationBizService.lastError
        this.formError = msg.length > 0 ? msg : '创建失败，请稍后重试'
      }
    } catch {
      this.formError = '创建失败，请稍后重试'
    }
    this.submitting = false
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '画板', subtitle: '把图片和文字收进一本创意相册' })
        if (this.loading) {
          AppLoading({ label: '加载画板…' }).layoutWeight(1)
        } else if (this.boards.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有画板',
              description: '选择几张图，创建属于你的灵感相册',
              actionLabel: '创建画板',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Grid() {
              ForEach(this.boards, (item: InspirationItem) => {
                GridItem() {
                  Column({ space: 8 }) {
                    InspirationCoverImage({
                      coverKey: item.coverKey,
                      useAspectRatio: true,
                      cornerRadius: Theme.radius.lg
                    })
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.kind === 'showcase' ? '精选' : `${item.imageKeys.length > 0 ? item.imageKeys.length : 1} 张图`)
                      .fontSize(Theme.type.caption)
                      .fontColor(item.kind === 'showcase' ? Theme.colors().brandAccent : Theme.colors().textTertiary)
                  }
                  .width('100%')
                  .onClick((): void => { InspirationDetailNav.openBoard(item.id) })
                }
              }, (item: InspirationItem) => item.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(Theme.space.s3)
            .rowsGap(Theme.space.s4)
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
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (!this.showForm) {
        Column() {
          AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
        }
        .width(56)
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().brandPrimary)
        .borderRadius(Theme.radius.pill)
        .position({ x: '78%', y: '82%' })
        .onClick((): void => { this.openCreateForm() })
      }

      if (this.showForm) {
        this.BoardFormOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BoardFormOverlay() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'close', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick((): void => { this.closeForm() })
        Text('创建画板相册')
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
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
      }

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Column({ space: 6 }) {
            Text('画板名称')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTitle, placeholder: '例如：夏日配色备忘' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('简介（可选）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextArea({ text: this.formDescription, placeholder: '这本相册想收集什么灵感…' })
              .width('100%')
              .height(80)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formDescription = v })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('添加图片（相册或内置素材，至少 1 张）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            BoardPhotoPicker({
              selectedKeys: this.formImageKeys,
              onToggle: (key: string): void => { this.toggleImage(key) },
              onPickGallery: (): void => { void this.pickFromGallery() }
            })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text('文字卡片（可选）')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            TextInput({ text: this.formTextCard, placeholder: 'Fresh · Airy · Confident' })
              .width('100%')
              .height(44)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTextCard = v })
          }
          .width('100%')

          AppButton({
            label: this.submitting ? '创建中…' : '创建画板',
            disabled: this.submitting,
            onTap: (): void => { void this.submitBoard() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}
