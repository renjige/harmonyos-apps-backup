import { Theme } from '../design-system/Theme'
import { AppNavBar } from '../design-system/AppNavBar'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { InspirationItem } from '../../models/JournalModels'
import { TripStore } from '../../services/TripStore'
import { TripNav } from '../../services/TripNav'
import { AppToast } from '../../services/AppToast'

@Component
export struct InspireDetailPane {
  @StorageLink('detailInspireId') @Watch('onId') inspireId: string = ''
  @StorageLink('darkModeOn') darkModeOn: boolean = false
  @Prop @Watch('onTok') refreshToken: number = 0
  @State item: InspirationItem = new InspirationItem()
  @State showConfirm: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  onId(): void {
    this.load()
  }

  onTok(): void {
    this.load()
  }

  private load(): void {
    const item = TripStore.findInspiration(this.inspireId)
    if (item !== undefined) {
      this.item = item
    }
  }

  private async remove(): Promise<void> {
    await TripStore.removeInspiration(this.inspireId)
    TripNav.closeInspireDetail()
    AppToast.show('灵感已删除')
  }

  build() {
    Stack() {
      Column() {
        AppNavBar({
          title: '灵感详情',
          onBack: (): void => { TripNav.closeInspireDetail() }
        })
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Text(this.item.title)
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .width('100%')
            Text(this.item.kindLabel())
              .fontSize(Theme.type.caption)
              .fontColor(Theme.palette(this.darkModeOn).brandAccent)
            AppCard({ title: '摘要' }) {
              Text(this.item.destination.length > 0 ? this.item.destination : '未填写目的地')
                .fontSize(Theme.type.subhead)
                .fontColor(Theme.palette(this.darkModeOn).textSecondary)
            }
            Text(this.item.body.length > 0 ? this.item.body : '暂无详细内容')
              .fontSize(Theme.type.bodyL)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
              .lineHeight(26)
              .width('100%')
            AppButton({
              label: '转为行程规划',
              onTap: (): void => {
                AppStorage.setOrCreate('tripFormId', '')
                AppStorage.setOrCreate('showTripForm', true)
                AppStorage.setOrCreate('detailInspireId', '')
                AppStorage.setOrCreate('tabBarHidden', true)
                AppStorage.setOrCreate('mainTabIndex', 0)
              }
            })
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '编辑',
                variant: 'secondary',
                onTap: (): void => {
                  AppStorage.setOrCreate('inspireFormId', this.inspireId)
                  AppStorage.setOrCreate('showInspireForm', true)
                  AppStorage.setOrCreate('detailInspireId', '')
                }
              })
                .layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'secondary',
                onTap: (): void => { this.showConfirm = true }
              })
                .layoutWeight(1)
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.palette(this.darkModeOn).surfacePage)

      if (this.showConfirm) {
        Column() {
          Column({ space: Theme.space.s4 }) {
            Text('确认删除这条灵感？')
              .fontSize(Theme.type.subtitleM)
              .fontColor(Theme.palette(this.darkModeOn).textPrimary)
            Row({ space: Theme.space.s3 }) {
              AppButton({
                label: '取消',
                variant: 'secondary',
                onTap: (): void => { this.showConfirm = false }
              })
                .layoutWeight(1)
              AppButton({
                label: '删除',
                onTap: (): void => { void this.remove() }
              })
                .layoutWeight(1)
            }
            .width('100%')
          }
          .width('86%')
          .padding(Theme.space.s6)
          .backgroundColor(Theme.palette(this.darkModeOn).surfaceCard)
          .borderRadius(Theme.radius.lg)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(Theme.palette(this.darkModeOn).overlayScrim)
        .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
