import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { CreateInspirationRequest, InspirationItem } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct InspirationsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State items: InspirationItem[] = []
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formContent: string = ''
  @State formBook: string = ''
  @State submitting: boolean = false
  @State formError: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    if (AuthService.isLoggedIn()) {
      this.items = await ReadingBizService.loadInspirations('')
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
    this.formContent = ''
    this.formBook = ''
    this.formError = ''
    this.showForm = true
  }

  private async submit(): Promise<void> {
    if (this.formContent.trim().length === 0) {
      this.formError = '请写下这一刻的想法'
      return
    }
    this.submitting = true
    const req = new CreateInspirationRequest()
    req.title = this.formTitle.trim().length > 0 ? this.formTitle.trim() : '阅读灵感'
    req.content = this.formContent.trim()
    req.tags = this.formBook.trim().length > 0 ? [this.formBook.trim()] : []
    const created = await ReadingBizService.createInspiration(req)
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
        Text('灵感收藏')
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
            TextInput({ text: this.formTitle, placeholder: '给灵感起个短标题（可选）' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
            TextInput({ text: this.formBook, placeholder: '关联书名（可选）' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBook = v })
            TextArea({ text: this.formContent, placeholder: '阅读时突然想到的句子、问题或行动…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(160)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formContent = v })
            AppButton({
              label: this.submitting ? '保存中…' : '收入思考库',
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
            title: '思考库是空的',
            description: '把阅读中闪过的想法留下来，之后可以写成笔记或书评',
            actionLabel: '记下灵感',
            onAction: (): void => { this.openForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: InspirationItem) => {
              ReadingListCard({
                title: item.title,
                summary: item.content,
                coverKey: item.coverKey,
                meta: item.recordDate,
                tags: item.tags,
                onTap: (): void => { ReadingDetailNav.openInspiration(item.id) }
              })
            }, (item: InspirationItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if (!this.showForm) {
        AppButton({
          label: '记下灵感',
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
