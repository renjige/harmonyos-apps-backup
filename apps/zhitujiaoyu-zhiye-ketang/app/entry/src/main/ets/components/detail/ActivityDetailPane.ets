import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { ActivityItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { AuthService } from '../../services/AuthService'
import { DetailShell } from './DetailShell'

@Component
export struct ActivityDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ActivityItem = new ActivityItem()
  onRequireAuth: () => void = () => {}

  private metaLine(): string {
    const parts: string[] = []
    if (this.item.type.length > 0) parts.push(this.item.type)
    if (this.item.startAt.length > 0) parts.push(this.item.startAt)
    if (this.item.venue.length > 0) parts.push(this.item.venue)
    if (this.item.capacity > 0) parts.push(`名额 ${this.item.capacity}`)
    return parts.join(' · ')
  }

  private openEnroll(): void {
    if (!AuthService.requireAuth('submit_enrollment')) {
      this.onRequireAuth()
      return
    }
    CareerDetailNav.open('activityEnroll', this.item.id)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      DetailShell({
        title: '活动详情',
        onBack: () => CareerDetailNav.close()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CareerMedia.cover(this.item.coverKey, this.item.type))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [[0x00000000, 0.1], [0xCC0F1638, 0.55], [0xF01A2A6C, 1.0]]
                })
              Column({ space: Theme.space.s2 }) {
                if (this.item.status.length > 0) {
                  Text(this.item.status)
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandDeep)
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor(Theme.colors().brandAccent)
                    .borderRadius(Theme.radius.pill)
                }
                Text(this.item.title)
                  .fontSize(Theme.type.title2)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .maxLines(3)
              }
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s5
              })
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
            .width('100%')
            .clip(true)

            Column({ space: Theme.space.s4 }) {
              Text(this.metaLine())
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              AppCard({ title: '活动简介' }) {
                Text(this.item.summary)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(24)
                  .width('100%')
              }
              Text(this.item.description.length > 0 ? this.item.description : this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(26)
                .width('100%')
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: 96
            })
            .width('100%')
          }
          .width('100%')
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      Column() {
        AppButton({
          label: '立即报名',
          onTap: (): void => this.openEnroll()
        })
      }
      .width('100%')
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s3,
        bottom: Theme.space.s5
      })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
    }
    .width('100%')
    .height('100%')
  }
}
