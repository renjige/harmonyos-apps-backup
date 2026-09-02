import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { XuAgendaItem } from '../../models/XuModels'
import { XuLocalStore } from '../../services/XuLocalStore'
import { XuDetailNav } from '../../services/XuDetailNav'
import { XuMedia } from '../../services/XuMedia'
import { XuConfirmDialog } from '../xu/XuConfirmDialog'
import { XuBizService } from '../../services/XuBizService'

@Component
export struct AgendaDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onIdChange') agendaId: string = ''
  @Prop refreshToken: number = 0
  @State item: XuAgendaItem = new XuAgendaItem()
  @State confirmDel: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await XuLocalStore.findAgenda(this.agendaId)
    if (found !== undefined) {
      this.item = found
    }
  }

  private async toggleDone(): Promise<void> {
    this.item.done = !this.item.done
    this.item.updatedAt = Date.now()
    await XuLocalStore.saveAgenda(this.item)
    void XuBizService.syncAgenda(this.item)
    this.onChanged()
  }

  private async doDelete(): Promise<void> {
    await XuLocalStore.deleteAgenda(this.item.id)
    this.confirmDel = false
    this.onChanged()
    XuDetailNav.closeAgenda()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(XuMedia.calendar())
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
            Column() {
              Text(this.item.kindLabel())
                .fontSize(Theme.type.caption)
                .fontColor('#FFFFFF')
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(26,42,58,0)', 0], ['rgba(26,42,58,0.82)', 1]]
            })
          }
          .width('100%')
          .borderRadius(Theme.radius.xl)
          .clip(true)

          Text(`${this.item.dateKey}  ${this.item.timeText.length > 0 ? this.item.timeText : '全天'}  ·  优先级${this.item.priorityLabel()}`)
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')

          AppCard({ title: '摘要' }) {
            Text(this.item.remark.length > 0 ? this.item.remark : '未填写备注')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
          }

          Column({ space: Theme.space.s3 }) {
            AppButton({
              label: this.item.done ? '标记为未完成' : '标记完成',
              onTap: (): void => { void this.toggleDone() }
            })
            AppButton({
              label: '编辑',
              variant: 'secondary',
              onTap: (): void => { XuDetailNav.openAgendaEditor(this.item.id) }
            })
            AppButton({
              label: '删除',
              variant: 'danger',
              onTap: (): void => { this.confirmDel = true }
            })
          }
          .width('100%')
          .padding({ bottom: Theme.space.s10 })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        .width('100%')
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      if (this.confirmDel) {
        XuConfirmDialog({
          title: '删除这条日程？',
          message: '删除后无法恢复。',
          onConfirm: (): void => { void this.doDelete() },
          onCancel: (): void => { this.confirmDel = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
