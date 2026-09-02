import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppCard } from '../design-system/AppCard'
import { BookNote } from '../../models/BookNoteModels'
import { TopicShelf } from '../../models/StudyModels'
import { NoteStore } from '../../services/NoteStore'
import { StudyStore } from '../../services/StudyStore'
import { ExportService } from '../../services/ExportService'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { MediaUriUtil } from '../../utils/MediaUriUtil'

@Component
export struct NoteDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('noteEpoch') @Watch('onNoteEpochChange') noteEpoch: number = 0
  @Prop @Watch('onNoteIdChange') noteId: string = ''
  @Prop @Watch('onReloadTokenChange') reloadToken: number = 0
  @State item: BookNote = new BookNote()
  @State related: BookNote[] = []
  @State relatedPreview: BookNote[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  @State topics: TopicShelf[] = []
  @State showTopicPick: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}
  onOpenRelated: (id: string) => void = (_id: string) => {}
  onOpenTopics: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onNoteIdChange(): void {
    void this.load()
  }

  onReloadTokenChange(): void {
    void this.load()
  }

  onNoteEpochChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await NoteStore.findById(this.noteId)
    if (found !== undefined) {
      this.item = NoteStore.cloneNote(found)
      this.related = await NoteStore.sameBookNotes(found.bookName, found.id)
      const preview: BookNote[] = []
      let count = 0
      for (const rel of this.related) {
        if (count >= 3) {
          break
        }
        preview.push(rel)
        count++
      }
      this.relatedPreview = preview
    }
    this.topics = await StudyStore.loadTopics()
  }

  private async addToTopic(topicId: string): Promise<void> {
    const ok = await StudyStore.addNoteToTopic(topicId, this.item.id)
    this.showTopicPick = false
    if (ok) {
      this.showToast('已加入专题')
      this.onChanged()
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await NoteStore.deleteById(this.item.id)
    this.onChanged()
    this.onClose()
  }

  private async fav(): Promise<void> {
    await NoteStore.toggleFavorite(this.item.id)
    await this.load()
    this.onChanged()
    this.showToast(this.item.isFavorite ? '已收藏' : '已取消收藏')
  }

  private async copyQuote(): Promise<void> {
    const ok = await ExportService.copyText(NoteStore.quoteCard(this.item))
    this.showToast(ok ? '金句卡片已复制' : '复制失败')
  }

  private async copyBody(): Promise<void> {
    const ok = await ExportService.copyText(this.item.excerpt)
    this.showToast(ok ? '摘录已复制' : '复制失败')
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('书摘详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Column().width(44)
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.item.coverImage.length > 0) {
                Image(MediaUriUtil.imageSrc(this.item.coverImage))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
              } else {
                Image($r('app.media.hero_library'))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
              }
              Column() {
                Blank()
                Column({ space: 6 }) {
                  Text(CategoryEmojiUtil.chipLabel(this.item.primaryTag()))
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                  Text(this.item.bookName)
                    .fontSize(Theme.type.title3)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .maxLines(2)
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,39,68,0.82)', 1]]
                })
              }
              .width('100%')
              .height(180)
            }
            .width('100%')
            .height(180)
            .borderRadius(Theme.radius.md)
            .clip(true)

            AppCard() {
              Column({ space: 8 }) {
                if (this.item.tags.length > 0) {
                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.item.tags, (t: string) => {
                      Text(CategoryEmojiUtil.chipLabel(t))
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandPrimary)
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .margin({ right: 6, bottom: 6 })
                        .backgroundColor(Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                    }, (t: string) => `${t}_${this.item.updatedAt}`)
                  }
                  .width('100%')
                }
                Text(this.metaLine())
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
                Text(this.item.excerpt)
                  .fontSize(Theme.type.bodyM)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
              }
            }

            if (this.item.reflection.length > 0) {
              AppCard() {
                Column({ space: 8 }) {
                  Text('我的感悟')
                    .fontSize(Theme.type.subhead)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .width('100%')
                  Text(this.item.reflection)
                    .fontSize(Theme.type.bodyM)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    .width('100%')
                }
              }
            }

            if (this.related.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text(`同书其他摘录 · ${this.related.length}`)
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.relatedPreview, (rel: BookNote) => {
                  Row({ space: Theme.space.s3 }) {
                    Column({ space: 4 }) {
                      Text(rel.excerptPreview())
                        .fontSize(Theme.type.bodyS)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .maxLines(2)
                        .width('100%')
                      if (rel.pageLabel().length > 0) {
                        Text(rel.pageLabel())
                          .fontSize(Theme.type.caption)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      }
                    }
                    .layoutWeight(1)
                    AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.sm)
                  .onClick((): void => { this.onOpenRelated(rel.id) })
                }, (rel: BookNote) => rel.id)
              }
              .width('100%')
            }

            Column({ space: Theme.space.s2 }) {
              AppButton({
                label: this.item.isFavorite ? '取消收藏' : '收藏这条书摘',
                onTap: (): void => { void this.fav() }
              })
              AppButton({
                label: '加入专题',
                variant: 'secondary',
                onTap: (): void => {
                  if (this.topics.length === 0) {
                    this.onOpenTopics()
                    return
                  }
                  this.showTopicPick = true
                }
              })
              AppButton({
                label: '编辑',
                variant: 'secondary',
                onTap: (): void => { this.onEdit(this.item.id) }
              })
              AppButton({
                label: '复制金句卡片',
                variant: 'secondary',
                onTap: (): void => { void this.copyQuote() }
              })
              AppButton({
                label: '复制摘录',
                variant: 'secondary',
                onTap: (): void => { void this.copyBody() }
              })
              AppButton({
                label: this.confirmDelete ? '再点一次确认删除' : '删除',
                variant: 'danger',
                onTap: (): void => { void this.doDelete() }
              })
            }
            .width('100%')
            .padding({ bottom: Theme.space.s10 })
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandDeep)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: Theme.space.s6 })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }

      if (this.showTopicPick) {
        Column() {
          Blank()
            .layoutWeight(1)
            .backgroundColor(Theme.colors().overlayScrim)
            .onClick((): void => { this.showTopicPick = false })
          Column({ space: Theme.space.s3 }) {
            Text('选择专题')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.topics, (t: TopicShelf) => {
              Text(t.title)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { void this.addToTopic(t.id) })
            }, (t: TopicShelf) => t.id)
            AppButton({
              label: '新建专题',
              variant: 'secondary',
              onTap: (): void => {
                this.showTopicPick = false
                this.onOpenTopics()
              }
            })
          }
          .width('100%')
          .padding(Theme.space.s5)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius({ topLeft: 20, topRight: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  private metaLine(): string {
    const bits: string[] = []
    bits.push(this.item.tagLine())
    if (this.item.pageLabel().length > 0) {
      bits.push(this.item.pageLabel())
    }
    bits.push(NoteStore.timeLabel(this.item.createdAt))
    return bits.join(' · ')
  }
}
