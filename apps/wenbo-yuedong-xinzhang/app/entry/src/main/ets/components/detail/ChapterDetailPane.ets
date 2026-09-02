import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppConfirmDialog } from '../design-system/AppConfirmDialog'
import { DetailShell } from './DetailShell'
import { YdTagPicker } from '../yuedong/YdTagPicker'
import { YdChapterItem } from '../../models/YdModels'
import { YdLocalStore } from '../../services/YdLocalStore'
import { YdDetailNav } from '../../services/YdDetailNav'

@Component
export struct ChapterDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop chapterId: string = ''
  onChanged: () => void = () => {}
  @State chapter: YdChapterItem = new YdChapterItem()
  @State recap: string = ''
  @State toast: string = ''
  @State confirmDelete: boolean = false
  @State isFavorite: boolean = false
  @State periodNotes: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const c = await YdLocalStore.findChapter(this.chapterId)
    if (c !== undefined) {
      this.chapter = c
      this.recap = c.recap
      this.isFavorite = await YdLocalStore.isFavorite('chapter', c.id)
      this.periodNotes = await YdLocalStore.loadChapterPeriodNotes(c.startKey, c.endKey)
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  build() {
    Stack() {
      DetailShell({
        title: this.chapter.title.length > 0 ? this.chapter.title : '篇章详情',
        onClose: (): void => { YdDetailNav.closeChapterDetail() },
        body: (): void => { this.Body() }
      })

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .position({ x: '8%', y: 48 })
          .zIndex(20)
      }

      if (this.confirmDelete) {
        AppConfirmDialog({
          title: '删除篇章',
          message: '确认删除此篇章？章末复盘将无法恢复。',
          confirmLabel: '删除',
          cancelLabel: '取消',
          danger: true,
          onConfirm: (): void => {
            void YdLocalStore.deleteChapter(this.chapter.id).then((): void => {
              this.confirmDelete = false
              this.onChanged()
              YdDetailNav.closeChapterDetail()
            })
          },
          onCancel: (): void => { this.confirmDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  Body() {
    Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.empty_guide'))
              .width('100%')
              .height(148)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.chapter.themeLabel())
                .fontSize(Theme.type.bodyS)
                .fontColor('#FFFFFF')
              Text(this.chapter.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
            })
          }
          .width('100%')

          Text(`${this.chapter.startKey} 至 ${this.chapter.endKey} · ${this.chapter.closed ? '已收官' : `剩余 ${this.chapter.remainDays()} 天`}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)

          if (this.periodNotes.length > 0) {
            Column({ space: Theme.space.s2 }) {
              Text('本周期微记回顾')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.colors().textSecondary)
              Text(this.periodNotes)
                .fontSize(Theme.type.bodyS)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(20)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.md)
            .alignItems(HorizontalAlign.Start)
          }

          YdTagPicker({
            entityType: 'chapter',
            entityId: this.chapter.id,
            onChanged: (): void => { this.onChanged() }
          })

          Column({ space: Theme.space.s2 }) {
            Text('章末复盘（至少 20 字方可收官）')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            TextArea({
              text: this.recap,
              placeholder: '这一章真正推进了什么？卡住的原因？下一章想怎么跃？'
            })
              .height(140)
              .onChange((v: string) => { this.recap = v })
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          if (!this.chapter.closed) {
            AppButton({
              label: '保存草稿',
              variant: 'secondary',
              onTap: (): void => { void this.saveDraft() }
            })
            AppButton({
              label: '写完并收官',
              variant: 'primary',
              onTap: (): void => { void this.closeIt() }
            })
          } else {
            AppButton({
              label: '复制复盘到剪贴板',
              variant: 'primary',
              onTap: (): void => { void this.copyOut() }
            })
          }
          AppButton({
            label: this.isFavorite ? '取消收藏' : '收藏本篇',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFavorite() }
          })
          AppButton({
            label: '删除篇章',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s10 })
    }
  }

  private async saveDraft(): Promise<void> {
    await YdLocalStore.saveChapterRecap(this.chapter.id, this.recap)
    this.showToast('草稿已保存')
    this.onChanged()
  }

  private async closeIt(): Promise<void> {
    const err = await YdLocalStore.closeChapter(this.chapter.id, this.recap)
    if (err.length > 0) {
      this.showToast(err)
      return
    }
    this.onChanged()
    const stats = await YdLocalStore.computeReviewStats()
    this.showToast(`这一章已收官 · 累计 ${stats.chapterClosed} 篇 · 跃动指数 ${stats.leapIndex}`)
    await this.load()
  }

  private async copyOut(): Promise<void> {
    try {
      const text = YdLocalStore.exportChapterText(this.chapter)
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      await pasteboard.getSystemPasteboard().setData(data)
      this.showToast('已复制到剪贴板')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async toggleFavorite(): Promise<void> {
    this.isFavorite = await YdLocalStore.toggleFavorite('chapter', this.chapter.id, this.chapter.title)
    this.onChanged()
    this.showToast(this.isFavorite ? '已加入收藏' : '已取消收藏')
  }
}
