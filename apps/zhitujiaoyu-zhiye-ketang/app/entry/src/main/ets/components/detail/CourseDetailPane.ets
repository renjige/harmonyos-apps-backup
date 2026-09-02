import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { CourseItem, CourseChapterItem } from '../../models/CareerModels'
import { CareerMedia } from '../../services/CareerMedia'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { FavoriteService } from '../../services/FavoriteService'
import { LearnProgressService } from '../../services/LearnProgressService'
import { StudyStatsService } from '../../services/StudyStatsService'
import { CourseChapterService } from '../../services/CourseChapterService'
import { AuthService } from '../../services/AuthService'
import { DetailShell } from './DetailShell'

@Component
export struct CourseDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: CourseItem = new CourseItem()
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @StorageLink('progressTick') progressTick: number = 0
  @State fav: boolean = false
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    this.fav = FavoriteService.isFavorite(this.item.id)
  }

  private metaLine(): string {
    const parts: string[] = []
    if (this.item.category.length > 0) parts.push(this.item.category)
    if (this.item.level.length > 0) parts.push(this.item.level)
    if (this.item.duration.length > 0) parts.push(this.item.duration)
    if (this.item.teacherName.length > 0) parts.push(this.item.teacherName)
    return parts.join(' · ')
  }

  private progressPercent(): number {
    return LearnProgressService.getPercent(this.item.id)
  }

  private async toggleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('favorite')) {
      this.onRequireAuth()
      return
    }
    this.fav = await FavoriteService.toggle(this.item.id)
  }

  private openEnroll(): void {
    if (!AuthService.requireAuth('submit_enrollment')) {
      this.onRequireAuth()
      return
    }
    CareerDetailNav.open('enroll', this.item.id)
  }

  private openTeacher(): void {
    if (this.item.teacherId.length > 0) {
      CareerDetailNav.open('teacher', this.item.teacherId)
    }
  }

  private chapters(): CourseChapterItem[] {
    return CourseChapterService.buildChapters(this.item)
  }

  private firstLearnIndex(): number {
    const list = this.chapters()
    let i = 0
    while (i < list.length) {
      if (!StudyStatsService.isChapterDone(this.item.id, list[i].index)) {
        return i
      }
      i = i + 1
    }
    return 0
  }

  private startLearn(): void {
    CareerDetailNav.openLearn(this.item.id, this.firstLearnIndex())
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      DetailShell({
        title: '课程详情',
        onBack: () => CareerDetailNav.close()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(CareerMedia.cover(this.item.coverKey, this.item.category))
                .width('100%')
                .height(240)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(240)
                .linearGradient({
                  angle: 180,
                  colors: [[0x00000000, 0.1], [0xCC0F1638, 0.55], [0xF01A2A6C, 1.0]]
                })
              Column({ space: Theme.space.s2 }) {
                Row({ space: Theme.space.s2 }) {
                  Text('免费课程')
                    .fontSize(Theme.type.overline)
                    .fontColor(Theme.colors().brandDeep)
                    .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                    .backgroundColor(Theme.colors().brandAccent)
                    .borderRadius(Theme.radius.pill)
                  if (this.progressPercent() > 0) {
                    Text(`已学 ${this.progressPercent()}%`)
                      .fontSize(Theme.type.overline)
                      .fontColor('#FFFFFF')
                      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                      .backgroundColor('rgba(255,255,255,0.2)')
                      .borderRadius(Theme.radius.pill)
                  }
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

              AppCard({ title: '课程简介', variant: 'plain' }) {
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

              AppCard({ title: '课程大纲', variant: 'outlined' }) {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.chapters(), (line: CourseChapterItem) => {
                    Row({ space: Theme.space.s3 }) {
                      Text(`${line.index}`)
                        .fontSize(Theme.type.caption)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(StudyStatsService.isChapterDone(this.item.id, line.index) ?
                          Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                        .width(24)
                        .height(24)
                        .textAlign(TextAlign.Center)
                        .backgroundColor(StudyStatsService.isChapterDone(this.item.id, line.index) ?
                          Theme.colors().brandPrimary : Theme.colors().brandPrimaryContainer)
                        .borderRadius(Theme.radius.pill)
                      Column({ space: 2 }) {
                        Text(line.title)
                          .fontSize(Theme.type.subhead)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        Text(line.kind === 'video' ? '视频 · 演示' : `图文 · ${line.durationMin} 分钟`)
                          .fontSize(Theme.type.overline)
                          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      }
                      .layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                  }, (line: CourseChapterItem) => `${line.index}`)
                }
                .width('100%')
              }

              Row({ space: Theme.space.s3 }) {
                AppButton({
                  label: this.fav ? '已收藏' : '收藏课程',
                  variant: 'secondary',
                  onTap: (): void => { void this.toggleFavorite() }
                }).layoutWeight(1)
                if (this.item.teacherId.length > 0) {
                  AppButton({
                    label: '查看讲师',
                    variant: 'secondary',
                    onTap: (): void => this.openTeacher()
                  }).layoutWeight(1)
                }
              }
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

      Column({ space: Theme.space.s2 }) {
        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: this.progressPercent() > 0 ? '继续学习' : '开始学习',
            onTap: (): void => { this.startLearn() }
          }).layoutWeight(1)
          AppButton({
            label: '立即报名',
            variant: 'secondary',
            onTap: (): void => this.openEnroll()
          }).layoutWeight(1)
        }
        .width('100%')
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
      .shadow({
        radius: 20,
        color: 'rgba(26,42,108,0.1)',
        offsetY: -4,
        offsetX: 0
      })
    }
    .width('100%')
    .height('100%')
  }
}
