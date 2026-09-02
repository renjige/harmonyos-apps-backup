import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { MoveItem, KnowledgeCard, FavFolder } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceMedia } from '../../services/TuceMedia'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'

@Component
export struct MoveDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop moveId: string = ''
  @State move: MoveItem = new MoveItem()
  @State fav: boolean = false
  @State folders: FavFolder[] = []
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = MoveLibrary.find(this.moveId)
    if (found !== undefined) {
      this.move = found
    }
    this.fav = await TuceStore.isFav(this.moveId)
    this.folders = await TuceStore.folders()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async toggle(): Promise<void> {
    this.fav = await TuceStore.toggleFav(this.moveId)
    this.showToast(this.fav ? '已收入收藏夹' : '已取消收藏')
    TuceNav.bump()
  }

  private async saveCard(): Promise<void> {
    const card = new KnowledgeCard()
    card.id = TuceStore.newId('card')
    card.moveName = this.move.name
    card.focus = this.move.bodyPart
    card.rhythm = `${this.move.minutes} 分钟 · ${this.move.level}`
    card.caution = this.move.caution
    card.insight = this.move.summary
    await TuceStore.saveCard(card)
    this.showToast('已存入知识卡')
  }

  private async addToFolder(folderId: string): Promise<void> {
    await TuceStore.addMoveToFolder(folderId, this.moveId)
    this.showToast('已加入收藏夹')
    TuceNav.bump()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(TuceMedia.cover(this.move.coverKey.length > 0 ? this.move.coverKey : 'warmup'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column() {
              Blank()
              Text(this.move.name)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .padding(Theme.space.s4)
                .width('100%')
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.72)', 1]]
                })
            }
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height(200)

          Text(`${this.move.category} · ${this.move.bodyPart} · ${this.move.level} · ${this.move.minutes} 分钟`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          Column({ space: Theme.space.s2 }) {
            Text('动作说明')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text(this.move.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text(`注意事项：${this.move.caution}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')

          AppButton({
            label: this.fav ? '取消收藏' : '收藏到图册',
            variant: 'primary',
            onTap: (): void => { void this.toggle() }
          })
          AppButton({
            label: '加入训练方案',
            variant: 'secondary',
            onTap: (): void => { TuceNav.open('combo', this.moveId) }
          })
          AppButton({
            label: '保存为知识卡',
            variant: 'ghost',
            onTap: (): void => { void this.saveCard() }
          })

          if (this.folders.length > 0) {
            Text('加入收藏夹')
              .fontSize(Theme.type.subhead)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            ForEach(this.folders, (f: FavFolder) => {
              Text(f.name)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceSubtle : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.sm)
                .onClick((): void => { void this.addToFolder(f.id) })
            }, (f: FavFolder) => f.id)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
