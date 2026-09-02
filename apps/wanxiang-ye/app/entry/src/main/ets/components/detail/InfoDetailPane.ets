import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { InfoCategory, InfoItem } from '../../models/InfoModels'
import { InfoRepository } from '../../services/InfoRepository'
import { WanXiangMedia } from '../../services/WanXiangMedia'
import { InfoRowCard } from '../wanxiang/InfoRowCard'
import { UserDataStore } from '../../services/UserDataStore'
import { ClipboardHelper } from '../../services/ClipboardHelper'

@Component
export struct InfoDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: InfoItem = new InfoItem()
  @Prop favorited: boolean = false
  @Prop readLater: boolean = false
  onClose: () => void = () => {}
  onToggleFavorite: () => void = () => {}
  onToggleReadLater: () => void = () => {}
  onShowToast: (msg: string) => void = () => {}
  onOpenRelated: (id: string) => void = () => {}
  onConvertKnowledge: () => void = () => {}
  onAddReview: () => void = () => {}
  @State related: InfoItem[] = []
  @State showNoteEditor: boolean = false
  @State noteDraft: string = ''
  @State savedNote: string = ''

  aboutToAppear(): void {
    this.related = InfoRepository.relatedItems(this.item.id, 4)
    void this.loadNote()
  }

  aboutToUpdate(): void {
    this.related = InfoRepository.relatedItems(this.item.id, 4)
    void this.loadNote()
  }

  private async loadNote(): Promise<void> {
    this.savedNote = await UserDataStore.getNote(this.item.id)
    this.noteDraft = this.savedNote
  }

  private async copySummary(): Promise<void> {
    const text = `【${this.item.title}】\n${this.item.summary}\n— ${this.item.source} · ${this.item.publishedAt}`
    const ok = await ClipboardHelper.copyText(text)
    if (ok) {
      this.onShowToast('摘要已复制到剪贴板')
    } else {
      this.onShowToast('复制失败，请稍后重试')
    }
  }

  private async saveNote(): Promise<void> {
    await UserDataStore.saveNote(this.item.id, this.noteDraft)
    this.savedNote = this.noteDraft.trim()
    this.showNoteEditor = false
    this.onShowToast('阅读笔记已保存')
  }

  build() {
    Stack() {
      DetailShell({
        title: '资讯详情',
        onClose: (): void => this.onClose(),
        content: (): void => { this.bodyContent() },
        footer: (): void => { this.footerBar() }
      })

      if (this.showNoteEditor) {
        this.noteEditorOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  bodyContent() {
    if (this.item.id.length === 0) {
      Column() {
        Text('内容加载中…')
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textSecondary)
      }
      .width('100%')
      .padding(Theme.space.s4)
    } else {
      this.bodyMain()
    }
  }

  @Builder
  bodyMain() {
    Column({ space: Theme.space.s4 }) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(WanXiangMedia.coverResource(this.item.coverKey))
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.lg)

        Column()
          .width('100%')
          .height(240)
          .borderRadius(Theme.radius.lg)
          .linearGradient({
            angle: 180,
            colors: [['rgba(0,0,0,0)', 0.1], ['rgba(0,0,0,0.88)', 1]]
          })

        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text(`${InfoCategory.emojiOf(this.item.category)} ${InfoCategory.labelOf(this.item.category)}`)
              .fontSize(Theme.type.caption)
              .fontColor('#FFFFFF')
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .backgroundColor('rgba(0,122,255,0.96)')
              .borderRadius(Theme.radius.pill)
            Text(`${this.item.readMinutes} 分钟阅读`)
              .fontSize(Theme.type.caption)
              .fontColor('#F8FAFC')
          }
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .maxLines(3)
          Row({ space: Theme.space.s2 }) {
            Text(this.item.source)
              .fontSize(Theme.type.caption)
              .fontColor('#F1F5F9')
            Text(this.item.publishedAt)
              .fontSize(Theme.type.caption)
              .fontColor('#E2E8F0')
          }
        }
        .padding(Theme.space.s4)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      AppCard({ title: '智慧摘要' }) {
        Text(this.item.summary)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')
      }

      Column({ space: Theme.space.s2 }) {
        Text('正文')
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(this.item.body)
          .fontSize(Theme.type.body)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .lineHeight(26)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      if (this.savedNote.length > 0) {
        AppCard({ title: '我的笔记' }) {
          Text(this.savedNote)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .lineHeight(24)
            .width('100%')
        }
      }

      if (this.related.length > 0) {
        Column({ space: Theme.space.s3 }) {
          Text('相关推荐')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          ForEach(this.related, (rel: InfoItem) => {
            InfoRowCard({
              item: rel,
              onTap: (): void => this.onOpenRelated(rel.id)
            })
          }, (rel: InfoItem) => rel.id)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
  }

  @Builder
  footerBar() {
    Column({ space: Theme.space.s2 }) {
      Row({ space: Theme.space.s2 }) {
        AppButton({
          label: this.favorited ? '已收藏' : '收藏',
          variant: this.favorited ? 'secondary' : 'primary',
          onTap: (): void => this.onToggleFavorite()
        }).layoutWeight(1)
        AppButton({
          label: this.readLater ? '已在稍后再读' : '稍后再读',
          variant: 'secondary',
          onTap: (): void => this.onToggleReadLater()
        }).layoutWeight(1)
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        AppButton({
          label: '复制摘要',
          variant: 'secondary',
          onTap: (): void => { void this.copySummary() }
        }).layoutWeight(1)
        AppButton({
          label: this.savedNote.length > 0 ? '编辑笔记' : '写笔记',
          variant: 'secondary',
          onTap: (): void => {
            this.noteDraft = this.savedNote
            this.showNoteEditor = true
          }
        }).layoutWeight(1)
      }
      .width('100%')

      Row({ space: Theme.space.s2 }) {
        AppButton({
          label: '加入复习',
          variant: 'secondary',
          onTap: (): void => this.onAddReview()
        }).layoutWeight(1)
        AppButton({
          label: '转为知识',
          variant: 'secondary',
          onTap: (): void => this.onConvertKnowledge()
        }).layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
  }

  @Builder
  noteEditorOverlay() {
    Column() {
      Row() {
        Text('阅读笔记')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('取消')
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => { this.showNoteEditor = false })
      }
      .width('100%')
      .padding(Theme.space.pageX)

      TextArea({ text: this.noteDraft, placeholder: '记录你的阅读想法、要点或待办…' })
        .width('100%')
        .height(220)
        .fontSize(Theme.type.body)
        .fontColor(Theme.colors().textPrimary)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.md)
        .padding(Theme.space.s3)
        .onChange((v: string): void => { this.noteDraft = v })
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX })

      AppButton({
        label: '保存笔记',
        variant: 'primary',
        onTap: (): void => { void this.saveNote() }
      })
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(Theme.colors().surfacePage)
    .zIndex(40)
  }
}
