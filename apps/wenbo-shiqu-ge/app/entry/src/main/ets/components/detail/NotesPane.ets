import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExploreNote, ExploreStore } from '../../services/ExploreStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'
import { PavilionMedia } from '../../services/PavilionMedia'

@Component
export struct NotesPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop articleId: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State notes: ExploreNote[] = []
  @State writing: boolean = false
  @State title: string = ''
  @State body: string = ''
  @State coverKey: string = 'hero_bg'
  @State tagText: string = ''
  @State toastText: string = ''
  @State confirmId: string = ''
  private covers: string[] = PavilionMedia.pickKeys()

  aboutToAppear(): void {
    this.writing = this.articleId.length > 0 && this.articleId !== 'all'
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.notes = ExploreStore.noteList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async save(): Promise<void> {
    if (this.body.trim().length === 0 && this.title.trim().length === 0) {
      this.showToast('请先写下发现')
      return
    }
    const aid = this.articleId === 'all' ? '' : this.articleId
    await ExploreStore.saveNote(this.title, this.body, this.coverKey, aid, this.tagText)
    this.title = ''
    this.body = ''
    this.tagText = ''
    this.writing = false
    this.reload()
    this.showToast('探索笔记已保存')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await ExploreStore.deleteNote(id)
    this.confirmId = ''
    this.reload()
    this.showToast('已删除笔记')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.writing ? '写探索笔记' : '探索笔记',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        if (this.writing) {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              TextInput({ text: this.title, placeholder: '标题（可空）' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.title = v })
              TextArea({ text: this.body, placeholder: '记下你的发现、疑问或联想' })
                .width('100%')
                .height(160)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding(14)
                .borderRadius(12)
                .onChange((v: string): void => { this.body = v })
              TextInput({ text: this.tagText, placeholder: '标签，如：天空、色彩、我的理解' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.tagText = v })
              Text('配一张已有封面（不调用相机）')
                .fontSize(13)
                .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .width('100%')
              Scroll() {
                Row({ space: 8 }) {
                  ForEach(this.covers, (key: string) => {
                    Image(PavilionMedia.resource(key))
                      .width(72)
                      .height(48)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(6)
                      .border({
                        width: this.coverKey === key ? 2 : 0,
                        color: Theme.brandInk(this.themeEpoch, this.darkModeOn)
                      })
                      .onClick((): void => { this.coverKey = key })
                  }, (key: string) => key)
                }
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              AppButton({ label: '保存笔记', onTap: (): void => { void this.save() } })
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.writing = false }
              })
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else if (this.notes.length === 0) {
          AppEmpty({
            title: '还没有探索笔记',
            description: '写下理解与延伸，用标签整理。例如：「为什么天空会变色」。',
            actionLabel: '写一条',
            onAction: (): void => { this.writing = true }
          })
        } else {
          Column() {
            AppButton({
              label: '写一条新笔记',
              onTap: (): void => { this.writing = true }
            })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.notes, (n: ExploreNote) => {
                  Column({ space: 6 }) {
                    Image(PavilionMedia.resource(n.coverKey))
                      .width('100%')
                      .height(96)
                      .objectFit(ImageFit.Cover)
                      .borderRadius(8)
                    Text(n.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                      .width('100%')
                    Text(n.body)
                      .fontSize(13)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                      .maxLines(4)
                      .width('100%')
                    if (n.tags.length > 0) {
                      Text(n.tags)
                        .fontSize(12)
                        .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    }
                    Text(this.confirmId === n.id ? '再点一次删除' : '删除')
                      .fontSize(12)
                      .fontColor(Theme.colors().danger)
                      .onClick((): void => { void this.remove(n.id) })
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                  .borderRadius(12)
                }, (n: ExploreNote) => n.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
            }
            .layoutWeight(1)
            .scrollBar(BarState.Off)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding(10)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(20)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
