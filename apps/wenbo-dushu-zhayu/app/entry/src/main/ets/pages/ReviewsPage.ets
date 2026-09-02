import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { CreateReviewRequest, ReviewItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct ReviewsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State items: ReviewItem[] = []
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formRating: number = 5
  @State submitting: boolean = false
  @State formError: string = ''
  private starOptions: number[] = [1, 2, 3, 4, 5]

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      this.items = await ReadingBizService.loadReviews('')
    } else {
      this.items = []
    }
  }

  private openForm(): void {
    if (!AuthService.requireAuth('create_note')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formBody = ''
    this.formRating = 5
    this.formError = ''
    this.showForm = true
  }

  private async submit(): Promise<void> {
    if (this.formBody.trim().length === 0) {
      this.formError = '请写下阅读评价'
      return
    }
    this.submitting = true
    const req = new CreateReviewRequest()
    req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '阅读书评'
    req.body = this.formBody.trim()
    req.summary = req.body.substring(0, 80)
    req.rating = this.formRating
    const created = await ReadingBizService.createReview(req)
    this.submitting = false
    if (created !== undefined) {
      this.showForm = false
      await this.reload()
      this.onChanged()
      return
    }
    this.formError = '保存失败，请稍后重试'
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
        Text('书评记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      if (this.showForm) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            if (this.formError.length > 0) {
              Text(this.formError)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().danger)
                .width('100%')
            }
            TextInput({ text: this.formTitle, placeholder: '书评标题（可选）' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
            Text('评分')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
            Row({ space: 8 }) {
              ForEach(this.starOptions, (n: number) => {
                Text(`${n}星`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.formRating === n ?
                    Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .backgroundColor(this.formRating === n ?
                    Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { this.formRating = n })
              }, (n: number) => `${n}`)
            }
            TextArea({ text: this.formBody, placeholder: '记录这本书给你的阅读体验…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(160)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
            AppButton({
              label: this.submitting ? '保存中…' : '发布书评',
              disabled: this.submitting,
              onTap: (): void => { void this.submit() }
            })
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.showForm = false }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      } else if (this.items.length === 0) {
        Column() {
          AppEmpty({
            title: '还没有书评',
            description: '读完一本书，写下评分与阅读体验',
            actionLabel: '写书评',
            onAction: (): void => { this.openForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: ReviewItem) => {
              ReadingListCard({
                title: item.title,
                summary: item.summary.length > 0 ? item.summary : item.body,
                coverKey: item.coverKey,
                meta: `${item.rating} 星 · ${item.recordDate}`,
                onTap: (): void => { ReadingDetailNav.openReview(item.id) }
              })
            }, (item: ReviewItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if (!this.showForm) {
        AppButton({
          label: '写书评',
          onTap: (): void => { this.openForm() }
        })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
