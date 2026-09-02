import { Theme } from '../../components/design-system/Theme'
import { AppButton } from '../../components/design-system/AppButton'
import { ResearchBar } from '../../components/research/ResearchBar'
import { ResearchSandboxImage } from '../../components/research/ResearchSandboxImage'
import { ResearchNote, ViewpointCard } from '../../models/ResearchModels'
import { LanguageCraftMedia } from '../../services/LanguageCraftMedia'
import { LanguageCraftNav } from '../../services/LanguageCraftNav'
import { ResearchNav } from '../../services/ResearchNav'
import { ResearchStore } from '../../services/ResearchStore'

@Component
export struct NoteDetailPane {
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @StorageLink('researchItemId') @Watch('onItem') itemId: string = ''
  @StorageLink('researchRefresh') @Watch('onItem') refreshToken: number = 0
  @State note: ResearchNote = new ResearchNote()
  @State toastText: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  onItem(): void {
    void this.load()
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async load(): Promise<void> {
    this.confirmDelete = false
    const found = await ResearchStore.findNote(this.itemId)
    if (found !== undefined) {
      this.note = found
    }
  }

  private async makeCard(): Promise<void> {
    const quote = this.note.viewpoint.trim().length > 0 ? this.note.viewpoint.trim() : this.note.body.trim()
    if (quote.length === 0) {
      this.showToast('先写观点或正文再生成卡片')
      return
    }
    const card = ViewpointCard.create()
    card.quote = quote
    card.sourceId = this.note.id
    await ResearchStore.saveCard(card)
    this.showToast('已生成观点卡片')
  }

  private async toggleStar(): Promise<void> {
    this.note.starred = this.note.starred === '1' ? '0' : '1'
    await ResearchStore.saveNote(this.note)
    this.showToast(this.note.starred === '1' ? '已收藏' : '已取消收藏')
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除这条笔记')
      return
    }
    await ResearchStore.deleteNote(this.note.id)
    ResearchNav.open('notes')
  }

  private sendToPolish(): void {
    const blob = this.noteBodyBlob()
    LanguageCraftNav.applyToPolish(blob)
  }

  private sendToSummary(): void {
    LanguageCraftNav.applyToSummary(this.noteBodyBlob(), 'detail')
  }

  private noteBodyBlob(): string {
    if (this.note.viewpoint.length > 0) {
      return `${this.note.title}\n${this.note.viewpoint}\n${this.note.body}`
    }
    return `${this.note.title}\n${this.note.body}`
  }

  build() {
    Stack() {
      Column() {
        ResearchBar({ title: '笔记详情' })
        Scroll() {
          Column({ space: Theme.space.s3 }) {
            Stack() {
              if (this.note.photoPath.length > 0) {
                ResearchSandboxImage({ srcPath: this.note.photoPath, imgHeight: 180, radius: Theme.radius.lg })
              } else {
                Image(LanguageCraftMedia.cover(this.note.coverKey.length > 0 ? this.note.coverKey : 'cover_library'))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.lg)
              }
              Column() {
                Text(this.note.title)
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .linearGradient({
                angle: 180,
                colors: [['rgba(10,37,64,0)', 0.35], ['rgba(10,37,64,0.82)', 1]]
              })
              .justifyContent(FlexAlign.End)
              .height(180)
              .borderRadius(Theme.radius.lg)
            }
            .width('100%')
            .height(180)

            Text(ResearchStore.timeLabel(this.note.updatedAt))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.of(this.darkModeOn).textSecondary)
              .width('100%')

            if (this.note.viewpoint.length > 0) {
              Column({ space: 6 }) {
                Text('我的观点')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.of(this.darkModeOn).brandPrimary)
                  .width('100%')
                Text(this.note.viewpoint)
                  .fontSize(Theme.type.body)
                  .fontColor(Theme.of(this.darkModeOn).textPrimary)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(Theme.of(this.darkModeOn).brandPrimaryContainer)
              .borderRadius(Theme.radius.md)
            }

            Text(this.note.body.length > 0 ? this.note.body : '（尚未填写正文）')
              .fontSize(Theme.type.body)
              .fontColor(Theme.of(this.darkModeOn).textPrimary)
              .width('100%')

            AppButton({
              label: '编辑笔记',
              onTap: (): void => { ResearchNav.openNoteEditor(this.note.id) }
            })
            AppButton({
              label: '生成观点卡片',
              variant: 'secondary',
              onTap: (): void => { void this.makeCard() }
            })
            AppButton({
              label: this.note.starred === '1' ? '取消收藏' : '收藏这条笔记',
              variant: 'secondary',
              onTap: (): void => { void this.toggleStar() }
            })
            AppButton({
              label: '送到润色台',
              variant: 'secondary',
              onTap: (): void => { this.sendToPolish() }
            })
            AppButton({
              label: '生成摘要',
              variant: 'secondary',
              onTap: (): void => { this.sendToSummary() }
            })
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除笔记',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.of(this.darkModeOn).surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.of(this.darkModeOn).brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.of(this.darkModeOn).brandPrimary)
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
}
