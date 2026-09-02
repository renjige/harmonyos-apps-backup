import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { SportRecord } from '../../models/SportRecord'
import { SportTypeOption } from '../../models/SportRecord'
import { RecordStore } from '../../services/RecordStore'
import { ShareCardService } from '../../services/ShareCardService'
import { SportDetailNav } from '../../services/SportDetailNav'

@Component
export struct SportRecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop recordId: string = ''
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  @State record: SportRecord = new SportRecord()
  @State photoIndex: number = 0
  @State toastText: string = ''
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await RecordStore.findById(this.recordId)
    if (found !== undefined) {
      this.record = found
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async shareCard(): Promise<void> {
    const ok = await ShareCardService.copyCard(this.record)
    this.showToast(ok ? '成就卡片已复制，可粘贴分享' : '复制失败，请重试')
  }

  private async toggleFav(): Promise<void> {
    const on = await RecordStore.toggleFavorite(this.record.id)
    this.record.favorited = on
    this.onChanged()
    this.showToast(on ? '已收入精彩时刻' : '已移出精彩时刻')
  }

  private async deleteRecord(): Promise<void> {
    await RecordStore.deleteRecord(this.record.id)
    this.onChanged()
    this.onClose()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          if (this.record.photos.length > 0) {
            Swiper() {
              ForEach(this.record.photos, (path: string, idx: number) => {
                Image(path)
                  .width('100%')
                  .height(320)
                  .objectFit(ImageFit.Cover)
              }, (path: string, idx: number) => `${idx}_${path}`)
            }
            .width('100%')
            .height(320)
            .indicator(this.record.photos.length > 1)
            .borderRadius(Theme.radius.lg)
          } else {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image($r('app.media.hero_home'))
                .width('100%')
                .height(240)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Column() {
                Blank()
                Text(this.record.displayTitle())
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .padding(Theme.space.s4)
              }
              .width('100%')
              .height('100%')
              .linearGradient({
                angle: 180,
                colors: [['rgba(0,0,0,0)', 0.4], ['rgba(0,0,0,0.75)', 1]]
              })
            }
          }

          AppCard({
            title: this.record.displayTitle(),
            onTap: (): void => {},
            content: (): void => {
              Text(`${SportTypeOption.labelOf(this.record.sportType)} · ${this.record.date} ${this.record.time}`)
                .fontSize(Theme.type.bodyS)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          })

          Column({ space: Theme.space.s2 }) {
            if (this.record.duration > 0) {
              this.MetricRow('时长', `${this.record.duration} 分钟`)
            }
            if (this.record.distance > 0) {
              this.MetricRow('距离', `${this.record.distance} km`)
            }
            if (this.record.calories > 0) {
              this.MetricRow('卡路里', `${this.record.calories} kcal`)
            }
            if (this.record.weight > 0) {
              this.MetricRow('体重', `${this.record.weight} kg`)
            }
          }
          .width('100%')

          if (this.record.note.length > 0) {
            Text(this.record.note)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
          }

          AppButton({ label: '生成分享卡片', variant: 'primary', onTap: (): void => { void this.shareCard() } })
          AppButton({
            label: this.record.favorited ? '移出精彩时刻' : '收入精彩时刻',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFav() }
          })
          AppButton({
            label: '编辑这条记录',
            variant: 'secondary',
            onTap: (): void => {
              SportDetailNav.closeDetail()
              SportDetailNav.openEditor(this.record.id)
            }
          })
          AppButton({
            label: '打开蜕变报告',
            variant: 'secondary',
            onTap: (): void => {
              SportDetailNav.closeDetail()
              SportDetailNav.openReport()
            }
          })
          AppButton({
            label: '删除记录',
            variant: 'secondary',
            onTap: (): void => { this.confirmDelete = true }
          })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
      }
      .layoutWeight(1)

      if (this.confirmDelete) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('确认删除这条运动记录？')
              .fontSize(Theme.type.title3)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.confirmDelete = false }
              }).layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'primary',
                onTap: (): void => { void this.deleteRecord() }
              }).layoutWeight(1)
            }
            .width('100%')
          }
          .padding(Theme.space.s6)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.lg)
          .margin(Theme.space.pageX)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.colors().overlayScrim)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  MetricRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(Theme.type.bodyS)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('30%')
      Text(value)
        .fontSize(Theme.type.body)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
    }
    .width('100%')
  }
}
