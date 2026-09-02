import { common } from '@kit.AbilityKit'
import { pasteboard } from '@kit.BasicServicesKit'
import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppointmentItem, PrepItem } from '../../models/AppointmentModels'
import { AppointmentCardUtil } from './AppointmentCards'
import { AppointmentMedia } from '../../services/AppointmentMedia'
import { AppointmentService } from '../../services/AppointmentService'
import { ScheduleEngine } from '../../services/ScheduleEngine'

@Component
export struct AppointmentDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: AppointmentItem = new AppointmentItem()
  @State confirmDelete: boolean = false
  @State followText: string = ''
  @State showFollow: boolean = false
  onClose: () => void = () => {}
  onComplete: (id: string, context: common.UIAbilityContext, followUp: string) => Promise<boolean> = async () => false
  onDelete: (id: string) => Promise<boolean> = async () => false
  onShare: (text: string) => void = () => {}
  onEdit: () => void = () => {}
  onPostpone: () => void = () => {}
  onPin: () => void = () => {}
  onPrep: (index: number) => void = () => {}
  onReopen: () => void = () => {}
  onDuplicate: () => void = () => {}
  onCheckIn: () => void = () => {}
  onFavorite: () => void = () => {}

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(Theme.type.subhead)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onClose() })
        Blank()
        Text(this.item.favorite ? '取消收藏' : '收藏')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onFavorite() })
        Text(this.item.pinned ? '取消置顶' : '置顶')
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .onClick((): void => { this.onPin() })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(AppointmentMedia.coverForItem(this.item))
              .width('100%')
              .height(180)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.xl)
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 180,
                colors: [['rgba(17,24,39,0.08)', 0], ['rgba(17,24,39,0.82)', 1]]
              })
              .borderRadius(Theme.radius.xl)
            Column({ space: 6 }) {
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
              Text(`${this.item.dateTimeLabel()} · ${this.item.durationMin} 分钟`)
                .fontSize(Theme.type.subhead)
                .fontColor('#FFFFFF')
                .width('100%')
            }
            .padding(18)
          }

          Column({ space: 8 }) {
            Text(`${this.item.sceneLabel()} · ${this.item.isImportant() ? '重要' : '普通'} · ${this.item.place.length > 0 ? this.item.place : '未填地点'}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            if (this.item.contactName.length > 0) {
              Text(`相关人：${this.item.contactName}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            if (this.leaveLabel().length > 0) {
              Text(this.leaveLabel())
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().brandPrimary)
                .width('100%')
            }
            Text(AppointmentCardUtil.rowMeta(this.item))
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .width('100%')
          .padding(18)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.xl)

          if (this.prepList().length > 0) {
            Column({ space: 8 }) {
              Text('会前准备')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              ForEach(this.prepList(), (row: PrepItem) => {
                Row({ space: 8 }) {
                  Text(row.done ? '已完成' : '待完成')
                    .fontSize(Theme.type.caption)
                    .fontColor(row.done ? Theme.colors().success : Theme.colors().brandPrimary)
                  Text(row.name)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .onClick((): void => { this.onPrep(row.index) })
              }, (row: PrepItem) => `${row.index}_${row.name}`)
            }
            .width('100%')
            .padding(18)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.xl)
          }

          if (this.item.note.length > 0) {
            Text(this.item.note)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(18)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
          }

          if (this.item.followUp.length > 0) {
            Text(`跟进：${this.item.followUp}`)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .padding(18)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.xl)
          }

          if (!this.item.isDone() && this.showFollow) {
            Column({ space: 8 }) {
              Text('完成时可记下跟进（选填）')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textTertiary)
                .width('100%')
              TextInput({ text: this.followText, placeholder: '例如：改约周五 / 补发纪要' })
                .onChange((v: string) => { this.followText = v })
              AppButton({ label: '确认完成', onTap: (): void => { void this.handleComplete() } })
            }
            .width('100%')
          }

          if (!this.item.isDone() && !this.showFollow) {
            AppButton({ label: '标记完成', onTap: (): void => { this.showFollow = true } })
            AppButton({ label: '改期', variant: 'secondary', onTap: (): void => { this.onPostpone() } })
            AppButton({
              label: this.item.checkedIn ? '取消到达打卡' : '到达打卡',
              variant: 'secondary',
              onTap: (): void => { this.onCheckIn() }
            })
          }
          if (this.item.isDone()) {
            AppButton({ label: '重新打开', variant: 'secondary', onTap: (): void => { this.onReopen() } })
          }
          AppButton({ label: '再约一次（明天同时段）', variant: 'secondary', onTap: (): void => { this.onDuplicate() } })
          AppButton({ label: '编辑', variant: 'secondary', onTap: (): void => { this.onEdit() } })
          AppButton({ label: '分享约定', variant: 'secondary', onTap: (): void => { this.handleShare() } })
          if (this.confirmDelete) {
            AppButton({
              label: '确认删除此约定',
              variant: 'danger',
              onTap: (): void => { void this.handleDelete() }
            })
          } else {
            AppButton({
              label: '删除',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = true }
            })
          }
        }
        .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  private prepList(): PrepItem[] {
    return ScheduleEngine.prepItems(this.item)
  }

  private leaveLabel(): string {
    return ScheduleEngine.leaveByLabel(this.item)
  }

  private async handleComplete(): Promise<void> {
    const ctx = getContext(this) as common.UIAbilityContext
    const ok = await this.onComplete(this.item.id, ctx, this.followText)
    if (ok) {
      this.onClose()
    }
  }

  private async handleDelete(): Promise<void> {
    const ok = await this.onDelete(this.item.id)
    if (ok) {
      this.onClose()
    }
  }

  private handleShare(): void {
    const text = AppointmentService.shareText(this.item)
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
      pasteboard.getSystemPasteboard().setData(data)
      this.onShare(text)
    } catch {
      this.onShare(text)
    }
  }
}
