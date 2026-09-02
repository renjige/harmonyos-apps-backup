import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { ExploreCard, ExploreStore } from '../../services/ExploreStore'
import { PavilionDetailNav } from '../../services/PavilionDetailNav'

@Component
export struct CardsPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State cards: ExploreCard[] = []
  @State writing: boolean = false
  @State title: string = ''
  @State body: string = ''
  @State tagText: string = ''
  @State confirmId: string = ''
  @State toastText: string = ''

  aboutToAppear(): void {
    this.reload()
  }

  onRefreshTokenChange(): void {
    this.reload()
  }

  private reload(): void {
    this.cards = ExploreStore.cardList()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0 && this.body.trim().length === 0) {
      this.showToast('请填写标题或描述')
      return
    }
    await ExploreStore.saveCard(this.title, this.body, '', this.tagText)
    this.title = ''
    this.body = ''
    this.tagText = ''
    this.writing = false
    this.reload()
    this.showToast('卡片已收入知识库')
  }

  private async remove(id: string): Promise<void> {
    if (this.confirmId !== id) {
      this.confirmId = id
      this.showToast('再点一次确认删除')
      return
    }
    await ExploreStore.deleteCard(id)
    this.confirmId = ''
    this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: this.writing ? '制作知识卡片' : '知识卡片',
        onClose: (): void => { PavilionDetailNav.close() }
      }) {
        if (this.writing) {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              TextInput({ text: this.title, placeholder: '卡片标题' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.title = v })
              TextArea({ text: this.body, placeholder: '描述：把内容整理成自己的话' })
                .width('100%')
                .height(140)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding(14)
                .borderRadius(12)
                .onChange((v: string): void => { this.body = v })
              TextInput({ text: this.tagText, placeholder: '标签，如：植物、色彩' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                .placeholderColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                .padding({ left: 14, right: 14 })
                .borderRadius(12)
                .onChange((v: string): void => { this.tagText = v })
              AppButton({ label: '保存到知识库', onTap: (): void => { void this.save() } })
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
        } else if (this.cards.length === 0) {
          AppEmpty({
            title: '还没有知识卡片',
            description: '自己整理标题、描述和标签，或在趣知详情生成卡片。',
            actionLabel: '制作一张',
            onAction: (): void => { this.writing = true }
          })
        } else {
          Column() {
            AppButton({
              label: '制作新卡片',
              onTap: (): void => { this.writing = true }
            })
              .margin({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: 8 })
            Scroll() {
              Column({ space: Theme.space.s3 }) {
                ForEach(this.cards, (c: ExploreCard) => {
                  Column({ space: 8 }) {
                    Text(c.title)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Theme.textMain(this.themeEpoch, this.darkModeOn))
                      .width('100%')
                    Text(c.body)
                      .fontSize(14)
                      .fontColor(Theme.textSub(this.themeEpoch, this.darkModeOn))
                      .width('100%')
                    if (c.tags.length > 0) {
                      Text(c.tags)
                        .fontSize(12)
                        .fontColor(Theme.brandInk(this.themeEpoch, this.darkModeOn))
                    }
                    Text(this.confirmId === c.id ? '再点一次删除' : '删除卡片')
                      .fontSize(12)
                      .fontColor(Theme.colors().danger)
                      .onClick((): void => { void this.remove(c.id) })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Theme.cardBg(this.themeEpoch, this.darkModeOn))
                  .borderRadius(12)
                  .onClick((): void => {
                    if (c.articleId.length > 0) {
                      PavilionDetailNav.openArticle(c.articleId)
                    }
                  })
                }, (c: ExploreCard) => c.id)
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
