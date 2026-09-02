import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateBoardRequest, InspirationItem } from '../models/InspirationModels'
import { InspirationBizService } from '../services/InspirationBizService'
import { InspirationDetailNav } from '../services/InspirationDetailNav'
import { InspirationMedia } from '../services/InspirationMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct BoardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onBoardCreated: () => void = () => {}
  @State boards: InspirationItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formTextCard: string = ''
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
    this.formError = ''
    this.showForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeForm(): void {
    this.showForm = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  private buildCardsJson(): string {
    const cards: object[] = []
    if (this.formTextCard.trim().length > 0) {
      const textCard = new CardTextEntry()
      textCard.type = 'text'
      textCard.text = this.formTextCard.trim()
      textCard.x = 20
      textCard.y = 20
      cards.push(textCard)
    }
    return JSON.stringify(cards)
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
    this.submitting = true
    this.formError = ''
    const cardsJson = this.buildCardsJson()
    const req = new CreateBoardRequest()
    req.title = this.formTitle.trim()
    req.description = this.formDescription.trim()
    req.coverKey = 'board_default'
    req.cardsJson = cardsJson
    req.body = cardsJson
    req.userId = this.currentUsername
    const created = await InspirationBizService.createMoodBoard(req)
    this.submitting = false
    if (created !== undefined) {
      this.closeForm()
      await this.reload()
      this.onBoardCreated()
    } else {
      this.formError = '创建失败，请稍后重试'
    }
  }

  build() {
    Stack() {
      Column() {
        AppHeader({ title: '画板', subtitle: '情绪板与视觉参考集合' })
        if (this.loading) {
          AppLoading({ label: '加载画板…' }).layoutWeight(1)
        } else if (this.boards.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无画板',
              description: '浏览精选画板或创建属于自己的创意画板',
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
                    Image(InspirationMedia.coverMedia(item.coverKey))
                      .width('100%')
                      .aspectRatio(1)
                      .borderRadius(Theme.radius.lg)
                      .objectFit(ImageFit.Cover)
                    Text(item.title)
                      .fontSize(Theme.type.subhead)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    if (item.kind === 'showcase') {
                      Text('精选')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandAccent)
                    } else {
                      Text('我的画板')
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textTertiary)
                    }
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
        Text('创建画板')
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

      Column({ space: Theme.space.s4 }) {
        Column({ space: 6 }) {
          Text('画板名称')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formTitle, placeholder: '例如：夏日品牌_refresh' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTitle = v })
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('简介')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextArea({ text: this.formDescription, placeholder: '描述这个画板的视觉方向…' })
            .width('100%')
            .height(100)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDescription = v })
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
        top: Theme.space.s4
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .zIndex(25)
  }
}

class CardTextEntry {
  type: string = 'text'
  text: string = ''
  x: number = 0
  y: number = 0
}
