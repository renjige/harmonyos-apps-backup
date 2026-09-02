import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { ExcerptItem } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'
import { ExportService } from '../../services/ExportService'
import { FolioMedia } from '../../services/FolioMedia'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct ExcerptDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') excerptId: string = ''
  @State item: ExcerptItem = new ExcerptItem()
  @State favOn: boolean = false
  @State docTitle: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  private favBusy: boolean = false
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  onEdit: (id: string) => void = (_id: string) => {}

  aboutToAppear(): void {
    void this.load()
  }

  onIdChange(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await FolioStore.findExcerpt(this.excerptId)
    if (found !== undefined) {
      this.item = found
      this.favOn = found.isFavorite
      const doc = await FolioStore.findDoc(found.docId)
      this.docTitle = doc !== undefined ? doc.title : '未归类文稿'
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2000)
  }

  private async fav(): Promise<void> {
    if (this.favBusy) {
      return
    }
    this.favBusy = true
    const next = await FolioStore.toggleFavorite(this.item.id)
    this.favOn = next
    const copy = new ExcerptItem()
    copy.id = this.item.id
    copy.docId = this.item.docId
    copy.folioId = this.item.folioId
    copy.text = this.item.text
    copy.reflection = this.item.reflection
    copy.tags = this.item.tags
    copy.isFavorite = next
    copy.createdAt = this.item.createdAt
    copy.updatedAt = Date.now()
    this.item = copy
    this.onChanged()
    this.showToast(next ? '已收藏，将进入每日智慧卡片' : '已取消收藏')
    this.favBusy = false
  }

  private async copy(): Promise<void> {
    const ok = await ExportService.copyText(this.item.text)
    this.showToast(ok ? '摘录已复制' : '复制失败')
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await FolioStore.deleteExcerpt(this.item.id)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      DetailShell({
        title: '摘录详情',
        onClose: (): void => { this.onClose() }
      }) {
        Scroll() {
          Column({ space: 12 }) {
            Stack() {
              Image(FolioMedia.cover('banner_review'))
                .width('100%')
                .height(168)
                .objectFit(ImageFit.Cover)
              Column() {
                Text(this.docTitle)
                  .fontSize(Theme.type.caption)
                  .fontColor('#FFFFFF')
                Text(this.item.tagLine().length > 0 ? this.item.tagLine() : '未打标签')
                  .fontSize(Theme.type.title3)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .margin({ top: 6 })
              }
              .width('100%')
              .padding(16)
              .linearGradient({
                angle: 180,
                colors: [['rgba(45,62,80,0)', 0], ['rgba(27,40,56,0.88)', 1]]
              })
            }
            .width('100%')
            .height(168)
            .borderRadius(Theme.radius.card)
            .clip(true)

            AppCard({ title: '原文摘录' }) {
              Text(this.item.text)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
            }
            if (this.item.reflection.length > 0) {
              AppCard({ title: '感想' }) {
                Text(this.item.reflection)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .lineHeight(22)
                  .width('100%')
              }
            }
            Text(FolioStore.timeLabel(this.item.createdAt))
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .width('100%')
            Row() {
              AppButton({
                label: this.favOn ? '取消收藏' : '收藏进每日卡片',
                onTap: (): void => { void this.fav() }
              })
            }
            .width('100%')
            .onClick((): void => { void this.fav() })
            AppButton({ label: '编辑摘录', variant: 'secondary', onTap: (): void => { this.onEdit(this.item.id) } })
            AppButton({ label: '复制原文', variant: 'secondary', onTap: (): void => { void this.copy() } })
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除摘录',
              variant: 'danger',
              onTap: (): void => { void this.doDelete() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
