import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { CourseItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { LearnProgressService } from '../../services/LearnProgressService'

@Component
export struct CourseListCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CourseItem = new CourseItem()
  @Prop showProgress: boolean = false
  onTap: () => void = () => {}

  private progressPercent(): number {
    return LearnProgressService.getPercent(this.item.id)
  }

  build() {
    Column({ space: 0 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(CareerMedia.cover(this.item.coverKey, this.item.category))
          .width('100%')
          .height(128)
          .objectFit(ImageFit.Cover)
        Row({ space: Theme.space.s1 }) {
          Text('免费')
            .fontSize(Theme.type.overline)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor(Theme.colors().brandAccent)
            .borderRadius(Theme.radius.pill)
          Text(this.item.level)
            .fontSize(Theme.type.overline)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .backgroundColor('rgba(26,42,108,0.72)')
            .borderRadius(Theme.radius.pill)
        }
        .margin({ left: Theme.space.s3, top: Theme.space.s3 })
      }
      .width('100%')
      .height(128)
      .clip(true)

      Column({ space: Theme.space.s2 }) {
        Text(this.item.category)
          .fontSize(Theme.type.overline)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          .fontWeight(FontWeight.Medium)
          .width('100%')
        Text(this.item.title)
          .fontSize(Theme.type.subhead)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.summary)
          .fontSize(Theme.type.caption)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: Theme.space.s2 }) {
          Text(this.item.duration)
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .layoutWeight(1)
          if (this.item.teacherName.length > 0) {
            Text(this.item.teacherName)
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .maxLines(1)
          }
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
        }
        .width('100%')

        if (this.showProgress && this.progressPercent() > 0) {
          Column({ space: 4 }) {
            Row() {
              Text(`学习进度 ${this.progressPercent()}%`)
                .fontSize(Theme.type.caption)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                .layoutWeight(1)
            }
            .width('100%')
            Stack({ alignContent: Alignment.Start }) {
              Row()
                .width('100%')
                .height(6)
                .backgroundColor(Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
              Row()
                .width(`${this.progressPercent()}%`)
                .height(6)
                .backgroundColor(Theme.colors().brandAccent)
                .borderRadius(Theme.radius.pill)
            }
            .width('100%')
          }
          .width('100%')
        }
      }
      .padding(Theme.space.s4)
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.md)
    .clip(true)
    .border({ width: 1, color: Theme.colors().strokeHairline })
    .shadow({
      radius: 16,
      color: 'rgba(26,42,108,0.06)',
      offsetY: 4,
      offsetX: 0
    })
    .onClick(() => this.onTap())
  }
}
