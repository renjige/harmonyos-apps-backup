import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { XdClip, XdDateUtil, XdLabels, XdTheme } from '../../models/XdModels'
import { XdStore } from '../../services/XdStore'
import { XdDetailNav } from '../../services/XdDetailNav'
import { XdMedia } from '../../services/XdMedia'
import { XdConfirmDialog } from '../xd/XdConfirmDialog'

@Component
export struct ClipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop clipId: string = ''
  onChanged: () => void = () => {}
  @State item: XdClip = new XdClip()
  @State confirmDel: boolean = false
  @State themes: XdTheme[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XdStore.findClip(this.clipId)
    if (found !== undefined) {
      this.item = found
    }
    this.themes = await XdStore.loadThemes()
  }

  private async toggleTreasure(): Promise<void> {
    this.item.treasured = !this.item.treasured
    await XdStore.saveClip(this.item)
    this.onChanged()
    await this.reload()
  }

  private async toggleTheme(id: string): Promise<void> {
    this.item.themeCsv = XdStore.toggleCsv(this.item.themeCsv, id)
    await XdStore.saveClip(this.item)
    this.onChanged()
    await this.reload()
  }

  private async remove(): Promise<void> {
    await XdStore.deleteClip(this.clipId)
    this.onChanged()
    XdDetailNav.closeClip()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XdMedia.momentBanner())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(90)
              .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.8)', 1]] })
            Text(XdLabels.clipKindLabel(this.item.clipKind))
              .fontSize(Theme.type.title3)
              .fontColor('#F6F1E8')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .clip(true)
          .borderRadius(Theme.radius.md)

          AppCard({ title: '收藏内容' }) {
            Text(this.item.text)
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          Text(XdDateUtil.displayDate(this.item.dateKey))
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.themes.length > 0) {
            Text('归入主题')
              .fontSize(Theme.type.subtitleS)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.themes, (t: XdTheme) => {
                Text(t.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(XdStore.csvHas(this.item.themeCsv, t.id) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(XdStore.csvHas(this.item.themeCsv, t.id) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.toggleTheme(t.id) })
              }, (t: XdTheme) => t.id)
            }
          }

          AppButton({
            label: this.item.treasured ? '取消珍藏' : '标为珍藏',
            variant: 'secondary',
            onTap: (): void => { void this.toggleTreasure() }
          })
          AppButton({ label: '编辑', onTap: (): void => { XdDetailNav.openClipEditor(this.item.id) } })
          AppButton({ label: '删除', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        XdConfirmDialog({
          title: '删除这道瞬间？',
          message: '删除后无法恢复。',
          confirmLabel: '删除',
          onConfirm: (): void => { void this.remove() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
