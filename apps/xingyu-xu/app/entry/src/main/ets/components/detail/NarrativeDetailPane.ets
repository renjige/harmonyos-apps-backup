import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { Narrative } from '../../models/XingyuModels'
import { XingyuMedia } from '../../services/XingyuMedia'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct NarrativeDetailPane {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @Prop narrativeId: string = ''
  @State item: Narrative = new Narrative()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const n = await XingyuStore.findNarrative(this.narrativeId)
    if (n !== undefined) {
      this.item = n
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    const on = await XingyuStore.toggleFavorite('narrative', this.item.id, this.item.preview())
    await this.reload()
    this.showToast(on ? '已加入星光收藏' : '已取消收藏')
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await XingyuStore.deleteNarrative(this.item.id)
    XingyuNav.closeNarrative()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XingyuMedia.image(this.item.coverKey()))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(120)
              .linearGradient({
                angle: 180,
                colors: [['rgba(18,24,43,0.05)', 0], ['rgba(18,24,43,0.82)', 1]]
              })
            Column({ space: 6 }) {
              Text(this.item.templateLabel())
                .fontSize(Theme.type.caption)
                .fontColor('#C4A574')
              Text(this.item.title.length > 0 ? this.item.title : '未命名叙事')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F3EC')
              Text(`${DateHelper.displayDate(this.item.dateKey)} · ${this.item.statusLabel()}`)
                .fontSize(Theme.type.footnote)
                .fontColor('#D4CFC4')
            }
            .padding(Theme.space.s4)
            .width('100%')
          }
          .width('100%')
          .clip(true)
          .borderRadius(Theme.radius.lg)

          AppCard({ title: '摘要' }) {
            Text(this.item.preview())
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }

          AppCard({ title: '正文' }) {
            Column({ space: Theme.space.s3 }) {
              Text(this.item.fieldA.length > 0 ? this.item.fieldA : '尚未填写')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(this.item.fieldB.length > 0 ? this.item.fieldB : '')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(this.item.fieldC.length > 0 ? this.item.fieldC : '')
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            .width('100%')
          }

          if (this.item.tags.length > 0) {
            Text(`标签 ${this.item.tags.join(' · ')}`)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }

          AppButton({
            label: this.item.isFavorite ? '取消收藏' : '收入星光收藏',
            onTap: () => {
              void this.toggleFav()
            }
          })
          AppButton({
            label: '编辑这条叙事',
            variant: 'secondary',
            onTap: () => XingyuNav.openEditor('narrative', this.item.id)
          })
          AppButton({
            label: this.confirmDelete ? '确认删除' : '删除',
            variant: 'danger',
            onTap: () => {
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
      .width('100%')
      .height('100%')

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(Theme.space.s3)
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.sm)
          .margin({ top: Theme.space.s4 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
