import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { SparkItem } from '../../models/XingyuModels'
import { XingyuMedia } from '../../services/XingyuMedia'
import { XingyuStore } from '../../services/XingyuStore'
import { XingyuNav } from '../../services/XingyuNav'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct SparkDetailPane {
  @StorageLink('xingyuRev') @Watch('onRev') xingyuRev: number = 0
  @Prop sparkId: string = ''
  @State item: SparkItem = new SparkItem()
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRev(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const s = await XingyuStore.findSpark(this.sparkId)
    if (s !== undefined) {
      this.item = s
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => {
      this.toastText = ''
    }, 2200)
  }

  private async toggleFav(): Promise<void> {
    const on = await XingyuStore.toggleFavorite('spark', this.item.id, this.item.preview())
    await this.reload()
    this.showToast(on ? '已加入星光收藏' : '已取消收藏')
  }

  private async doDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.showToast('再点一次确认删除')
      return
    }
    await XingyuStore.deleteSpark(this.item.id)
    XingyuNav.closeSpark()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XingyuMedia.image('cover_hobby'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(110)
              .linearGradient({
                angle: 180,
                colors: [['rgba(18,24,43,0.05)', 0], ['rgba(18,24,43,0.82)', 1]]
              })
            Column({ space: 6 }) {
              Text(this.item.kindLabel())
                .fontSize(Theme.type.caption)
                .fontColor('#C4A574')
              Text(this.item.title.length > 0 ? this.item.title : '未命名灵感')
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#F6F3EC')
              Text(DateHelper.displayDate(this.item.dateKey))
                .fontSize(Theme.type.footnote)
                .fontColor('#D4CFC4')
            }
            .padding(Theme.space.s4)
            .width('100%')
          }
          .clip(true)
          .borderRadius(Theme.radius.lg)

          AppCard({ title: '想法' }) {
            Text(this.item.body.length > 0 ? this.item.body : '尚未填写')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .width('100%')
          }
          AppCard({ title: '来源' }) {
            Text(this.item.source.length > 0 ? this.item.source : '未记录来源')
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          }
          AppCard({ title: '计划' }) {
            Text(this.item.plan.length > 0 ? this.item.plan : '尚未写下计划')
              .fontSize(Theme.type.body)
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
            label: '编辑这条灵感',
            variant: 'secondary',
            onTap: () => XingyuNav.openEditor('spark', this.item.id)
          })
          AppButton({
            label: this.confirmDelete ? '确认删除' : '删除',
            variant: 'danger',
            onTap: () => {
              void this.doDelete()
            }
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)

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
