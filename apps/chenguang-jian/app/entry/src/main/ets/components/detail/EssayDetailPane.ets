import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { EssayItem } from '../../models/EssayModels'
import { DawnMedia } from '../../services/DawnMedia'
import { EssayDateUtil } from '../../services/EssayDateUtil'
import { EssayNav } from '../../services/EssayNav'
import { EssayStore } from '../../services/EssayStore'

@Component
export struct EssayDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  onChanged: () => void = () => {}
  @State item: EssayItem | undefined = undefined
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.loadItem()
  }

  onItemIdChange(): void {
    this.confirmDelete = false
    this.loadItem()
  }

  private loadItem(): void {
    this.item = EssayStore.find(this.itemId)
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await EssayStore.remove(this.item.id)
    this.confirmDelete = false
    EssayNav.closeDetail()
    this.onChanged()
  }

  private async doArchive(): Promise<void> {
    if (this.item === undefined) {
      return
    }
    await EssayStore.archive(this.item.id, true)
    EssayNav.closeDetail()
    this.onChanged()
  }

  build() {
    Stack() {
      if (this.item === undefined) {
        Column({ space: Theme.space.s4 }) {
          AppEmpty({ title: '这张笺不在了', description: '也许它已经被轻轻收起。' })
          AppButton({ label: '返回', variant: 'secondary', onTap: (): void => { EssayNav.closeDetail() } })
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .justifyContent(FlexAlign.Center)
      } else {
        DetailShell({ title: this.item.displayTitle(), onClose: (): void => { EssayNav.closeDetail() } }) {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(DawnMedia.cover(this.item.coverKey))
                  .width('100%')
                  .height(220)
                  .objectFit(ImageFit.Cover)
                Column() {
                  Text(this.item.displayTitle())
                    .fontSize(Theme.type.title1)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#FFFFFF')
                    .width('100%')
                }
                .width('100%')
                .padding({ left: 20, right: 20, bottom: 18 })
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(61,50,40,0)', 0], ['rgba(61,50,40,0.78)', 1]]
                })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .borderRadius(Theme.radius.lg)
              .clip(true)

              AppCard({ title: '这一刻' }) {
                Text(`${EssayDateUtil.cardTime(this.item.createdAt)}${this.item.weather.length > 0 ? ` · ${this.item.weather}` : ''}`)
                  .fontSize(Theme.type.subhead)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  .width('100%')
              }

              AppCard({ title: '笺上的字' }) {
                Text(this.item.content.length > 0 ? this.item.content : '这一页还是空白。')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .textAlign(this.item.align === 'center' ? TextAlign.Center : TextAlign.Start)
              }

              if (this.item.tagList().length > 0) {
                Row({ space: 8 }) {
                  ForEach(this.item.tagList(), (tag: string) => {
                    Text(`#${tag}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor(Theme.colors().brandPrimaryContainer)
                      .borderRadius(Theme.radius.pill)
                  }, (tag: string) => tag)
                }
                .width('100%')
              }

              AppButton({
                label: '继续写这一张',
                onTap: (): void => {
                  if (this.item !== undefined) {
                    EssayNav.closeDetail()
                    EssayNav.openWrite(this.item.id)
                  }
                }
              })
              AppButton({
                label: '归档',
                variant: 'secondary',
                onTap: (): void => { void this.doArchive() }
              })
              AppButton({
                label: this.confirmDelete ? '再点一次确认删除' : '删除这张笺',
                variant: 'secondary',
                onTap: (): void => {
                  if (!this.confirmDelete) {
                    this.confirmDelete = true
                    this.showToast('删除后无法恢复')
                    return
                  }
                  void this.doDelete()
                }
              })
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }
}
