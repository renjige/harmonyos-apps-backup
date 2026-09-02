import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateBoardRequest, GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { GrowthDetailNav } from '../services/GrowthDetailNav'
import { GrowthMedia } from '../services/GrowthMedia'
import { AuthService } from '../services/AuthService'

@Component
export struct BoardPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onCreateTriggerChange') createTrigger: number = 0
  onRequireAuth: () => void = () => {}
  onBoardCreated: () => void = () => {}
  @State boards: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formDescription: string = ''
  @State formTextCard: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State lastBoardId: string = ''
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onCreateTriggerChange(): void {
    if (this.createTrigger > 0) {
      this.openCreateForm()
    }
  }

  private timelineDate(item: GrowthRecordItem): string {
    if (item.recordDate.length > 0) {
      return item.recordDate
    }
    if (item.createdAt.length >= 10) {
      return item.createdAt.substring(0, 10)
    }
    return '成长节点'
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.boards = await GrowthBizService.loadMoodBoards(this.currentUsername)
    this.lastBoardId = ''
    if (this.boards.length > 0) {
      this.lastBoardId = this.boards[this.boards.length - 1].id
    }
    this.loading = false
  }

  private openCreateForm(): void {
    if (!AuthService.requireAuth('create_goal')) {
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
    if (!AuthService.requireAuth('create_goal')) {
      this.onRequireAuth()
      return
    }
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写里程碑名称'
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
    const created = await GrowthBizService.createMoodBoard(req)
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
        AppHeader({ title: '成长时间轴', subtitle: '里程碑与成长轨迹纵向回顾' })
        if (this.loading) {
          AppLoading({ label: '加载时间轴…' }).layoutWeight(1)
        } else if (this.boards.length === 0) {
          Column() {
            AppEmpty({
              title: '暂无成长里程碑',
              description: '添加第一个里程碑，在时间轴上看见你的成长轨迹',
              actionLabel: '添加里程碑',
              onAction: (): void => { this.openCreateForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column({ space: 0 }) {
              ForEach(this.boards, (item: GrowthRecordItem) => {
                Row({ space: Theme.space.s3 }) {
                  Column() {
                    Column()
                      .width(12)
                      .height(12)
                      .backgroundColor(Theme.colors().brandPrimary)
                      .borderRadius(Theme.radius.pill)
                    if (item.id !== this.lastBoardId) {
                      Column()
                        .width(2)
                        .height(120)
                        .backgroundColor(Theme.colors().strokeHairline)
                    }
                  }
                  .width(20)
                  .alignItems(HorizontalAlign.Center)

                  Column({ space: 8 }) {
                    Text(this.timelineDate(item))
                      .fontSize(Theme.type.overline)
                      .fontColor(Theme.colors().brandPrimary)
                      .width('100%')
                    Row({ space: Theme.space.s3 }) {
                      Image(GrowthMedia.coverMedia(item.coverKey))
                        .width(72)
                        .height(72)
                        .borderRadius(Theme.radius.md)
                        .objectFit(ImageFit.Cover)
                      Column({ space: 4 }) {
                        Text(item.title)
                          .fontSize(Theme.type.subhead)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .width('100%')
                        Text(item.kind === 'showcase' ? '精选里程碑' : '我的里程碑')
                          .fontSize(Theme.type.caption)
                          .fontColor(item.kind === 'showcase' ?
                            Theme.colors().brandAccent : Theme.colors().textTertiary)
                          .width('100%')
                        if (item.summary.length > 0) {
                          Text(item.summary)
                            .fontSize(Theme.type.caption)
                            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .width('100%')
                        }
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                      AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                    }
                    .width('100%')
                    .padding(Theme.space.s4)
                    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                    .borderRadius(Theme.radius.lg)
                    .border({ width: 1, color: Theme.colors().strokeHairline })
                    .onClick((): void => { GrowthDetailNav.openBoard(item.id) })
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)
                .padding({ bottom: Theme.space.s4 })
              }, (item: GrowthRecordItem) => item.id)
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
          .edgeEffect(EdgeEffect.Spring)
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
        Text('添加成长里程碑')
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
          Text('里程碑名称')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formTitle, placeholder: '例如：完成第一个 30 天习惯' })
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
          TextArea({ text: this.formDescription, placeholder: '描述这个成长节点的意义…' })
            .width('100%')
            .height(100)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formDescription = v })
        }
        .width('100%')

        Column({ space: 6 }) {
          Text('一句话总结（可选）')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
            .width('100%')
          TextInput({ text: this.formTextCard, placeholder: '坚持 · 突破 · 复盘' })
            .width('100%')
            .height(44)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.formTextCard = v })
        }
        .width('100%')

        AppButton({
          label: this.submitting ? '创建中…' : '保存里程碑',
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
