import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CourtMedia } from '../config/CourtMedia'
import { CourtBizService } from '../services/CourtBizService'
import { CourtDetailNav } from '../services/CourtDetailNav'
import { AuthService } from '../services/AuthService'
import { BookingItem } from '../models/CourtModels'

@Component
export struct BookingsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State loading: boolean = true
  @State bookings: BookingItem[] = []
  @State toastText: string = ''
  @State confirmCancelId: string = ''
  @State busyId: string = ''
  onRequireAuth: () => void = () => {}
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (this.isLoggedIn()) {
      this.bookings = await CourtBizService.loadBookings(AuthService.currentUsername())
    } else {
      this.bookings = []
    }
    this.loading = false
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private statusColor(status: string): ResourceColor {
    if (status === 'confirmed') {
      return Theme.colors().success
    }
    if (status === 'cancelled') {
      return Theme.colors().textTertiary
    }
    return Theme.colors().brandAccent
  }

  private statusText(status: string): string {
    if (status === 'confirmed') {
      return '已打卡'
    }
    if (status === 'cancelled') {
      return '已取消'
    }
    return '待到场'
  }

  private async checkIn(b: BookingItem): Promise<void> {
    this.busyId = b.id
    const ok = await CourtBizService.updateBookingStatus(b.id, 'confirmed', '到场打卡')
    this.busyId = ''
    if (ok) {
      this.showToast('已到场打卡')
      this.onChanged()
      await this.reload()
      return
    }
    this.showToast('打卡失败，请稍后重试')
  }

  private async cancel(b: BookingItem): Promise<void> {
    if (this.confirmCancelId !== b.id) {
      this.confirmCancelId = b.id
      this.showToast('再点一次确认取消预约')
      return
    }
    this.busyId = b.id
    const ok = await CourtBizService.updateBookingStatus(b.id, 'cancelled', b.remark)
    this.busyId = ''
    this.confirmCancelId = ''
    if (ok) {
      this.showToast('预约已取消')
      this.onChanged()
      await this.reload()
      return
    }
    this.showToast('取消失败，请稍后重试')
  }

  build() {
    Stack() {
      Column() {
        Row({ space: Theme.space.s3 }) {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textPrimary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Theme.colors().surfaceSubtle)
          .borderRadius(Theme.radius.pill)
          .rotate({ angle: 180 })
          .onClick(() => {
            CourtDetailNav.close()
          })

          Text('我的预约')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        if (this.loading) {
          Text('加载中…')
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
            .padding(Theme.space.pageX)
        } else if (!this.isLoggedIn()) {
          Column({ space: Theme.space.s4 }) {
            AppEmpty({
              title: '请先登录',
              description: '登录后可提交、取消预约并到场打卡',
              actionLabel: '去登录',
              onAction: (): void => {
                this.onRequireAuth()
              }
            })
            AppButton({
              label: '返回',
              variant: 'secondary',
              onTap: (): void => {
                CourtDetailNav.close()
              }
            })
          }
          .padding(Theme.space.pageX)
          .layoutWeight(1)
        } else if (this.bookings.length === 0) {
          Column({ space: Theme.space.s4 }) {
            AppEmpty({
              title: '暂无预约',
              description: '去发现页选场馆，点选可订时段后提交',
              actionLabel: '关闭',
              onAction: (): void => {
                CourtDetailNav.close()
              }
            })
          }
          .padding(Theme.space.pageX)
          .layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.bookings, (b: BookingItem) => {
                Column({ space: Theme.space.s3 }) {
                  Row({ space: Theme.space.s3 }) {
                    Image(CourtMedia.byKey(CourtBizService.inferCoverKeyForTitle(b.serviceTitle)))
                      .width(64)
                      .height(64)
                      .borderRadius(Theme.radius.md)
                      .objectFit(ImageFit.Cover)
                    Column({ space: 4 }) {
                      Text(b.serviceTitle)
                        .fontSize(Theme.type.subhead)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().textPrimary)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(`${b.preferredDate} ${b.preferredTime}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                      Text(this.statusText(b.status))
                        .fontSize(Theme.type.caption)
                        .fontColor(this.statusColor(b.status))
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  if (b.status === 'pending') {
                    Row({ space: Theme.space.s2 }) {
                      AppButton({
                        label: this.busyId === b.id ? '处理中…' : '到场打卡',
                        onTap: (): void => {
                          void this.checkIn(b)
                        }
                      })
                    }
                    .width('100%')
                    Row({ space: Theme.space.s2 }) {
                      AppButton({
                        label: this.confirmCancelId === b.id ? '再点确认取消' : '取消预约',
                        variant: 'secondary',
                        onTap: (): void => {
                          void this.cancel(b)
                        }
                      })
                    }
                    .width('100%')
                  }
                }
                .width('100%')
                .padding(Theme.space.s4)
                .backgroundColor(Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .border({ width: 1, color: Theme.colors().strokeHairline })
              }, (b: BookingItem) => b.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s10
            })
          }
          .layoutWeight(1)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
            .maxLines(3)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: Theme.space.s6, left: Theme.space.pageX, right: Theme.space.pageX })
        .alignItems(HorizontalAlign.Center)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
