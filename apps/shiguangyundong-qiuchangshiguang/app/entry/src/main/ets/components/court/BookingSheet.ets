import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { AppDatePickerField, AppTimePickerField } from '../design-system/AppDatePickerField'
import { AppTextField } from '../design-system/AppTextField'
import { CourtBizService } from '../../services/CourtBizService'
import { CourtDetailNav } from '../../services/CourtDetailNav'
import { VenueItem } from '../../models/CourtModels'
import { AuthService } from '../../services/AuthService'

@Component
export struct BookingSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop venueId: string = ''
  @State venue: VenueItem = new VenueItem()
  @State contactName: string = ''
  @State contactPhone: string = ''
  @State address: string = ''
  @State preferredDate: string = ''
  @State preferredTime: string = ''
  @State remark: string = ''
  @State submitting: boolean = false
  @State toastText: string = ''
  @State errorText: string = ''
  onSuccess: () => void = () => {}
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.loadVenue()
  }

  private async loadVenue(): Promise<void> {
    const found = await CourtBizService.findVenue(this.venueId)
    if (found !== undefined) {
      this.venue = found
      if (this.address.length === 0) {
        this.address = found.district.length > 0 ? found.district : found.title
      }
    }
    const slot = AppStorage.get<string>('courtSlotTime') ?? ''
    if (slot.length > 0) {
      this.preferredTime = slot
    }
  }

  private showToast(message: string): void {
    this.toastText = message
    setTimeout(() => {
      this.toastText = ''
    }, 2800)
  }

  private async submit(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      this.onRequireAuth()
      return
    }
    this.errorText = ''
    if (this.contactName.length === 0) {
      this.errorText = '请填写联系人姓名'
      return
    }
    if (this.contactPhone.length !== 11) {
      this.errorText = '请填写 11 位手机号'
      return
    }
    if (this.address.length === 0) {
      this.errorText = '请填写详细地址或场馆备注'
      return
    }
    if (this.preferredDate.length === 0 || this.preferredTime.length === 0) {
      this.errorText = '请选择预约日期与时段'
      return
    }
    this.submitting = true
    const username = AuthService.currentUsername()
    const ok = await CourtBizService.createBooking(
      this.venueId,
      this.contactName,
      this.contactPhone,
      this.address,
      this.preferredDate,
      this.preferredTime,
      this.remark,
      username
    )
    this.submitting = false
    if (ok) {
      this.showToast('预约已提交，工作人员将电话确认')
      this.onSuccess()
      CourtDetailNav.close()
      return
    }
    this.errorText = '提交失败，请稍后重试'
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

          Text('预约场地')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4, bottom: Theme.space.s2 })

        if (this.errorText.length > 0) {
          Text(this.errorText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().danger)
            .width('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })
        }

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Column({ space: 4 }) {
              Text('预约场馆')
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
              Text(this.venue.title.length > 0 ? this.venue.title : '场馆')
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .width('100%')
              Text(`${this.venue.category} · ${this.venue.priceLabel}`)
                .fontSize(Theme.type.footnote)
                .fontColor(Theme.colors().textOnBrandContainer)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().brandPrimaryContainer)
            .borderRadius(Theme.radius.lg)

            this.FormField('联系人', this.contactName, '请输入姓名', (v: string) => {
              this.contactName = v
            })
            this.FormField('手机号', this.contactPhone, '11 位手机号', (v: string) => {
              this.contactPhone = v
            })
            this.FormField('地址 / 备注', this.address, '场馆地址或到场说明', (v: string) => {
              this.address = v
            })

            AppDatePickerField({
              label: '预约日期',
              value: this.preferredDate,
              onChange: (v: string) => {
                this.preferredDate = v
              }
            })
            AppTimePickerField({
              label: this.preferredTime.length > 0 ? `已选时段 ${this.preferredTime}` : '预约时段',
              value: this.preferredTime,
              onChange: (v: string) => {
                this.preferredTime = v
              }
            })
            this.FormField('备注（选填）', this.remark, '人数、装备需求等', (v: string) => {
              this.remark = v
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
        .edgeEffect(EdgeEffect.Spring)

        Column({ space: Theme.space.s3 }) {
          AppButton({
            label: this.submitting ? '提交中…' : '提交预约',
            onTap: (): void => {
              void this.submit()
            }
          })
        }
        .width('100%')
        .padding(Theme.space.pageX)
        .padding({ bottom: Theme.space.s4 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

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

  @Builder
  FormField(label: string, value: string, placeholder: string, onChange: (v: string) => void) {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(Theme.type.caption)
        .fontColor(Theme.colors().textTertiary)
        .width('100%')
      AppTextField({
        text: value,
        placeholder: placeholder,
        onChange: (v: string): void => {
          onChange(v)
        }
      })
    }
    .width('100%')
  }
}
