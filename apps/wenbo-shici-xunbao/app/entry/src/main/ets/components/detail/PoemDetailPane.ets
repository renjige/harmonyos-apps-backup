import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailMetaRow, DetailSection, DetailShell } from './DetailShell'
import { PoemItem } from '../../models/PoetryModels'
import { PoetryMedia } from '../../services/PoetryMedia'
import { HuntProgressStore } from '../../services/HuntProgressStore'
import { PoetryNav } from '../../services/PoetryNav'

@Component
export struct PoemDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop poem: PoemItem = new PoemItem()
  @StorageLink('poetryTick') tick: number = 0
  @State noteDraft: string = ''
  @State showNote: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    const n = HuntProgressStore.noteFor(this.poem.id)
    this.noteDraft = n !== undefined ? n.body : ''
  }

  private favLabel(): string {
    return HuntProgressStore.isFavorite(this.poem.id) ? '取消收藏' : '收藏此诗'
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async toggleFav(): Promise<void> {
    await HuntProgressStore.toggleFavorite(this.poem.id)
    this.showToast(HuntProgressStore.isFavorite(this.poem.id) ? '已收藏' : '已取消收藏')
  }

  private async saveNote(): Promise<void> {
    await HuntProgressStore.saveNote(this.poem.id, this.poem.title, this.noteDraft)
    this.showNote = false
    this.showToast(this.noteDraft.trim().length > 0 ? '笔记已保存' : '笔记已清除')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        DetailShell({
          title: this.poem.title,
          cover: PoetryMedia.cover(this.poem.coverKey),
          onClose: () => PoetryNav.close()
        })
        Scroll() {
          Column({ space: 12 }) {
            DetailMetaRow({
              text: `${this.poem.dynasty} · ${this.poem.author} · ${this.poem.theme}`
            })
            if (this.poem.placeName.length > 0) {
              Text(`诗地：${this.poem.placeName}`)
                .fontSize(13)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            Column({ space: 8 }) {
              Text('导语')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.poem.summary.length > 0 ? this.poem.summary : this.poem.body)
                .fontSize(15)
                .lineHeight(26)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(20)

            DetailSection({ heading: '原文', body: this.poem.body })
            DetailSection({ heading: '注释', body: this.poem.annotation })
            DetailSection({ heading: '译文', body: this.poem.translation })
            DetailSection({ heading: '赏析', body: this.poem.appreciation.length > 0 ? this.poem.appreciation : this.poem.description })

            AppButton({
              label: this.favLabel(),
              onTap: () => { void this.toggleFav() }
            })
            AppButton({
              label: '写笔记',
              variant: 'secondary',
              onTap: () => { this.showNote = true }
            })
            if (this.poem.placeId.length > 0) {
              AppButton({
                label: '查看诗地',
                variant: 'ghost',
                onTap: () => PoetryNav.openPlace(this.poem.placeId)
              })
            }
          }
          .padding({ left: 20, right: 20, top: 16, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showNote) {
        Column({ space: 12 }) {
          Text('读书笔记')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.noteDraft, placeholder: '记下你对这首诗的感受' })
            .height(160)
            .onChange((v: string) => { this.noteDraft = v })
          AppButton({ label: '保存笔记', onTap: () => { void this.saveNote() } })
          AppButton({
            label: '取消',
            variant: 'ghost',
            onTap: () => { this.showNote = false }
          })
        }
        .width('100%')
        .height('100%')
        .padding(20)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(14)
          .fontColor('#F5F0E8')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,26,46,0.88)')
          .borderRadius(12)
          .margin({ top: 48 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
