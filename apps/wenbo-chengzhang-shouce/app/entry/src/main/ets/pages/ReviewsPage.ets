import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { AppIcon } from '../components/design-system/AppIcon'
import { CreateReviewRequest, GrowthRecordItem } from '../models/GrowthModels'
import { GrowthBizService } from '../services/GrowthBizService'
import { AuthService } from '../services/AuthService'
import { ReviewDetailPane } from '../components/detail/ReviewDetailPane'

@Component
export struct ReviewsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State items: GrowthRecordItem[] = []
  @State loading: boolean = true
  @State showForm: boolean = false
  @State formWin: string = ''
  @State formBlock: string = ''
  @State formNext: string = ''
  @State formThanks: string = ''
  @State formError: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @State selectedId: string = ''
  @State detailToken: number = 0
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
      this.items = await GrowthBizService.loadReviews(this.currentUsername)
    } else {
      this.items = []
    }
    this.loading = false
  }

  private openForm(): void {
    if (!AuthService.requireAuth('create_review')) {
      this.onRequireAuth()
      return
    }
    this.formWin = ''
    this.formBlock = ''
    this.formNext = ''
    this.formThanks = ''
    this.formError = ''
    this.showForm = true
  }

  private async submitReview(): Promise<void> {
    if (this.formWin.trim().length === 0 && this.formBlock.trim().length === 0 &&
      this.formNext.trim().length === 0 && this.formThanks.trim().length === 0) {
      this.formError = '请至少填写一项'
      return
    }
    this.submitting = true
    const req = new CreateReviewRequest()
    req.win = this.formWin.trim()
    req.block = this.formBlock.trim()
    req.nextGoal = this.formNext.trim()
    req.thanks = this.formThanks.trim()
    req.userId = this.currentUsername
    const created = await GrowthBizService.createReview(req)
    this.submitting = false
    if (created !== undefined) {
      this.showForm = false
      await this.reload()
      this.toastText = '复盘已保存'
      setTimeout(() => { this.toastText = '' }, 2400)
    } else {
      this.formError = GrowthBizService.lastError.length > 0 ? GrowthBizService.lastError : '保存失败'
    }
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s2 }) {
          Column() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .rotate({ angle: 180 })
          .onClick((): void => { this.onClose() })
          Text('每周复盘')
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
          .onClick((): void => { this.openForm() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

        if (this.showForm) {
          this.FormPane()
        } else if (this.loading) {
          AppLoading({ label: '加载复盘…' }).layoutWeight(1)
        } else if (this.items.length === 0) {
          Column() {
            AppEmpty({
              title: '还没有周复盘',
              description: AuthService.isLoggedIn()
                ? '用四个问题回顾本周：进步、卡住、下周目标、感谢'
                : '登录后可写每周复盘',
              actionLabel: '写本周复盘',
              onAction: (): void => { this.openForm() }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.items, (item: GrowthRecordItem) => {
              ListItem() {
                Column({ space: 6 }) {
                  Text(item.title)
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(item.summary)
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.xl)
                .border({ width: 1, color: Theme.colors().strokeHairline })
                .onClick((): void => {
                  this.selectedId = item.id
                  this.detailToken += 1
                })
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s3
              })
            }, (item: GrowthRecordItem) => item.id)
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.selectedId.length > 0) {
        ReviewDetailPane({
          itemId: this.selectedId,
          refreshToken: this.detailToken,
          onReviewDeleted: (): void => { void this.reload() },
          onClose: (): void => {
            this.selectedId = ''
            void this.reload()
          }
        })
          .width('100%')
          .height('100%')
          .zIndex(12)
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
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  FormPane() {
    Scroll() {
      Column({ space: Theme.space.s3 }) {
        Text('本周四问')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')
        Text('本周最值得记录的进步')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.formWin, placeholder: '一件具体的小事即可' })
          .onChange((v: string) => { this.formWin = v })
          .height(72)
          .width('100%')
        Text('卡在哪里')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.formBlock, placeholder: '时间、情绪或方法' })
          .onChange((v: string) => { this.formBlock = v })
          .height(72)
          .width('100%')
        Text('下周最小可行目标')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.formNext, placeholder: '小到本周一定能完成' })
          .onChange((v: string) => { this.formNext = v })
          .height(72)
          .width('100%')
        Text('想感谢的人或事')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
        TextArea({ text: this.formThanks, placeholder: '可选' })
          .onChange((v: string) => { this.formThanks = v })
          .height(72)
          .width('100%')
        if (this.formError.length > 0) {
          Text(this.formError)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().danger)
            .width('100%')
        }
        Text(this.submitting ? '保存中…' : '保存复盘')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().brandOnPrimary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(14)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.lg)
          .onClick((): void => { void this.submitReview() })
        Text('取消')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding(10)
          .onClick((): void => { this.showForm = false })
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      .width('100%')
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }
}
