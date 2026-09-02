import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { QyClip, QyDateUtil, QyLabels, QyTheme } from '../../models/QyModels'
import { QyStore } from '../../services/QyStore'
import { QyDetailNav } from '../../services/QyDetailNav'
import { QyMedia } from '../../services/QyMedia'
import { QyConfirmDialog } from '../qy/QyConfirmDialog'

@Component
export struct ClipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop clipId: string = ''
  onChanged: () => void = () => {}
  @State item: QyClip = new QyClip()
  @State confirmDel: boolean = false
  @State themes: QyTheme[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await QyStore.findClip(this.clipId)
    if (found !== undefined) {
      this.item = found
    }
    this.themes = await QyStore.loadThemes()
  }

  private async toggleTreasure(): Promise<void> {
    this.item.treasured = !this.item.treasured
    await QyStore.saveClip(this.item)
    this.onChanged()
    await this.reload()
  }

  private async toggleTheme(id: string): Promise<void> {
    this.item.themeCsv = QyStore.toggleCsv(this.item.themeCsv, id)
    await QyStore.saveClip(this.item)
    this.onChanged()
    await this.reload()
  }

  private async remove(): Promise<void> {
    await QyStore.deleteClip(this.clipId)
    this.onChanged()
    QyDetailNav.closeClip()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(QyMedia.teaBanner())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(90)
              .linearGradient({ angle: 180, colors: [['rgba(47,74,71,0)', 0], ['rgba(47,74,71,0.8)', 1]] })
            Text(QyLabels.clipKindLabel(this.item.clipKind))
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
          Text(QyDateUtil.displayDate(this.item.dateKey))
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.themes.length > 0) {
            Text('归入主题')
              .fontSize(Theme.type.subtitleS)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.themes, (t: QyTheme) => {
                Text(t.title)
                  .fontSize(Theme.type.caption)
                  .fontColor(QyStore.csvHas(this.item.themeCsv, t.id) ? Theme.colors().brandOnPrimary : Theme.colors().brandPrimary)
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .margin({ right: 8, bottom: 8 })
                  .backgroundColor(QyStore.csvHas(this.item.themeCsv, t.id) ? Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                  .borderRadius(Theme.radius.pill)
                  .onClick((): void => { void this.toggleTheme(t.id) })
              }, (t: QyTheme) => t.id)
            }
          }

          AppButton({
            label: this.item.treasured ? '取消珍藏' : '标为珍藏',
            variant: 'secondary',
            onTap: (): void => { void this.toggleTreasure() }
          })
          AppButton({ label: '编辑', onTap: (): void => { QyDetailNav.openClipEditor(this.item.id) } })
          AppButton({ label: '删除', variant: 'danger', onTap: (): void => { this.confirmDel = true } })
          Column().height(Theme.space.s10)
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
      .width('100%')
      .height('100%')

      if (this.confirmDel) {
        QyConfirmDialog({
          title: '删除这道观察？',
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
