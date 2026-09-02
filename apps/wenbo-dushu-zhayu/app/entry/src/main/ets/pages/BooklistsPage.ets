import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ReadingListCard } from '../components/reading/ReadingListCard'
import { BooklistItem, CreateBooklistRequest } from '../models/ReadingModels'
import { ReadingBizService } from '../services/ReadingBizService'
import { ReadingDetailNav } from '../services/ReadingDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct BooklistsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  onClose: () => void = () => {}
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}
  @State items: BooklistItem[] = []
  @State showForm: boolean = false
  @State formTitle: string = ''
  @State formBody: string = ''
  @State formBooks: string = ''
  @State submitting: boolean = false
  @State formError: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.items = await ReadingBizService.loadBooklists()
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

  private openForm(): void {
    if (!AuthService.requireAuth('create_book')) {
      this.onRequireAuth()
      return
    }
    this.formTitle = ''
    this.formBody = ''
    this.formBooks = ''
    this.formError = ''
    this.showForm = true
  }

  private async submit(): Promise<void> {
    if (this.formTitle.trim().length === 0) {
      this.formError = '请填写书单名称'
      return
    }
    this.submitting = true
    const req = new CreateBooklistRequest()
    req.title = this.formTitle.trim()
    req.body = this.formBody.trim()
    req.summary = req.body.substring(0, 40)
    req.tags = this.parseTags(this.formBooks)
    const created = await ReadingBizService.createBooklist(req)
    this.submitting = false
    if (created !== undefined) {
      this.showForm = false
      await this.reload()
      this.onChanged()
      return
    }
    this.formError = '创建失败，请稍后重试'
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
        Text('专题书单')
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
            TextInput({ text: this.formTitle, placeholder: '如：成长书单' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formTitle = v })
            TextArea({ text: this.formBody, placeholder: '这本书单想送给谁、解决什么问题…' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(120)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBody = v })
            TextInput({ text: this.formBooks, placeholder: '推荐书籍，逗号分隔' })
              .fontColor(Theme.colors().textPrimary)
              .placeholderColor(Theme.colors().textSecondary)
              .caretColor(Theme.colors().brandPrimary)
              .width('100%')
              .height(44)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.formBooks = v })
            AppButton({
              label: this.submitting ? '创建中…' : '创建书单',
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
            title: '暂无书单',
            description: '专题书单加载后会出现在这里',
            actionLabel: '创建我的书单',
            onAction: (): void => { this.openForm() }
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            ForEach(this.items, (item: BooklistItem) => {
              ReadingListCard({
                title: item.title,
                subtitle: item.category,
                summary: item.summary.length > 0 ? item.summary : item.body,
                coverKey: item.coverKey,
                tags: item.tags,
                meta: item.userId.length > 0 ? '我的书单' : '专题推荐',
                onTap: (): void => { ReadingDetailNav.openBooklist(item.id) }
              })
            }, (item: BooklistItem) => item.id)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      if (!this.showForm) {
        AppButton({
          label: '创建我的书单',
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
