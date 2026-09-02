import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { TeacherItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { DetailShell } from './DetailShell'

@Component
export struct TeacherDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: TeacherItem = new TeacherItem()

  private metaLine(): string {
    let line = this.item.specialty
    if (this.item.years > 0) {
      line = `${line} · ${this.item.years} 年教龄`
    }
    return line
  }

  build() {
    DetailShell({
      title: '讲师详情',
      onBack: () => CareerDetailNav.close()
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(CareerMedia.cover(this.item.coverKey, '职业技能'))
              .width('100%')
              .height(220)
              .objectFit(ImageFit.Cover)
            Column()
              .width('100%')
              .height(220)
              .linearGradient({
                angle: 180,
                colors: [[0x00000000, 0.15], [0xE61A2A6C, 1.0]]
              })
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .padding({
                left: Theme.space.pageX,
                right: Theme.space.pageX,
                bottom: Theme.space.s4
              })
          }
          .width('100%')
          .height(220)
          .clip(true)

          Column({ space: Theme.space.s4 }) {
            Text(this.metaLine())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            AppCard({ title: '讲师简介' }) {
              Text(this.item.summary.length > 0 ? this.item.summary : this.item.bio)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text(this.item.bio)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
            AppButton({
              label: '查看该讲师课程',
              onTap: (): void => {
                CareerDetailNav.close()
                AppStorage.setOrCreate('mainTab', 1)
                AppStorage.setOrCreate('learnFilterTeacher', this.item.id)
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
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
